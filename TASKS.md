# 鸿蒙侧任务清单（M1–M5）

最后更新：2026-09-17 ｜ 按 pro 的 commit **`e13f506`**

判据、取值、要不要做，全部只在 pro 那七份文件里；这份清单只做一件事：**把每个里程碑的「怎么算过」
翻译成鸿蒙侧的动作**——落在哪个 API、动哪个文件、怎么验。判据一句也不复述，复述出来就是第二处真相。
pro 会动，往下一个里程碑走之前重读它，并更新上面那个 commit。

**M1 逐条到位，M2–M5 只到「哪个 API / 哪个回调 / 哪条单测」为止**，不展开实现——形状还没在一个能跑的
容器上验过，写细了只是把猜测钉死。

---

## M1 · 装到模拟器

**这一步不碰 `Web` 组件。** 一行 ArkWeb 代码都不写，`Index.ets` 只是一个原生页面。

| pro 的判据 | 鸿蒙侧动作 | 动哪个文件 | 怎么验 | 状态 |
| --- | --- | --- | --- | --- |
| 构建通过 | `devecocli build` 出 HAP | 整个 `harmony/Crab/` | 命令返回 `BUILD SUCCESSFUL`，产物 `harmony/Crab/entry/build/default/outputs/default/entry-default-unsigned.hap`（2026-09-17 实测 **76,922 B**） | ✅ 已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译 |
| 产物是 HAP | 同上，鸿蒙侧本来就是 HAP | — | 同上 | ✅ 同上（是 OpenHarmony HAP，不是交付形态） |
| 装进模拟器能起来 | `hdc install` + 起 Ability | — | 屏幕上出现那个原生页面 | ❌ **阻塞**：无 HarmonyOS SDK、无模拟器镜像 |
| 屏幕上有一个原生页面 | `Index.ets` 一个最小页面（`Column` + `Text`），不引 `@kit.ArkWeb` | `harmony/Crab/entry/src/main/ets/pages/Index.ets` | 编译过 + 装上之后人眼看一次 | 编译 ✅ ／ 观察 ❌ 同上 |
| 标识 `net.xiaoluzhu.crab` | `bundleName` | `harmony/Crab/AppScope/app.json5` | 字符串在工程里只出现一处 | ✅ 已落地 |
| 应用名 `Crab` ＋ 中文「螃蟹」 | `label` 走 `$string:app_name`，中文落一份 `zh_CN` 限定词资源 | `AppScope/resources/base/element/string.json` ＋ `AppScope/resources/zh_CN/element/string.json` | ⚠️ 只有装上之后看桌面图标下的名字才算验过 | 落地 ✅ ／ 观察 ❌ |
| `compatibleSdkVersion` / `targetSdkVersion` = `6.1.0(23)` | HarmonyOS 侧那两个字符串值 | `harmony/Crab/build-profile.json5` 的 PLATFORM BLOCK | `bash harmony/switch-runtime.sh` 回 `hos` 即是这一档 | ✅ 由 `switch-runtime.sh` 保证 |

**「装得上」在鸿蒙侧有一条与代码无关的拦路虎**：`00401004`，要求的 syscap 全集来自 `deviceTypes`，
模拟器的能力集通常比任何完整设备类型都小。已预先放 `harmony/Crab/entry/src/main/syscap.json` 收窄，
机制、实测数字与「HarmonyOS 侧是否生效未核实」都在
[`TOOLCHAIN.md`](TOOLCHAIN.md#5-装不进设备-00401004)。真撞上了先按那条走，**不得因为装不上就改成真机
验收**——那是 pro 的第 3 个出口，回 pro 议。

### 现在不做什么

- **不碰 `Web` 组件**、不写任何 ArkWeb 代码、不建 `rawfile/`
- **不加 `ohos.permission.INTERNET`**——它是 M2 承载那一步的事（pro 的 M2 平台事实），M1 加了就是提前
  往 `module.json5` 里塞一条没有消费方的声明
- **`scripts/probe.sh` 只留骨架**（十六条 slug 与固定顺序已固化在里面），断言从 M2 起填
- 不接 JSBridge——pro 明写契约作废

### 阻塞在哪

一件事，两处后果：**本机没有 HarmonyOS SDK，也没有模拟器镜像。**

- 「装进模拟器能起来」「屏幕上有一个原生页面」这两格观察不了，M1 因此**不能宣布过**
- 交付物形态也不对：现在编出来的是 OpenHarmony HAP，pro 要的是 HarmonyOS NEXT 的 HAP

解法是人工的一步（登录华为账号下载 CLT + 模拟器镜像），步骤在
[`TOOLCHAIN.md`](TOOLCHAIN.md#需要人做的一步)。在那之前鸿蒙侧的措辞停在
**「已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行」**。

### M1 一过要插队的两条

pro 的 `开工.md` 排的是「M1 一过立刻插队，不等 M2 开工」，鸿蒙侧摊到两条，都在壳子里加一个 `Web`
组件加几行打印就打得出来，不另起临时工程：

| 哪一条 | 怎么打 | 为什么值得插队 |
| --- | --- | --- |
| 模拟器上 ArkWeb 跑不跑得起来，顺带 `resource://` 的 origin 与子资源 | `Web` 组件加载一个 `$rawfile` 页面，打印 `location.origin`，看同目录的脚本与图片加载得上 | 答案同时改三处（pro 的 M2 承载方案、M3 混合内容那条的理由、「三端一致」要不要为某端破例）；**更大的一层是「模拟器能不能当验收面」——跑不起来则 M2–M4 在鸿蒙侧整个没有观察面，属范围级，回 pro 议** |
| `data:` iframe 加不加载得起来 | 入口 HTML 嵌一个 `data:` URL 的 iframe，内联脚本 `postMessage` 回父页面 | 它是 M3 `inject-scope` 那条断言的载体（pro 的 M3「要试出来的」第一条）；不行就地试 `sandbox` + `srcdoc` 的退路，换则三端一起换 |

两条都被上面那个阻塞挡着——**没有模拟器就一条都打不出来**。

### 顺带能推进的待核实

pro 的 M1「要试出来的」里落在鸿蒙侧的两条，都不挡建工程，且**不需要模拟器**：

| 要核什么 | 怎么核 | 状态 |
| --- | --- | --- |
| 鸿蒙 `bundleName` 的字符规则 | 查官方声明（`python3 tools/hwdoc.py doc app-configuration-file`），再拿 `devecocli create --bundle-name` 试一个 | 部分：`net.xiaoluzhu.crab` 被 CLI 收下（全小写、点分三段），**官方字符规则的声明还没查到** |
| 鸿蒙上架之后能否改 `bundleName` | 查 AppGallery 的声明 | 未做 |

两条都只决定 pro 里那句「形状核过」的依据能不能站住，**不改取值**。核出来回 pro 改文档。

### 对账

pro 的 `开工.md` 要求每个里程碑收尾把「怎么算过」那几格的结果贴到 pro 上该里程碑的 issue 里。
鸿蒙侧现在能贴的是：构建通过 ✅（`BUILD SUCCESSFUL in 2 s 698 ms`，产物 76,922 B 未签名 OpenHarmony
HAP，`rpcid.json` 212 条）、装得上与页面 ❌（附阻塞原因）。
**不等谁、也不阻塞谁**，但要贴——三端跑偏要在第一次对账就看出来。

---

## M2 · 本地承载

承载**从官方解法一起手**：自编 https 域名 + `onInterceptRequest` 映射回 `$rawfile`（理由是内核的 CORS
白名单不含 `resource`，见 pro 的 M2 平台事实）。`resource://` 那条路仍要核一次，两条都不成立才谈本地
HTTP server。

| pro 的判据 | 落在哪个 API / 哪个文件 | 怎么验 |
| --- | --- | --- |
| 六条断言（`origin` `storage` `subresource` `intercept` `escape` `escape-encoded`） | 探针页素材落 `entry/src/main/resources/rawfile/`；越界目标那个文件放**承载目录之外**、内容 `OUT_OF_BOUNDS` | `bash scripts/probe.sh`，一行一条 |
| 承载与拦截 | `Web` 组件的 `onInterceptRequest`：命中映射回 `$rawfile`，未命中自兜 404 + body 固定标记 `INTERCEPTED` | `intercept` 那条断言 |
| DOM storage 本里程碑先开（只借这一项） | `domStorageAccess(true)` | `storage` 那条断言 |
| 承载 origin 在端内只定义一处 | 一个 ArkTS 常量（位置随承载代码定），喂给三处：`onInterceptRequest` 的映射判定、`ScriptItem.scriptRules`（**须以 `://` 结尾**）、`onLoadIntercept` 的放行判定 | **一条可执行检查**：扫源码树断言该字符串只出现一处（单测或构建期脚本，走查不算） |
| 不得读到承载目录之外的文件，含 `%2e%2e%2f` | 拦截点里做路径归一化 | 两条越界断言 + **一条路径归一化单测** |
| 访问网页要声明的权限 | `module.json5` 的 `requestPermissions` 加 `ohos.permission.INTERNET`（system_grant，声明即可） | 编译过 + 页面能打开；⚠️ 全部请求都被拦截点接住时是否仍需这条，pro 的 M2「要试出来的」里有一格 |
| `resource://` 那条路 | 拿 `$rawfile` 直接承载跑 `origin` 与 `subresource` 两条 | 与插队那条 spike 合并跑一次 |

不用 `WebSchemeHandler`：`onInterceptRequest` 够了，而前者必须在结束回调里清理资源，多一处泄漏面。
真要用（取 POST body）时再换。

---

## M3 · 配置、注入与 UA

| pro 的判据 | 落在哪个 API / 哪个文件 | 怎么验 |
| --- | --- | --- |
| 六项配置逐项显式 | `javaScriptAccess` / `domStorageAccess` / `mixedMode(MixedMode.None)` / `fileAccess(false)` / 有声媒体自动播放 / `zoomAccess(false)` + `textZoomRatio(100)` | **取值单测**（pro 的规矩：取值进单测） |
| 文件访问那一项在鸿蒙上是两处 | `fileAccess(false)`，**且不得调用 `setPathAllowingUniversalAccess()`** | 单测断言那个调用不存在（扫源码树） |
| 六项不得写入可能为空的变量 | 全部写字面量或非空常量 | 同上那条单测；理由是鸿蒙「不设置」与传 `undefined`/`null` 结果不同，`mixedMode` 会从最严跳到最松 |
| 注入 | `javaScriptOnDocumentStart(Array<ScriptItem>)`，注册点**只能落在 `onControllerAttached` 里**（controller 方法早于它一律抛 17100001）；`scriptRules` 从 M2 那个 origin 常量派生，须以 `://` 结尾 | `inject-order`、`inject-scope` 两条断言 |
| 注入脚本内容三端一字不差 | 立即执行函数：先判 `location.origin`，再 `window.__CRAB__ = … { origin, injected: 0 }`、`injected++` | `inject-order` 判 `injected === 1` |
| ⚠️ 相同脚本内容会被静默去重 | 不靠「注册两次不同规则」扩范围 | 走查 + 单测断言只注册一处 |
| UA | `onControllerAttached` 里 `getUserAgent()` 取 → 拼 `Crab/0.1.0` → `setCustomUserAgent()`，**须在 `loadUrl` 之前** | **UA 拼接单测** + 探针页打印 `navigator.userAgent` |
| 版本取应用版本 | `AppScope/app.json5` 的 `versionName`（已是 `0.1.0`） | 与 UA 单测同一处 |
| 加载后生效差异表（鸿蒙那一列七行） | 两个实例、三步法 | 只能在模拟器上跑；UA 那行 pro 已记「改动触发重载」 |
| `renderMode` | 建 `Web` 组件时定（**构造参数，不可动态切换**）；默认 `ASYNC_RENDER` 下组件高度超 7,680 物理像素白屏 | 走查；这一种白屏不触发任何错误回调，别归因到 M4 的降级没做对 |

---

## M4 · 导航与降级

| pro 的判据 | 落在哪个 API / 哪个回调 | 怎么验 |
| --- | --- | --- |
| 导航闸门 | **`onLoadIntercept` 与 `onOverrideUrlLoading` 初期都接上**（覆盖面不同，矩阵跑完再决定砍不砍哪个；两处放行判定必须一致，都从 M2 那个常量派生） | 覆盖矩阵：六种情形各触发一次，列「哪个回调在哪种情形下响了」 |
| 跨 origin 一律拒绝并留日志 | 闸门里拒绝 + 打 `CRAB-NAV nav-cross-origin <URL>` | `nav-cross-origin`，日志由 `probe.sh` 回读 |
| `_blank` / `window.open` 一律拒绝并各留一行 | `multiWindowAccess(true)` + `onWindowNew` 里拒绝；**`allowWindowOpenMethod` 显式取 `true`**（取 false 则脚本发起的 `window.open` 压根不回调，那行日志就没了；它的默认值还受系统属性影响） | `nav-blank`；⚠️ `onWindowNew` 里「不新建窗口」的正确回法要查声明 + 跑一次，回调不能悬着 |
| `tel:` / `mailto:` 交系统 | 闸门放行给系统方式打开 | `nav-system-scheme`，唯一一条 `MANUAL` |
| 未知 scheme 拒绝且不崩溃 | 闸门里拒绝 + `CRAB-NAV nav-unknown-scheme <URL>` | `nav-unknown-scheme` + 命令收尾时进程还在 |
| 对话框三处都接、都必须回一次 | `onAlert` / `onConfirm` / `onPrompt` 返 `true` 自处理，**必须调 `result.handleConfirm()` / `handleCancel()`** + 各打 `CRAB-DLG <类型>` | `dialog`：页面读到 `true` 与 `CRAB`，日志三行 |
| 权限一律拒绝、给页面明确失败 | `onPermissionRequest` → `request.deny()`；`onGeolocationShow` → `geolocation.invoke(origin, false, false)`；**两处都要接** + 各打 `CRAB-PERM <权限>` | `permission`（探针页只按定位这一条；相机麦克风要 `getUserMedia`，M5 明写未验证） |
| 后退走页面历史，到底交宿主 | `accessBackward()` 判、`backward()` 退；拦页面级 `onBackPress`，无历史时返回 false 交宿主 | `nav-back` + 「在入口页直接后退」人工看一次 |
| 渲染进程终止重建一次，第二次进错误态 | `onRenderExited`（带 `renderExitReason`）；**计数必须幂等**——移动设备多个 `Web` 组件共享渲染进程，一次退出在每个组件上各触发一次 | 主动触发两次：`terminateRenderProcess()`（三端里唯一有官方手段的端）；⚠️ `renderExitReason` 各取值含义要声明与实测各取一次 |
| 主文档加载失败进错误态，不得白屏 | `onErrorReceive` / `onPageBegin` 一侧接错误态：固定文案 +「重试」按钮 + `CRAB-ERR <场景> <错误码>` | 删掉承载目录里的入口文件再加载一次（**单独跑一遍，跑完把文件放回去**） |
| SSL 错误一律取消，绝不 proceed | `onSslErrorEventReceive` → `event.handler.handleCancel()`；子资源上的只取消并打一行 | **没有观察面**：走查 + 一条单测（拦住「图省事 proceed 一下」那次手误） |
| 切后台停媒体与计时器 | Ability 的 `onInactive()` + `pauseAllTimers()` | 人工看一次（媒体停播、计时器停） |
| 销毁容器 | 先从视图树摘除再销毁，销毁后无回调进入已释放对象 | 人工看一次 |
| ⚠️ 「共享渲染进程」这个前提本身 | `setRenderProcessMode()` / `getRenderProcessMode()` 是**静态方法**，传枚举外的值自动按多进程处理 | 不设它；上面那条幂等的前提就是「没人碰过这个开关」 |

四个日志前缀 `CRAB-NAV` / `CRAB-DLG` / `CRAB-PERM` / `CRAB-ERR` 的取值在 pro 的取值表，本仓不另写。
打到 hilog，`probe.sh` 用 `hdc hilog` 回读（⚠️ 这条路还没跑过；取不回来则靠日志判的那五条退回
`MANUAL`，pro 的 M4「要试出来的」有这一格）。

---

## M5 · 三端汇合

| pro 的判据 | 落在哪个 API / 哪条单测 |
| --- | --- |
| release 构建禁止开启远程调试 | `setWebDebuggingAccess(boolean)`（API 9，**静态、进程级**，做不到按容器区分） |
| 开关取值由构建类型决定，不得写成常量或运行期可改的配置 | 取值从构建产物类型派生 + **一条单测**按构建类型断言取值 |
| 三端记录并排放齐 | 探针页十六条的逐项结果、加载后生效差异表鸿蒙那一列、每条要求的核实记录 |
| 明写「只在模拟器上看过」的那几条 | 鸿蒙侧目前是**全部**——本机连模拟器都没有，一条都还没跑过 |

`setWebDebuggingAccess(true)` 官方自带安全提示（不建议在正式发布版本中启用），所以这条不只是 pro 的
规矩；带端口的重载要 API 20 起且端口须 > 1024，本项目不用。

---

## 探针页与 `scripts/probe.sh`

素材一套（入口 HTML、一个脚本 + 一张图、越界目标文件、第二个 HTML、八个人工按钮、`data:` iframe），
按里程碑分批加，形状与那五条规约在 pro 的 M2 最后一节，**三端一字不差、本仓不复述**。

`scripts/probe.sh` 现在是骨架：十六条 slug 与固定顺序已固化，判定全部输出 `FAIL not-implemented`。
要把它填满，缺的三件按顺序是：模拟器镜像 → M2 的承载与探针页 → 脚本自己那四段（起模拟器装 HAP →
人工那一遍 → 回读 hilog → 判定）。**人工那一遍在命令之前跑完，命令不代按。**
