/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// 混合容器最小基座：本地 rawfile 页面 + 三条原生 ↔ H5 通信路径。
// 依据 docs/05-arkweb-hybrid-container.md 与 docs/03-arkts-codegen-rules.md（R 系列 + W1–W16）。
// ⚠️ 未编译验证：Command Line Tools 未就位，见 harmony/README.md。

import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'HybridShell';
const DOMAIN: number = 0x1001;
const PORT_INIT_NAME: string = '__init_port__';
const PROXY_NAME: string = 'testObjName';

/**
 * 暴露给 H5 的原生能力。
 * W12：方法必须列进 registerJavaScriptProxy 的 methodList，不在列表里的前端调不到。
 * W13：注册对象对页面所有 frame 可见，将来加载三方页面时要用 javaScriptProxy 的 permission 收窄。
 */
class NativeBridge {
  echo(text: string): string {
    return `native echo: ${text}`;
  }

  deviceLabel(): string {
    return 'HarmonyOS HybridShell';
  }
}

/** 端口消息载体。R2：对象字面量必须有显式类型，不能直接 JSON.stringify 一个匿名字面量。 */
class PortPayload {
  from: string = '';
  at: number = 0;
}

@Entry
@Component
struct Index {
  webviewController: webview.WebviewController = new webview.WebviewController();
  bridge: NativeBridge = new NativeBridge();
  ports: webview.WebMessagePort[] = [];

  @State status: string = '等待页面加载';
  @State attached: boolean = false;
  @State proxyRegistered: boolean = false;
  @State portOpened: boolean = false;

  aboutToAppear(): void {
    // W16：setWebDebuggingAccess 是静态方法，须在 UI 线程调用；官方提示不要留到正式发布版本。
    try {
      webview.WebviewController.setWebDebuggingAccess(true);
    } catch (error) {
      this.report(`开启 DevTools 失败：${(error as BusinessError).message}`);
    }
  }

  aboutToDisappear(): void {
    this.closePort();
    this.unregisterProxy();
  }

  report(line: string): void {
    this.status = line;
    hilog.info(DOMAIN, TAG, '%{public}s', line);
  }

  /** W15：controller 的方法必须在绑定到 Web 组件之后才能调，否则抛 17100001。 */
  ready(): boolean {
    if (!this.attached) {
      this.report('controller 尚未绑定 Web 组件（W15），等页面加载完再点');
      return false;
    }
    return true;
  }

  // ---- 路径一：应用侧 → 前端页面 ----------------------------------------
  callH5(): void {
    if (!this.ready()) {
      return;
    }
    // R16：callback 与 Promise 两个重载二选一，这里用 Promise。
    this.webviewController.runJavaScript('htmlTest()')
      .then((result: string) => {
        // W10：前端返回的 string 被当作 JSON 数据，直接用会带引号，需要 JSON.parse。
        // 这里把两个值都打出来，方便实测时看清差异。
        let parsed: string = result;
        try {
          parsed = JSON.parse(result) as string;
        } catch (error) {
          hilog.warn(DOMAIN, TAG, 'W10 与预期不符：返回值不是合法 JSON');
        }
        this.report(`H5 原始返回 ${result} ／ JSON.parse 后 ${parsed}`);
      })
      .catch((error: BusinessError) => {
        this.report(`runJavaScript 失败：${error.code} ${error.message}`);
      });
  }

  // ---- 路径二：前端页面 → 应用侧 ----------------------------------------
  registerProxy(): void {
    if (!this.ready()) {
      return;
    }
    try {
      this.webviewController.registerJavaScriptProxy(
        this.bridge, PROXY_NAME, ['echo', 'deviceLabel']);
      // W4：注册后不会立即生效，必须等下次加载或显式 refresh()。
      this.webviewController.refresh();
      this.proxyRegistered = true;
      this.report(`已注册 ${PROXY_NAME} 并 refresh()`);
    } catch (error) {
      this.report(`注册失败：${(error as BusinessError).code}`);
    }
  }

  unregisterProxy(): void {
    if (!this.proxyRegistered) {
      return;
    }
    try {
      // W5：官方明写 registerJavaScriptProxy 必须配 deleteJavaScriptRegister，否则内存泄漏。
      this.webviewController.deleteJavaScriptRegister(PROXY_NAME);
      this.proxyRegistered = false;
      this.report(`已反注册 ${PROXY_NAME}`);
    } catch (error) {
      this.report(`反注册失败：${(error as BusinessError).code}`);
    }
  }

  // ---- 路径三：消息端口 --------------------------------------------------
  openPort(): void {
    if (!this.ready()) {
      return;
    }
    try {
      this.ports = this.webviewController.createWebMessagePorts();
      // W9：必须先注册 onMessageEvent 再发送，否则 postMessageEvent 抛 17100010。
      this.ports[1].onMessageEvent((result: webview.WebMessage) => {
        if (typeof result === 'string') {
          this.report(`端口收到字符串：${result}`);
        } else {
          this.report(`端口收到 ArrayBuffer，${(result as ArrayBuffer).byteLength} 字节`);
        }
      });
      // W2：controller.postMessage 是「把端口送给 H5」，不是发数据。
      this.webviewController.postMessage(PORT_INIT_NAME, [this.ports[0]], '*');
      this.portOpened = true;
      this.report('端口已建立并下发给 H5');
    } catch (error) {
      this.report(`建端口失败：${(error as BusinessError).code}`);
    }
  }

  sendToH5(): void {
    if (!this.portOpened || this.ports.length < 2) {
      this.report('端口未建立，先点「建端口」');
      return;
    }
    const payload: PortPayload = { from: 'native', at: Date.now() };
    try {
      // W1：ArkTS 侧是 postMessageEvent，写成 postMessage 是错的。
      // W3：基础协议只支持 string / ArrayBuffer，传对象必须先序列化，否则静默收不到。
      this.ports[1].postMessageEvent(JSON.stringify(payload));
      this.report('已通过端口发送 JSON 字符串');
    } catch (error) {
      this.report(`postMessageEvent 失败：${(error as BusinessError).code}`);
    }
  }

  closePort(): void {
    if (this.ports.length === 0) {
      return;
    }
    try {
      // docs/05 记的官方收尾动作是 close ports[0]。
      // ⚠️ 待核实：应用侧持有的 ports[1] 是否也需要显式 close，官方示例未写。
      this.ports[0].close();
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'close 失败 %{public}d', (error as BusinessError).code);
    }
    this.ports = [];
    this.portOpened = false;
    this.report('端口已关闭');
  }

  // R10：build() 内不声明本地变量、不用三元 / switch、不调用非 @Builder 方法。
  // R15：事件回调一律箭头函数。
  build() {
    Column({ space: 8 }) {
      Text('HybridShell 混合容器最小基座')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text(this.status)
        .fontSize(12)
        .fontColor('#666666')
        .width('100%')

      Row({ space: 6 }) {
        Button('调 H5 函数')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.callH5();
          })
        Button('注册对象')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.registerProxy();
          })
        Button('反注册')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.unregisterProxy();
          })
      }
      .width('100%')

      Row({ space: 6 }) {
        Button('建端口')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.openPort();
          })
        Button('端口发消息')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.sendToH5();
          })
        Button('关端口')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.closePort();
          })
      }
      .width('100%')

      // renderMode 不传即默认 RenderMode.ASYNC_RENDER。
      // W20：该模式下组件高度超 7,680px 物理像素会白屏，且两种模式都不支持动态切换。
      //      这里 Web 只占 Column 的剩余空间，不会触到阈值。
      Web({ src: $rawfile('index.html'), controller: this.webviewController })
        .javaScriptAccess(true)
        .fileAccess(true)
        .domStorageAccess(true)
        .onControllerAttached(() => {
          this.attached = true;
          this.report('controller 已绑定，可以调 WebviewController 方法了');
        })
        .onPageEnd(() => {
          // W11：runJavaScriptExt 必须等 loadUrl 完成后再调，官方举例就是放在 onPageEnd。
          this.report('页面加载完成');
        })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(12)
  }
}

