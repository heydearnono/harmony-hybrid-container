# 实验：混合容器最小基座能否在模拟器上跑通原生 ↔ H5 双向通信

- 日期：2026-09-02（2026-09-03 两次更新：落地工程骨架、打通编译）
- 状态：**进行中，步 0–2 达成，步 3 起阻塞**（缺 OpenHarmony 设备/模拟器）
- 产物：`harmony/HybridShell/` + `entry-default-unsigned.hap`（110,930 B）
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
`docs/05` 的代码片段可以把「未编译验证」改写为更准确的状态，`harmony/` 有真实工程。
（2026-09-03 修正：只有落进工程且被编译器**正面**检验的规则才算，W1 是目前唯一一条；
运行期语义要等步 3 起。）

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

2026-09-03 分两轮：上午落地工程骨架（步 0），下午打通编译（步 1、步 2 判据达成）。逐步实况：

| 步 | 结果 | 证据 |
| --- | --- | --- |
| 0 `create` | ✅ **达成**（用了桩） | 30 个文件落在 `harmony/HybridShell/`，CLI 自报 `Template integrity check passed.` |
| 1 不改代码 `build` | ✅ **达成**（走免登录 OpenHarmony 链） | `BUILD SUCCESSFUL in 3 s 109 ms`，产物 `entry/build/default/outputs/default/entry-default-unsigned.hap` |
| 2 写混合容器代码后 build | ✅ **达成** | `Finished :entry:default@CompileArkTS... after 2 s 91 ms`；HAP 内含 `ets/modules.abc` 31,560 B + `resources/rawfile/index.html` + `probe.js` |
| 3–8 | ⛔ 未开始 | 本机无 OpenHarmony 设备/模拟器，`hdc` 在 `sdk/23/toolchains/hdc`（存在）但无目标可连 |

⚠️ **步 1/2 的达成有限定**：编译走的是 OpenHarmony API 23 SDK，**不是 HarmonyOS SDK**，
产物是 OpenHarmony HAP。可证伪点 1 的原始表述（「出不了 HAP → 退回 001 的结论」）
在 OpenHarmony 侧**被推翻**（出得来），在 HarmonyOS 侧**仍未检验**。

### 步 0 的关键发现：`create` 不需要 SDK

`devecocli create` 只做参数校验 + 模板变量替换，**完全不碰 SDK**。
唯一门禁是 `DEVECO_CLI_CLT_PATH` 目录下有个可解析的 `version.txt`（正则 `/^#\s*Version:\s*(\S+)/`）。
所以用一个只含 `version.txt` 的桩目录 `~/.local/hmos-toolchain/clt-stub/` 就把骨架拿到了。
**产物是官方模板的原样输出，不是手搓。** 做法与边界记在 `harmony/README.md`。

顺带两条修正：

- **API level 上限是 23**。`--api-level 24` 被拒：`Invalid API version 24. Your SDK supports API version 17-23`。
  读 `dist/cli.js` 的 `RI()`：下限硬编码 17，上限取 `getMaxApiLevel()`，取不到回落硬编码 23。
  `create` 生成的原值是 `"6.1.0(23)"`；下午为走 OpenHarmony 链又改成整数 `23`（三个字段 + 新增
  `compileSdkVersion`，原值留在文件注释里）。而现网主力是 6.1.1(24) —— 真 CLT 到位后要重判。
- 模板的 `modelVersion`：CLI 包内模板文件磁盘上是 **`6.0.2`**，`create` 落盘时替换成 **`6.1.0`**
  （工程里是 6.1.0）。`harmony/README.md` 此前两种写法都不够准确，已改。

### 步 1 是怎么从失败翻到达成的

上午用桩 CLT 时，`build` 稳定失败在 ohpm：

```
[ohpm install] Running...
Command failed with ENOENT: <CLT>/tool/node/bin/node <CLT>/ohpm/bin/pm-cli.js install --all
```

即 CLT 里必须真有 `tool/node/bin/node` 和 `ohpm/bin/pm-cli.js` —— **桩能过 `create` 过不了 `build`，
是设计边界不是配置问题**。下午这两个洞由**免登录的 OpenHarmony 链**填上：
hvigor 6.26.1 的 `command-line-tools.zip`（公开直链，对过官方 sha256）解开就是 `$CLT` 期望的树，
`sdk/` 与 `tool/node/` 是空占位，分别填入 OpenHarmony SDK 23 五组件与 Node 22.14.0。

登录门禁**只挡 HarmonyOS SDK 本体**，hvigor / ohpm / OpenHarmony SDK 全是公开直链。
装法、五个报错原文、1,255 MB 的体积代价见 `research-log/2026-09-03-免登录编译打通.md`
与 `harmony/README.md` 的「另一条路」。

### 步 2 写了什么

代码按 `docs/05` 的三条路径 + `docs/03` 的 W1–W16 逐条落地，注释里标了对应规则编号，
这样将来编译/运行报错时能直接对回规则：

| 位置 | 覆盖的规则 | 编译期是否被检验 |
| --- | --- | --- |
| `NativeBridge` 类 + `registerProxy()` | W4（注册后必须 `refresh()`）、W5（配 `deleteJavaScriptRegister`）、W12（methodList）、W13（注册对象对所有 frame 可见） | W5/W12 ✅ 签名过检；W4/W13 是运行期语义，❌ |
| `callH5()` | W10（返回的 string 是 JSON 文本，要 `JSON.parse`）、W11（`onPageEnd` 时序） | ❌ 均为运行期语义 |
| `openPort()` / `sendToH5()` | W1（`postMessageEvent` ≠ `postMessage`）、W2（两个 `postMessage` 语义）、W3（`PortPayload` 类 + `JSON.stringify`）、W9（先 `onMessageEvent` 再发） | **W1 ✅ 反向实验直接确认**（见下）；W2/W3/W9 ❌ |
| `ready()` 守卫 | W15（controller 未绑定就调方法 → 17100001） | ❌ 运行期错误码 |
| `aboutToAppear()` | W16（`setWebDebuggingAccess` 是静态方法，不留到发布版） | ✅ 静态方法归属过检 |
| `rawfile/js/probe.js` | W6（外部脚本预期被 CORS 拦，页面上自报结果） | ❌ 要装上才知道 |
| `Web(...)` 上的注释 | W20（默认 `ASYNC_RENDER`，7,680px 白屏阈值） | ❌ 纯注释 |
| `PortPayload` 类的存在本身 | R2（对象字面量必须有显式类型，不能直接 `JSON.stringify({...})`） | ✅ 过检 |

H5 页面本身做成了**自报结果的测试台**：W6 探针、三条路径各一节，
所以步 3 一装上就能一眼看出哪条通、哪条不通，不必逐条手工比对。

### 编译器真的在查类型 —— W1 由此转为实测

`BUILD SUCCESSFUL` 本身不能排除「它只是转译、没查类型」。所以做了反向实验：
把 `sendToH5()` 里 W1 的正确写法故意改错再编译。

```diff
- this.ports[1].postMessageEvent(JSON.stringify(payload));
+ this.ports[1].postMessage(JSON.stringify(payload));
```

```
10505001 ArkTS Compiler Error
Error Message: Property 'postMessage' does not exist on type 'WebMessagePort'.
  At File: .../entry/src/main/ets/pages/Index.ets:177:21
COMPILE RESULT:FAIL {ERROR:2}
```

**这是 W1 的机器证据**：`WebMessagePort` 上确实没有 `postMessage`，写错在编译期就被抓，
不会拖到运行期静默失败。改回后 `BUILD SUCCESSFUL` 恢复，文件已还原。

推论：靠 API 签名成立的规则（W1/W5/W12/W16、R2/R16 等）都过了类型检查；
**W2/W3/W4/W9/W10/W11/W15 是运行期语义，编译通过不构成验证**，仍只有文档依据。
`code-linter` 这条线依然是空的 —— OpenHarmony CLT 包内没有 codelinter 实体。

## 结论

**假设成立到「能编译」，卡在「能跑」。** 逐句拆开：

| 假设的分句 | 判定 |
| --- | --- |
| 只有 CLT（无 DevEco Studio）能创建混合容器工程 | ✅ **成立**，`create` 甚至不需要 SDK |
| 能编译出 HAP | ✅ **成立**，但**限定在 OpenHarmony API 23**；HarmonyOS SDK 侧未检验 |
| 加载 rawfile 里的 H5、跑通三条通信路径 | ⛔ **未检验**，无设备/模拟器 |

四个可证伪点的当前状态：

1. `create` + `build` 出不了 HAP → **被推翻**（OpenHarmony 侧出得来；HarmonyOS 侧待检）。
2. HAP 装不进模拟器 → **未检验**，本机无 OpenHarmony 设备/模拟器。
3. `Web` 组件加载 `$rawfile` 失败 → **未检验**（`index.html` 与 `probe.js` 已确认进包）。
4. 三条通信路径任一跑不通 → **未检验**；但 W1 已由编译器**正面确认**。

最有价值的产出不是 HAP，是**有了裁判**：281 行 ArkTS 第一次被真编译器判过，
`docs/03` 的 R/W 规则集在类型层面站得住。运行期语义仍然只有文档依据。

## 遗留

- ⚠️ **仓库里提交的是 HarmonyOS 侧配置**（2026-09-04 起，为了别人 clone 后能用 DevEco Studio 打开），
  复现本实验的编译要先 `bash harmony/switch-runtime.sh ohos`。**入库那份配置本身未被编译器验过。**
- ⚠️ **产物是 OpenHarmony HAP**，预期装不进 HarmonyOS NEXT 真机（未实测，无设备）。
  要 HarmonyOS HAP 仍需人登录下载 Command Line Tools，见 `harmony/README.md`。
- ⚠️ 步 3–8 全部未开始：本机无 OpenHarmony 设备/模拟器。`hdc` 在 `sdk/23/toolchains/hdc`（存在），
  但没有目标可连。**这是本实验现在唯一的卡点**，且是环境卡点不是代码卡点。
- ⚠️ W2/W3/W4/W9/W10/W11/W15 属运行期语义，编译通过**不构成**验证。
- ⚠️ `code-linter` 实体不在 OpenHarmony CLT 包内（`$CLT/bin/codelinter` 只是个壳），静态检查这条线仍缺。
- 模拟器镜像获取是否也要华为账号登录，未确认。若要，这个实验会和 `001` 卡在同一处。
- 目标 API 定 23 还是 24：OpenHarmony 侧现锁 23（CLI 上限），HarmonyOS 侧要等真 CLT 再判。
- 本实验只验最小闭环。同层渲染（W17–W23）、离线 Web 组件（W24–W27）、SchemeHandler 另立实验。
