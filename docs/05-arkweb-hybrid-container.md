# ArkWeb 与混合容器

最后更新：2026-09-03 ｜ 全部代码片段**未编译验证**（工具链缺 Command Line Tools，见 `harmony/README.md`）

本项目主线方向的入口文档。讲清三件事：ArkWeb 是什么、原生与 H5 怎么互相调、本地 H5 资源怎么加载。

## 结论先行

| 问题 | 答案 | 出处 slug |
| --- | --- | --- |
| Kit 名 | `@kit.ArkWeb`，导入 `import { webview } from '@kit.ArkWeb'` | `web-in-app-frontend-page-function-invoking` |
| ArkWeb 与 `Web` 组件的关系 | ArkWeb（方舟Web）是能力总称，**它提供 `Web` 组件**用于显示网页内容 | `web-component-overview` |
| 内核 | **基于谷歌 Chromium 内核**，系统版本与 M 版本一一对应（见下表） | `web-component-overview` |
| 联网要权限 | `ohos.permission.INTERNET` | `web-component-overview` |
| 小程序容器 | 官方点名支持：小程序宿主应用可用 `Web` 组件渲染小程序页面，配合同层渲染、视频托管。**同层渲染页给了具体做法**：地图组件用 `XComponent`、输入框用 `TextInput` | `web-component-overview` · `web-same-layer` |
| **模拟器** | ✅ **本 Kit 支持模拟器** | `web-component-overview` |

最后一条对本项目意义很大：混合容器方向**不必等真机**（真机需实名认证 + AGC 签名）。
本机是 macOS ARM，模拟器支持的两个平台之一。这是从端侧 AI 转到混合容器的一个意外红利——
端侧 AI 的 K1–K12 陷阱全都只能在真机上验，混合容器的绝大部分能力在模拟器上就能跑。

## 内核版本对应（照抄官方表）

| 系统版本 | Chromium 版本 |
| --- | --- |
| HarmonyOS 4.0 及之前 | M99 |
| HarmonyOS 4.1 – 5.1 | M114 |
| HarmonyOS 6.0 | **M132**（默认、推荐）／ M114（可选，需按官方适配指导切换） |
| HarmonyOS 6.1 | M132 |
| HarmonyOS 7.0 | **M144**（默认、推荐）／ M132（可选） |

用途：判断某个 W3C / WebAssembly 特性能不能用，**查 Chromium 版本而不是查鸿蒙版本**。
官方也是这个口径——让开发者按内核版本去 MDN / webassembly.org 查支持情况。

结合现网分布（`docs/01`：2026-08-20 时 6.1.1(24) 占 84.93%）：**实际要兼容的主力内核是 M132**。

## ⚠️ 元服务不能用 `Web` 组件

官方原文：应用渲染网页需调用 ArkWeb 组件；**元服务内嵌网页渲染则需使用官方提供的 Webview 组件**，
按元服务开发框架选择 **ASCF Webview** 或 **AtomicServiceEnhancedWeb** 组件。

即：App 和元服务（原子化服务）在这件事上走的不是同一套组件。⚠️ 这两个组件本文未展开，待核实。

## 原生 ↔ H5 通信：三条路径，不是一条

这是混合容器的核心，也是最容易写错的地方。官方把它拆成**三个方向**，各有独立的接口族：

| 方向 | 接口 | 出处 slug |
| --- | --- | --- |
| 应用侧 → 前端页面 | `runJavaScript()` / `runJavaScriptExt()` | `web-in-app-frontend-page-function-invoking` |
| 前端页面 → 应用侧 | `javaScriptProxy()`（属性）／ `registerJavaScriptProxy()`（方法），配 `deleteJavaScriptRegister()` | `web-in-page-app-function-invoking` |
| 双向消息通道 | `createWebMessagePorts()` + 端口对 | `web-app-page-data-channel` |

**每条都另有一套 C/C++ NDK 版本**：`arkweb-ndk-jsbridge`、`arkweb-ndk-page-data-channel`。
⚠️ NDK 路线本文未展开，待核实。

### 路径一：应用侧调前端函数

`runJavaScript()` 只收 `string`；`runJavaScriptExt()` 收 `string` 和 `ArrayBuffer`。

```typescript
// 未编译验证。出处：web-in-app-frontend-page-function-invoking
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    webview.WebviewController.setWebDebuggingAccess(true);   // 静态方法，注意不是实例方法
  }

  build() {
    Column() {
      Button('调无参函数').onClick(() => {
        this.webviewController.runJavaScript('htmlTest()');
      })
      // 也可以直接把函数定义整段传过去
      Button('传代码').onClick(() => {
        this.webviewController.runJavaScript(
          `function changeColor(){document.getElementById('text').style.color='red'}`);
      })
      Web({ src: $rawfile('index.html'), controller: this.webviewController })
    }
  }
}
```

`$rawfile('index.html')` 对应 `entry/src/main/resources/rawfile/index.html`。

### 路径二：前端调应用侧函数（两种注册方式）

| 方式 | 用法 | 生效时机 |
| --- | --- | --- |
| `javaScriptProxy({...})` | 挂在 `Web` 组件上的**属性**，组件初始化时注册 | 随组件初始化 |
| `registerJavaScriptProxy(...)` | `WebviewController` 的**方法**，初始化完成后调 | **下次加载或 `refresh()` 之后才生效** |

两者都必须配 `deleteJavaScriptRegister()` 使用，**否则内存泄漏**（官方明写）。

```typescript
// 未编译验证。出处：web-in-page-app-function-invoking
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

class TestClass {
  test(): string { return 'ArkTS Hello World!'; }
}

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();
  @State testObj: TestClass = new TestClass();

  build() {
    Column() {
      Button('注册').onClick(() => {
        // 第三个参数是同步方法名白名单；不在 methodList 里的方法前端调不到
        this.webviewController.registerJavaScriptProxy(this.testObj, 'testObjName', ['test']);
        this.webviewController.refresh();   // ⚠️ 不 refresh 不生效
      })
      Button('反注册').onClick(() => {
        try {
          this.webviewController.deleteJavaScriptRegister('testObjName');
          this.webviewController.refresh();
        } catch (error) {
          console.error(`code: ${(error as BusinessError).code}, msg: ${(error as BusinessError).message}`);
        }
      })
      Web({ src: $rawfile('index.html'), controller: this.webviewController })
    }
  }
}
```

前端侧就用注册时的对象名直接调：`testObjName.test()`。

`javaScriptProxy` 属性写法的字段：`object` / `name` / `methodList` / `controller`，
可选 `asyncMethodList`、`permission`。`permission` 是一段 **JSON 字符串**（不是对象），
结构为 `{"javascriptProxyPermission":{"urlPermissionList":[...],"methodList":[{"methodName":...,"urlPermissionList":[...]}]}}`，
可按 scheme/host/port/path 限定哪些 URL 能调哪些方法。**混合容器加载三方页面时这是必要的隔离手段。**

### 路径三：消息端口（双向通道）

`createWebMessagePorts()` 一次创建**两个**端口：一个留在应用侧，另一个 `postMessage` 发给 H5。

```typescript
// 未编译验证。出处：web-app-page-data-channel
ports: webview.WebMessagePort[] = [];

// 1. 创建端口对
this.ports = this.controller.createWebMessagePorts();
// 2. 应用侧端口注册接收回调
this.ports[1].onMessageEvent((result: webview.WebMessage) => { /* string 或 ArrayBuffer */ });
// 3. 把另一个端口发给 H5（这里的 postMessage 是 controller 上的，不是端口上的）
this.controller.postMessage('__init_port__', [this.ports[0]], '*');
// 4. 应用侧发消息用端口
this.ports[1].postMessageEvent(this.sendFromEts);
// 5. 用完关闭
this.ports[0].close();
```

H5 侧监听 `window.addEventListener('message', ...)`，从 `event.ports[0]` 取端口后用
`h5Port.onmessage` / `h5Port.postMessage(data)`。

**三处最容易写错的地方（官方文档里就藏着）：**

1. **两侧方法名不对称。** ArkTS 端口用 `onMessageEvent` / `postMessageEvent`；
   H5 端口用 `onmessage` / `postMessage`。在 ArkTS 侧写 `port.postMessage(...)` 是错的。
2. **同一文件里有两个 `postMessage`。** `controller.postMessage(name, ports, uri)` 是「把端口送过去」，
   `port.postMessageEvent(data)` 才是「发数据」。混用不会报编译错，只是收不到。
3. **`WebMessage` 只支持 `string` 和 `ArrayBuffer`。** 传对象必须 `JSON.stringify`，
   官方 FAQ 把「H5 发消息应用侧收不到」的第一原因就归给这个。**静默失效，无报错。**

另一条官方 FAQ 顺带确认了时序：**`javaScriptOnDocumentStart` 在 `onControllerAttached` 之后执行。**

## 加载本地 H5：跨域是第一道坎

混合容器几乎一定要加载本地离线资源，而这里有个**默认拦死**的行为：

> ArkWeb 内核**禁止 `file` 协议和 `resource` 协议访问跨域请求**。

表现是 DevTools 控制台报：

```
Access to script at 'xxx' from origin 'xxx' has been blocked by CORS policy:
Cross origin requests are only supported for protocol schemes:
http, arkweb, data, chrome-extension, chrome, https, chrome-untrusted.
```

注意这个白名单里有 **`arkweb`** 这个自定义 scheme，但**没有 `file` 和 `resource`**。
所以「`$rawfile` 加载 index.html，里面 `<script src="./js/script.js">` 加载不出来」是预期行为，不是 bug。

官方给两条解法：

| 方法 | 做法 | 代价 |
| --- | --- | --- |
| 一 | 编一个自用域名（如 `https://www.example.com/`）替代 `file`/`resource`，用 `onInterceptRequest` 把请求映射回本地文件 | 要自己维护 URL→本地路径表和 mimeType 表 |
| 二 | `setPathAllowingUniversalAccess()` 设置允许跨域的路径白名单，之后用 `file` 协议访问 | 官方明说是**高风险操作** |

方法二的约束很硬，值得逐条记下：

- 一旦设置了路径列表，**`file` 协议就只能访问列表内的资源**，`fileAccess` 的行为被此接口覆盖。
- 路径必须落在这几类目录下（el1/el2 放开的路径是固定的）：
  `Context.filesDir`、`Context.resourceDir`，**从 API version 21 起**还包括 `Context.cacheDir` 与 `Context.tempDir`。
- 路径里**不允许包含 `cache/web`**，否则抛异常码 **401**；设成 `cache` 时 `cache/web` 同样不可访问。
- 任一路径不满足条件 → 抛 **401**，整个列表设置失败。
- 列表设为空 → 回落到 `fileAccess` 规则。

方法一的骨架（`schemeMap` 映射 URL 到 rawfile 相对路径，`mimeTypeMap` 给出 MIME）：

```typescript
// 未编译验证。出处：web-cross-origin
Web({ src: 'https://www.example.com/index.html', controller: this.webviewController })
  .javaScriptAccess(true)
  .fileAccess(true)
  .domStorageAccess(true)
  .onInterceptRequest((event) => {
    if (!event) { return; }
    if (this.schemeMap.has(event.request.getRequestUrl())) { /* 构造本地响应返回 */ }
    return null;   // 不拦截
  })
```

## 拦截：两套机制，别混

| 机制 | 接口 | 能力 | 限制 |
| --- | --- | --- | --- |
| `onInterceptRequest` | `Web` 组件事件 | 拦截并自定义响应，配 `WebResourceResponse` 构造返回 | ⚠️ **拿不到 Post Data** |
| `SchemeHandler` | 提供 **ArkTS 与 NDK 两套接口** | 可拦截 `Web` 组件**及 ServiceWorker** 发出的 HTTP(s) 与自定义协议请求；能拿到 Post Data | 有请求开始/结束两个回调，**必须在结束回调里清理资源，否则内存泄漏** |

选择依据很清楚：**只做离线包映射用 `onInterceptRequest`；需要读 POST 体或要覆盖 ServiceWorker 就上 `SchemeHandler`。**

出处：`web-scheme-handler`（两者对比与 SchemeHandler 细节）、`web-resource-interception-request-mgmt`（`onInterceptRequest` 用法）。

## 渲染模式：两种，且**不能动态切换**

`Web` 组件的 `renderMode` 参数（构造参数，不是属性）只有两个值，选错的代价是白屏。

| 模式 | 图形节点 | 高度上限（物理像素） | 适用 |
| --- | --- | --- | --- |
| `RenderMode.ASYNC_RENDER`（**默认**） | surface 节点，独立送显 | **7,680px，超过白屏** | 整页就是一个 Web，H5 内部自己出滚动条 |
| `RenderMode.SYNC_RENDER` | canvas 节点，跟系统组件一起送显 | **500,000px** | Web 只是页面的一段富文本，外层用 `Scroll` 统一滚动，Web 内部不出滚动条 |

- **两者都不支持动态切换。** 建组件时就得定。
- `SYNC_RENDER` 不支持 DSS（显示子系统）合成，性能开销更高。
- 判据很直接：**Web 内部是否允许出现滚动条。** 允许 → 异步；不允许（要与 ArkUI 组件协同滚动）→ 同步。

出处：`web-render-mode`。

## 同层渲染：小程序容器的关键能力

官方在这一页里第一次把「小程序」写成具体做法：**小程序的地图组件用 ArkUI `XComponent` 渲染以提升性能，
输入框组件用 `TextInput` 渲染以获得与系统一致的输入体验。** 这是「小程序容器」目前能找到的最实的落点。

原理：把 H5 里的 `<embed>` / `<object>`（**同层标签**）交给 ArkUI 组件渲染，
经 `NodeContainer` + `NodeController` + `BuilderNode` 挂到同一图层，而不是用 `Stack` 按 Z 轴堆叠。

### 开启与标签规则

```typescript
// 未编译验证。出处：web-same-layer
Web({ src: $rawfile('text.html'), controller: this.controller })
  .enableNativeEmbedMode(true)              // ⚠️ 默认关闭，不开就显示「该插件不支持」
  .registerNativeEmbedRule('object', 'test') // 用 <object> 时必须注册；用 <embed> 且 type 以 native/ 开头可省
```

```html
<!-- 默认规则下：标签写 embed，type 以 native/ 开头 -->
<embed id="input1" type="native/view" style="width:100%; height:100px"/>
```

- 不调 `registerNativeEmbedRule` 或传空串 → 回落默认 `"embed"` + `"native/"` 前缀模式。
- **tag 全字符串匹配，type 前缀匹配**，两者都不区分大小写（内核统一转小写）。
- ⚠️ **指定的类型若与 W3C 标准类型重合**（官方举例 `registerNativeEmbedRule("object", "application/pdf")`），
  ArkWeb 遵循 W3C 标准行为，**不会**识别成同层标签。
- ⚠️ 不能把 W3C 标准标签（`<input>`、`<video>`）定义为同层标签；
  也**不能同时**把 `<embed>` 和 `<object>` 都配成同层标签。

### 四个上报回调

| 回调 | 时机 |
| --- | --- |
| `onNativeEmbedLifecycleChange()` | 同层标签创建 / 销毁 / 位置宽高变化；支持进入前进后退缓存 |
| `onNativeEmbedGestureEvent()` | 触摸事件命中同层标签；配 `setGestureEventResult()` 定消费方，**默认应用侧消费** |
| `onNativeEmbedVisibilityChange()` | 相对视口的可见状态变化；**默认不上报**因 CSS 样式/尺寸变化引起的可见性变化 |
| `onNativeEmbedObjectParamChange()` | `<object>` 内嵌 `param` 的增/改/删；**单次最多 500 条**，超出分多次上报 |

事件要同时给两侧消费：`setGestureEventResult()` 里把 `stopPropagation` 设为 `false`，
系统组件侧消费的同时冒泡给 ArkWeb。

### 规格约束（踩中就是视觉 bug，不是编译错）

- 同层标签数量**每页 ≤ 5 个**，超过渲染性能下降。
- 受 GPU 限制，同层标签**最大高度 8,000px、最大纹理 8,000px**，超了组件被拉伸。
- **开启同层渲染后，该 `Web` 组件打开的所有页面都不支持 `RenderMode.SYNC_RENDER`。**
  即「同层渲染」与「超长页面同步渲染」二者不可兼得。
- 自定义同层组件**最外层容器的宽高必须等于同层标签的宽高**，否则被拉伸。
- 交互型组件（`TextInput`/`TextArea` 等）：用 `Stack` 包裹同层组件容器与 `BuilderNode`，
  且 `NodeContainer` 的 `position`/`width`/`height` 与标签绑定。否则文本选择框错位、
  `LoadingProgress`/`Marquee` 的动画启停与可见状态不匹配。
- CSS 只支持一个子集（`display`/`position`/`z-index`/盒模型/边框/圆角/`transition`/`transform` 等）；
  **`transform` 只支持 `translate` 与 `scale`（scale 参数须 ≥ 0）**，`rotate`、`skew` 不保证符合预期。
- 有同层标签的页面**不支持缩放**：`initialScale`、`zoom`、`zoomIn`、`zoomOut` 都不支持。
- 暂不支持鼠标、键盘、触摸板事件上报；鼠标/触摸板左键默认转成 Touch 事件上报。
- `Web` 组件本身也可同层渲染，但**仅支持一层嵌套**，事件只支持滑动、点击、长按。

可同层渲染的 ArkUI 组件范围很宽（基础 + 容器 + 自绘制 `XComponent`/`Canvas`/`Video`/`Web`
+ 命令式节点 `BuilderNode`/`FrameNode`/`RenderNode` 等）；**不支持的通用属性只有两个**：
分布式迁移标识、特效绘制合并。

### 为什么值得用而不是 `Stack` 堆叠

官方给了 Trace 实测对比（`same-layer-rendering-native-component`）：

| 场景 | 非同层（`Stack` 堆叠） | 同层渲染 |
| --- | --- | --- |
| 列表滑动，单帧 `ReceiveVsync` 渲染耗时 | **5ms** | **1ms** |
| 首次加载 | 图片加载被推迟到原生组件加载完成之后；`render_service` 每帧耗时大幅上升 | 图片加载提前；`render_service` 每帧耗时无明显变化 |

选型判据：原生组件**大小位置固定** → `Stack` 堆叠够用且实现简单；
需要**跟随 H5 页面变化** → 上同层渲染。

出处：`web-same-layer`、`same-layer-rendering-native-component`。

## 「离线 Web 组件」= 离屏预创建，**不是离线包**

⚠️ 名字有歧义，此前本文把它列为待读时特意标注过。读完确认：
`web-offline-mode` 讲的是**用 `NodeContainer` 承载、命令式创建但先不挂树的 Web 组件**，
用途是性能优化（预启动渲染进程、预渲染页面），与「H5 离线资源包」毫无关系。
离线包相关的能力在 `web-cross-origin` / `web-scheme-handler` 那条线上。

创建后组件状态是 **Hidden + Inactive**，不呈现给用户；需要时通过 `NodeController` 挂到 `NodeContainer`。

| 用法 | 做法 | 收益前提 |
| --- | --- | --- |
| 预启动渲染进程 | 提前建一个加载 `about:blank` 的空 Web 组件 | ⚠️ **仅在单渲染进程模式下收益显著**；渲染进程只有在**所有** Web 组件都销毁后才终止，故建议至少保持一个活着 |
| 预渲染页面 | 提前建组件并置为 Active 后台渲染 | 适用于**高命中率**的跳转目标页 |

预渲染的正确写法（关键是**渲染完要立刻停**）：

```typescript
// 未编译验证。出处：web-offline-mode
Web({ src: data.url, controller: data.controller })
  .onPageBegin(() => { data.controller.onActive(); })        // 开启渲染
  .onFirstMeaningfulPaint(() => {
    if (!shouldInactive) { return; }
    data.controller.onInactive();                            // 预渲染完成，停止渲染
    shouldInactive = false;
  })
```

- ⚠️ **每个 `Web` 组件约占 200MB 内存**（官方数字），别一次建一堆。
- ⚠️ 官方建议**每个窗口只用一个 `Web` 组件**，靠复用而不是多开。
- ⚠️ 不要预渲染**自动播放音视频**的页面。
- ⚠️ `onFirstMeaningfulPaint` **只适用 http/https 页面**——这条对本地 `$rawfile` 场景直接不可用。
- 不停 `onInactive()` 会在后台持续渲染，官方点名会**发热与功耗**问题。

复用与释放：

- **复用**：不用时 `loadUrl('about:blank')` 腾出来，下个页面再 `loadUrl(真实 url)`。
- **释放**：⚠️ **只有未绑定 `NodeContainer` 时才能释放**，否则对应的 `NodeContainer` 白屏。
  绑定状态用 `NodeController` 的 `onBind` / `onUnbind` 回调跟踪，示例里包了个 `isBound()`；
  释放动作是 `rootNode?.dispose()` + `rebuild()`。
- 官方示例的做法：`UIAbility` 的 `onBackground` 里回收、`onForeground` 里恢复。

白屏三步排查（官方给的顺序）：① `module.json5` 是否声明 `ohos.permission.INTERNET`；
② `NodeContainer` 与节点的绑定逻辑（在 `Web` 上方临时加一个 `Text` 探测节点是否上树）；
③ 看 `WebPattern::OnVisibleAreaChange` 日志确认可见性。

出处：`web-offline-mode`。

## 进程模型：五种进程，默认策略随设备变

| 进程 | 作用域 | 职责 |
| --- | --- | --- |
| 应用进程 | 应用唯一（主进程） | Web 对外接口与回调、网络/媒体等需要与系统服务交互的部分 |
| Foundation 进程 | 系统唯一 | 接收孵化请求，管理应用进程与渲染进程的绑定关系 |
| Web 孵化进程 | 系统唯一 | 孵化渲染进程与 GPU 进程，孵化后做沙箱降权、预加载 so |
| Web 渲染进程 | **可共享或独立** | HTML 解析/排版/绘制 + JS 与 WebAssembly 执行 |
| Web GPU 进程 | 应用唯一 | 光栅化、合成送显 |

- ⚠️ 官方明写：**Web 内核对内存大小的申请无限制约束。** 配合「每组件约 200MB」一起看。
- **默认策略随设备不同**：移动设备**共享**渲染进程（省内存），2in1 设备**独立**渲染进程（安全与稳定）。
- `webview.WebviewController.setRenderProcessMode()` / `getRenderProcessMode()` 是**静态方法**，
  枚举 `0 = 单进程`、`1 = 多进程`。⚠️ **传入不在 `RenderProcessMode` 枚举范围内的值 → 自动按多进程处理**，
  不是回落到单进程。
- `terminateRenderProcess()` 主动关渲染进程；⚠️ **会影响共享该进程的所有其他实例**。
  进程未启动或已销毁时调用无影响。
- 监听：`onRenderExited`（拿 `renderExitReason`，区分 OOM / crash / 正常退出，
  ⚠️ 共享进程时**每个受影响的 Web 组件都会各触发一次**）、
  `onRenderProcessNotResponding`（无响应期间**可能反复触发**，带 `jsStack`/`pid`/`reason`）、
  `onRenderProcessResponding`。
- `sharedRenderProcessToken` 是 **`Web` 组件的构造参数**：多渲染进程模式下同 token 的组件优先复用同一渲染进程；
  绑定在渲染进程初始化时形成，进程不再关联任何组件时解绑。

出处：`web_component_process`。

## 起始版本（查的是 API 参考，不是指南）

指南页几乎不写版本，**必须查 `harmonyos-references` 的 `@ohos.web.webview`**。
模块描述页原话：「本模块**首批接口从 API version 9 开始支持**。后续版本如有新增内容，
则采用上角标单独标记该内容的起始版本。」

即：**API 参考页标题上没有上角标的方法 = API 9**。

| 接口 | 起始版本 | 备注 |
| --- | --- | --- |
| `runJavaScript(script, callback)` / Promise 重载 | 9 | |
| `runJavaScriptExt(script, ...)` | **10** | ⚠️ 但 `script` 收 `ArrayBuffer` 是**从 12 起**（参数表上角标 `ArrayBuffer12+`） |
| `registerJavaScriptProxy` | 9 | |
| `deleteJavaScriptRegister` | 9 | |
| `createWebMessagePorts()` | 9 | 参数 `isExtentionType` 是**从 10 起** |
| `postMessage(name, ports, uri)` | 9 | |
| `WebMessagePort.postMessageEvent` / `onMessageEvent` | 9 | 基础协议，载体 `WebMessage` |
| `WebMessagePort.postMessageEventExt` / `onMessageEventExt` | **10** | 扩展协议，载体 `WebMessageExt`，支持更丰富的数据类型 |
| `WebMessagePort.close()` | 9 | |
| `refresh()` | 9 | |
| `refresh(ignoreCache: boolean)` | **24** | 可选择忽略缓存刷新 |
| `setPathAllowingUniversalAccess(pathList)` | **12** | ⚠️ 支持 `cacheDir` / `tempDir` 是**从 21 起**（见指南页） |
| `setWebDebuggingAccess(access)` | 9 | 静态方法 |
| `setWebDebuggingAccess(access, port)` | **20** | 无线调试；`port` 必须 **> 1024**，否则抛异常 |

模块信息：`import { webview } from '@kit.ArkWeb'`，系统能力 `SystemCapability.Web.Webview.Core`，
访问在线网页需 `ohos.permission.INTERNET`。**静态方法必须在 UI 线程上使用。**

常见错误码（`Webview错误码`）：

| 码 | 含义 |
| --- | --- |
| 17100001 | `The WebviewController must be associated with a Web component.` —— controller 没绑到 `Web` 组件就调方法 |
| 17100006 | 端口注册消息事件失败 |
| 17100010 | 通过端口发送消息失败 |
| 401 | 参数错误（必填缺失 / 类型错 / 校验失败），`setPathAllowingUniversalAccess` 路径不合规也是这个 |

## 官方文档地图

用 `python3 tools/hwdoc.py doc <slug>` 取正文。catalog 均为 `harmonyos-guides`，根节点 `[arkweb]`。

| 主题 | slug |
| --- | --- |
| 简介（内核版本表、权限、模拟器） | `web-component-overview` |
| 进程模型 | `web_component_process` |
| 生命周期 | `web-event-sequence` |
| 术语 | `arkweb-glossary` |
| **应用侧调前端** | `web-in-app-frontend-page-function-invoking` |
| **前端调应用侧** | `web-in-page-app-function-invoking` |
| **数据通道** | `web-app-page-data-channel` |
| 通信的 C/C++ 版 | `arkweb-ndk-jsbridge` · `arkweb-ndk-page-data-channel` |
| **本地资源跨域** | `web-cross-origin` |
| **拦截网络请求（SchemeHandler）** | `web-scheme-handler` |
| **自定义页面请求响应** | `web-resource-interception-request-mgmt` |
| 拦截能力总览 | `web-component-intercept-capab-usage` |
| 加载页面 | `web-page-loading-with-web-components` |
| 加速访问（预加载/预连接） | `web-predictor` |
| 前进后退缓存 | `web-set-back-forward-cache` |
| **离线 Web 组件** | `web-offline-mode` |
| 渲染模式 | `web-render-mode` |
| 大小自适应内容 | `web-fit-content` |
| **同层渲染** | `web-same-layer` · `same-layer-rendering-native-component` |
| Cookie 与数据存储 | `web-cookie-and-data-storage-mgmt` |
| User-Agent | `web-default-useragent` |
| 深色模式 | `web-set-dark-mode` |
| 软键盘对接 | `web-docking-softkeyboard` |
| 嵌套滚动 | `web-nested-scrolling` |
| 手势交互 | `web-gesture` |
| 坚盾守护模式 | `web-secure-shield-mode` |
| 广告过滤 | `web-adsblock` |
| 无痕模式 | `web-incognito-mode` |
| DevTools 调试 | `web-debugging-with-devtools` |
| 白屏定位 | `web-white-screen` |
| 崩溃信息收集 | `web-crashpad` |
| 自动化测试（Hypium） | `web-hypium-autotests` |
| 浏览器扩展通信 | `web-native-messaging` |

## 未确认

- ⚠️ **所有代码片段未编译验证。** Command Line Tools 未到位，见 `harmony/README.md`。
- ✅ 起始版本已从 `harmonyos-references` 的 `@ohos.web.webview` 补齐（见「起始版本」一节，2026-09-02）。
  仍未查的是 `Web` **组件属性/事件**（`onInterceptRequest`、`javaScriptProxy`、`fileAccess` 等）的起始版本
  —— 那些在**组件描述**页而非 webview 模块页，⚠️ 待查。
- ⚠️ `webview.WebviewController` 与裸写 `WebviewController`：`web-cross-origin` 方法二、
  `web-offline-mode`（`class Data` 与 `initWeb` 形参，多处）、`web-render-mode` 示例里都出现了
  不带 `webview.` 前缀的 `WebviewController` 类型标注。**已在 4 个独立页面见到**，
  基本可以排除单页笔误，大概率是全局可见的类型；但**仍未在 API 参考/组件描述页找到明确声明**，暂按待核实处理。
  写代码时统一用 `webview.WebviewController` 更安全。
- ⚠️ 元服务的 **ASCF Webview** / **AtomicServiceEnhancedWeb** 两个组件未展开。
- ✅ `web-offline-mode` 已读完（2026-09-03）。确认「离线 Web 组件」**不是**「离线包」，
  是离屏预创建的 Web 组件，见「离线 Web 组件」一节。
- ✅ 同层渲染（`web-same-layer` + `same-layer-rendering-native-component`）、
  渲染模式（`web-render-mode`）、进程模型（`web_component_process`）已读完（2026-09-03）。
- 🔶 「小程序容器」：简介页只点了场景，但同层渲染页给出了具体组件替换做法（地图→`XComponent`、
  输入框→`TextInput`）。**仍未找到成套的「小程序容器」文档或 Kit**，判断是「用 ArkWeb + 同层渲染自己搭」，
  而非官方提供现成容器。⚠️ 待进一步确认。
- ⚠️ 模拟器支持写的是「支持，与真机存在通用差异」，**具体哪些 Web 能力在模拟器上不可用未确认**。
  另注意 `arkts-apis-webview` 模块页写「示例效果请**以真机运行为准**」，两处口径需留意。
- ⚠️ 本节新增能力的**起始版本全未查**：`renderMode`、`enableNativeEmbedMode`、
  `registerNativeEmbedRule`、`onNativeEmbed*` 四个回调、`sharedRenderProcessToken` 在**组件描述**页；
  `setRenderProcessMode` / `getRenderProcessMode` / `terminateRenderProcess` / `onActive` / `onInactive`
  在 webview 模块页但本轮未查。

## 来源

全部来自 `developer.huawei.com` 官方文档中心，catalog `harmonyos-guides`，
访问日期 **2026-09-02**（前 7 篇）与 **2026-09-03**（渲染模式、同层渲染 ×2、离线组件、进程模型 5 篇），
抓取方式 `tools/hwdoc.py doc <slug>`（文档中心是 Angular SPA，见 `docs/00-doc-retrieval.md`）。
URL 拼法：`https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/<slug>`。

本文引用的页面（含页面自报的更新时间）：

| slug | 官方更新时间 |
| --- | --- |
| `web-component-overview` | 2026-06-12 |
| `web-in-app-frontend-page-function-invoking` | 2026-08-29 |
| `web-in-page-app-function-invoking` | 2026-08-29 |
| `web-app-page-data-channel` | 2026-03-09 |
| `web-cross-origin` | 2026-08-29 |
| `web-scheme-handler` | 2026-08-29 |
| `web-resource-interception-request-mgmt` | 2026-08-29 |
| `web-render-mode` | 2026-08-29 |
| `web-same-layer` | 2026-08-29 |
| `same-layer-rendering-native-component` | **2026-08-18** |
| `web-offline-mode` | 2026-08-29 |
| `web_component_process` | 2026-08-29 |

API 参考（catalog `harmonyos-references`，同日访问）：

| slug | 内容 |
| --- | --- |
| `arkts-apis-webview` | 模块描述：首批接口 API 9、导入模块、权限、系统能力 |
| `arkts-apis-webview-webviewcontroller` | `WebviewController` 全部方法与起始版本（14000+ 行） |
| `arkts-apis-webview-webmessageport` | `WebMessagePort`：基础协议与 Ext 协议、错误码 |

目录树里还有约 40 个未读的类/接口页（`WebSchemeHandler`、`WebResourceHandler`、`ProxyController`、
`WebMessageExt`、`AIPageCommand` 等），入口 slug 是 `js-apis-webview`。

可信度 A（官方一手）。目录树来自 `hwdoc.py tree harmonyos-guides ArkWeb`。






