/**
 * 插队 spike（M1 之后、M2 之前，一次性）
 *
 * pro 的 开工.md 排的是「M1 一过立刻插队，在 M1 的壳子里加一个 WebView 加几行打印，不另起临时工程」。
 * 鸿蒙侧两条：① ArkWeb 在模拟器上起不起得来，顺带 resource:// 的 origin 与子资源；② data: iframe。
 * 要试什么、怎么算答上了，在 pro 的 M2 / M3「要试出来的」，这里不复述；落点在本仓 TASKS.md。
 *
 * 故意**不**做的：不经 onInterceptRequest、不注入、不设 UA、不开 domStorage——
 * 这一跑要看的就是 $rawfile 直接落在 resource:// 上的原样表现。承载、配置、注入从 M2 / M3 正式写。
 *
 * 观察面两处：页面上逐行显示（截图）＋ hilog（命令行回读）：
 *   hdc shell hilog -x -T CrabSpike
 * 页面侧 `SPIKE <key> <value>` 经 onConsole 转进来；原生侧 `NATIVE <事件> ...` 是加载回调，
 * 用来区分「页面没起来」「主文档起来了但子资源被拦」「白屏但无错误回调」三种情形。
 */
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'CrabSpike';

function log(line: string): void {
  hilog.info(DOMAIN, TAG, '%{public}s', line);
}

@Entry
@Component
struct Index {
  private readonly controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Text('螃蟹 · Crab · ArkWeb spike')
        .id('CrabSpikeTitle')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .padding(12)
      // $rawfile 在运行期就是 resource://rawfile/...；页面里的相对路径子资源因此也落在 resource:// 上
      Web({ src: $rawfile('spike/index.html'), controller: this.controller })
        .id('CrabSpikeWeb')
        .javaScriptAccess(true)
        .layoutWeight(1)
        .width('100%')
        .onControllerAttached(() => {
          log('NATIVE attached');
        })
        .onPageBegin((event) => {
          if (event) {
            log(`NATIVE page-begin ${event.url}`);
          }
        })
        .onPageEnd((event) => {
          if (event) {
            log(`NATIVE page-end ${event.url}`);
          }
        })
        // 主资源与子资源出错都回调；子资源被 CORS 拦掉时若有回调，就落在这里
        .onErrorReceive((event) => {
          if (event) {
            log(`NATIVE error main=${event.request.isMainFrame()} code=${event.error.getErrorCode()} ` +
              `info=${event.error.getErrorInfo()} url=${event.request.getRequestUrl()}`);
          }
        })
        .onHttpErrorReceive((event) => {
          if (event) {
            log(`NATIVE http-error main=${event.request.isMainFrame()} ` +
              `status=${event.response.getResponseCode()} url=${event.request.getRequestUrl()}`);
          }
        })
        .onRenderExited((event) => {
          if (event) {
            log(`NATIVE render-exited reason=${event.renderExitReason}`);
          }
        })
        .onConsole((event) => {
          if (event) {
            log(event.message.getMessage());
          }
          // false：照常也进 ArkWeb 自己那条 hilog，多一份对照
          return false;
        })
    }
    .width('100%')
    .height('100%')
  }
}
