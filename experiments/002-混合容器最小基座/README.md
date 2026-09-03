# 实验：混合容器最小基座能否在模拟器上跑通原生 ↔ H5 双向通信

- 日期：2026-09-02（2026-09-03 更新范围）
- 状态：设计中（阻塞：等 Command Line Tools 就位，见 `harmony/README.md`）
- 相关文档：`docs/05-arkweb-hybrid-container.md`、`docs/03-arkts-codegen-rules.md`（W1–W27）

## 假设

**在只有 CLT（无 DevEco Studio）的 macOS ARM 上，可以创建一个混合容器工程，
加载本地 rawfile 里的 H5 页面，并在模拟器上跑通三条通信路径与本地资源加载。**

可证伪点分四个，任一失败都能独立给出结论：

1. `devecocli create` + `devecocli build` 出不了 HAP → 退回 `experiments/001` 的结论。
2. HAP 装不进模拟器（CLT-only 模式下 `emulator` / `hdc` 不可用）→ 「模拟器需要 Studio」成立。
3. `Web` 组件加载 `$rawfile` 的 H5 失败 → 混合容器最小形态就不成立。
4. 三条通信路径任一跑不通 → 对应的 W 规则要改写。

## 为什么关心

这是本项目从「读文档」跨到「真能跑」的第一个真实交付物，也是主线方向的地基。

关键前提来自 `web-component-overview`：**ArkWeb 明确支持模拟器**。
这跟第一轮的端侧 AI 完全不同——K1–K12 全都只能真机验（要实名认证 + AGC 签名），
所以那些陷阱至今只有文档依据。而 W1–W16 **应该是可以被实测的**。这个实验就是去兑现这一点。

若假设成立：`docs/03` 的 W1–W16 从「官方文档依据」升级为「实测验证」，
`docs/05` 的代码片段可以逐条摘掉「未编译验证」标注，`harmony/` 有真实工程。

## 方法

分步做，前一步失败就不做后一步。

| 步 | 动作 | 怎么算成功 |
| --- | --- | --- |
| 0 | `source harmony/env.sh` 后 `devecocli create --app-name HybridShell --project-path harmony/HybridShell` | 生成官方模板的 25 个文件 |
| 1 | 不改任何代码直接 `devecocli build` | 产物里出现 `.hap` |
| 2 | 在 `entry/src/main/resources/rawfile/` 放一个最小 `index.html`，`Index.ets` 换成 `Web({ src: $rawfile('index.html'), controller })`，加 `ohos.permission.INTERNET`，再 build | 编译通过 |
| 3 | 起模拟器，装 HAP，看页面是否渲染 | H5 内容显示出来 |
| 4 | 验 W6：`index.html` 里 `<script src="./js/script.js">`，看是否被 CORS 拦 | **拦掉才算符合预期**；报错文本与 `web-cross-origin` 记录的是否一致 |
| 5 | 验路径一：按钮调 `runJavaScript('htmlTest()')` | 页面元素变色 |
| 6 | 验路径二：`registerJavaScriptProxy` + `refresh()`，前端调 `testObjName.test()`；并验 W4（不 `refresh()` 是否真的不生效） | 拿到返回值；且不 refresh 时确实调不到 |
| 7 | 验路径三与 W1/W2/W3：端口通道跑通；再故意传一个对象（不 `JSON.stringify`）看是否静默失败 | 正常路径收到消息；异常路径**无报错且收不到** |
| 8 | 打开 DevTools（`setWebDebuggingAccess(true)`）确认调试通道可用 | 能看到控制台输出 |

**范围说明（2026-09-03）：** W 系列已涨到 27 条，但本实验**只验 W1–W16 的通信与资源加载部分**。
W17–W23（同层渲染、渲染模式）与 W24–W27（离线 Web 组件、进程模型）另立实验，理由：

- 同层渲染要写 `NodeController` / `BuilderNode` 一整套，和「最小基座」不是一个粒度。
- W20 的 7,680px 白屏阈值要构造超长页面，是独立的可证伪点。
- W25 已发现一条与本实验直接冲突的限制：**`onFirstMeaningfulPaint` 只适用 http/https 页面**，
  而本实验走 `$rawfile`，拿不到预渲染的停止时机。所以预渲染这套在最小基座里本来就用不上。

需要的环境：CLT ≥ 26.0.0、JDK 21（已就位）、模拟器（macOS ARM 支持）。
API 版本按现网主力取，对应内核 M132（见 `docs/05` 内核版本表）。

⚠️ 步 3 起是否需要华为账号登录（模拟器镜像下载、签名）**未确认**，这可能是第二个人工卡点。

## 过程

（未开始，等 CLT）

## 结论

（待）

## 遗留

- 模拟器镜像获取是否也要华为账号登录，未确认。若要，这个实验会和 `001` 卡在同一处。
- CLT-only 模式下 `devecocli emulator` / `hdc` 是否可用，未确认（`001` 步 2 只核对了 `create`/`build` 无 Studio 硬依赖）。
- 本实验只验最小闭环。同层渲染、离线 Web 组件、SchemeHandler 另立实验。
