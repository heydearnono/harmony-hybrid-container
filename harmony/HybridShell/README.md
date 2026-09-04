# HybridShell — 混合容器最小基座（拿到手先读这个）

最后更新：2026-09-04

原生外壳 + 本地 H5 的最小可编译工程：`Web` 组件加载 `$rawfile` 里的页面，
跑原生 ↔ H5 三条通信路径（`runJavaScript` / `registerJavaScriptProxy` / `WebMessagePort`）。
背景与规则集见仓库根的 `README.md`、`docs/05-arkweb-hybrid-container.md`、`docs/03-arkts-codegen-rules.md`。

**当前状态**：已过 OpenHarmony API 23 编译，产出 110,930 B 未签名 HAP；
**未在 HarmonyOS SDK 上编译过，也从没在设备上跑过**（本项目没有设备/模拟器）。
所以下面「运行期」相关的坑都是别人替我们踩出来的，不是我们自己验的。

## 三分钟检查清单

按顺序过，90% 的报错都出在这四条上：

1. **打开的目录对不对** —— 要打开 `harmony/HybridShell/`，**不是仓库根目录**。
   仓库根没有 `build-profile.json5`，DevEco Studio 会直接说「请选择一个工程」。
2. **平台配置跟你的 SDK 对不对** —— 仓库默认是 HarmonyOS 侧。
   只有 OpenHarmony SDK 就先 `bash harmony/switch-runtime.sh ohos`。
3. **DevEco Studio 版本够不够新** —— 工程声明 `modelVersion: 6.1.0`，
   老 Studio 只认 `6.0.1`，编译第一步就会拦。
4. **装不上不等于代码有问题** —— `00401004` 这类是设备能力/签名问题，跟 ArkTS 代码无关。

## 你走哪条路

| 你的环境 | 平台配置 | 编译命令 | 产物 |
| --- | --- | --- | --- |
| DevEco Studio + HarmonyOS SDK | `switch-runtime.sh hos`（仓库默认） | Studio 里点 Build，或 `hvigorw assembleHap` | HarmonyOS HAP |
| 只有命令行 + OpenHarmony SDK | `switch-runtime.sh ohos` | `source harmony/env.sh && devecocli build` | OpenHarmony HAP |

两套 SDK **不能互相顶替**：它们靠元数据文件名硬性区分（OpenHarmony 是 `oh-uni-package.json`
+ metaVersion `3.0.x`，HarmonyOS 是 `sdk-pkg.json` + `1.0.x`），`runtimeOS` 决定加载器走哪一支。
伪造也过不了 metaVersion 白名单，所以只能切配置，不能骗它。

## 错误速查表

| 现象 | 一句话原因 | 怎么修 |
| --- | --- | --- |
| `Select an OpenHarmony or HarmonyOS project` | 打开的目录不是工程根 | 打开 `harmony/HybridShell/` 这一级 → [#1](#1-选择工程时被拒) |
| `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]` | 工程写着 OpenHarmony，你只有 HarmonyOS SDK | `switch-runtime.sh hos` → [#2](#2-两套-sdk-配错) |
| `00303168 Configuration Error / SDK component missing.` | 反过来：工程写着 HarmonyOS，你只有 OpenHarmony SDK | `switch-runtime.sh ohos` → [#2](#2-两套-sdk-配错) |
| `00303028 Unsupported modelVersion of Hvigor 6.1.0` | Studio 自带的 hvigor 只认 `6.0.1` | 升 Studio → [#3](#3-modelversion-对不上) |
| `00303034 For the OpenHarmony project, Please configure compileSdkVersion` | OpenHarmony 侧必填这个字段 | `switch-runtime.sh ohos` 会带上 |
| `00303060` 系统能力集交集为空 | `deviceTypes: ["phone"]` 在 OpenHarmony SDK 里不存在 | 同上，脚本会改成 `["default"]` |
| `00303208 Unable to find 'sdk.dir' in 'local.properties' or 'OHOS_BASE_SDK_HOME'` | 没告诉 hvigor SDK 在哪 | `export OHOS_BASE_SDK_HOME=...`，别往工程里塞 `local.properties` |
| `00308018 The SDK license agreement is not accepted` | **误导性报错**，真因是本地缺 SDK 组件 | 把缺的 native / previewer 装上 → [#4](#4-许可证报错其实是缺组件) |
| `00401004` 设备缺一批 `SystemCapability.*` | 要求的能力集来自 `deviceTypes`，与代码无关 | 见 [#5](#5-装不进设备-00401004) 与 `docs/03` 的 R22 |
| `10505001 ArkTS Compiler Error` | 这才是真的代码错 | 按文件行号改，编译器会指到具体位置 |
| `Will skip sign 'hap'. No signingConfigs profile is configured` | 只是警告，产物未签名 | 装真机才需要签名 → [#6](#6-未签名的-hap) |
| `Failed to determine Command Line Tools version from version.txt` | `version.txt` 首行格式不对 | 必须是 `# Version: 26.0.0` 这种形式 |
| `Invalid API version 24. Your SDK supports API version 17-23` | DevEco CLI 的 api-level 上限是 23 | 用 `--api-level 23` |
| `Command failed with ENOENT: <CLT>/tool/node/bin/node` | CLT 里缺 Node / ohpm 实体 | 见仓库 `harmony/README.md` 的「另一条路」 |
| `Installing pnpm@8.13.1` / `1 high severity vulnerability` | Studio 自己拉构建依赖 | **无关噪音，忽略** |

## 逐条详解

### #1 选择工程时被拒

`Select an OpenHarmony or HarmonyOS project` 只说明**当前目录不像一个工程**。两种可能：

- 打开的是仓库根 `hmos/`。工程在 `harmony/HybridShell/`，判据是那一级有 `build-profile.json5`
  和 `oh-package.json5`。
- 拉到的代码里真的没有工程。曾经就是这个原因——工程提交在了本地分支上没推。
  核一下：`git ls-tree -r --name-only origin/main | grep harmony/HybridShell` 应该有 33 个文件。

### #2 两套 SDK 配错

这是目前最容易撞的一条，且**两个方向各有一条报错，互为镜像**：

| 工程里写的 | 你机器上装的 | 报什么 |
| --- | --- | --- |
| `runtimeOS: "OpenHarmony"` + 整数 `23` | 只有 HarmonyOS SDK | `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]` |
| `runtimeOS: "HarmonyOS"` + `"6.1.0(23)"` | 只有 OpenHarmony SDK | `00303168 SDK component missing.`（本项目实测） |

一条命令切：

```sh
bash harmony/switch-runtime.sh          # 只看当前在哪一侧
bash harmony/switch-runtime.sh hos      # 切 HarmonyOS
bash harmony/switch-runtime.sh ohos     # 切 OpenHarmony
```

它只重写两个文件里 `>>> PLATFORM BLOCK >>>` 标记之间的内容
（`build-profile.json5` 的 `runtimeOS` + 三个版本号、`entry/src/main/module.json5` 的 `deviceTypes`），
注释和其他配置不动。往返切换是幂等的。**不要手改这四处**，漏一处就会撞上另一条报错。

⚠️ 提交前记得切回 `hos`（仓库默认），否则下一个用 Studio 的人又会撞 #2。

### #3 modelVersion 对不上

```
00303028 Configuration Error
Error Message: Unsupported modelVersion of Hvigor 6.1.0.
  > The supported Hvigor modelVersion is 6.0.1.
```

工程两处声明 `6.1.0`（`hvigor/hvigor-config.json5`、`oh-package.json5`），是 `devecocli create`
（DevEco CLI 1.3.0-stable）落盘时写的。报这条说明**你的 DevEco Studio 比生成工程的 CLI 老一档**。

**建议升 Studio，而不是把工程降到 6.0.1**：工程还锁着 `compatibleSdkVersion: "6.1.0(23)"`，
只认 model 6.0.1 的 Studio 大概率也没有 API 23 SDK，降 modelVersion 只是把报错往后挪一格。
⚠️ 具体哪个 Studio 版本带支持 6.1.0 的 hvigor，没查到可信来源，别照抄版本号。

真要降版本，把这三样一起降到你实际装了的级别，别只降一个：
`hvigor/hvigor-config.json5` 的 `modelVersion`、`oh-package.json5` 的 `modelVersion`、
`build-profile.json5` 的三个 SDK 版本号。

### #4 许可证报错其实是缺组件

```
00308018 Cause: The SDK license agreement is not accepted.
... re-download the Native:6.1.0.32,Previewer:6.1.0.32 SDK
```

**不是许可证问题。** 读 `oh-sdk-info-handler.js` 的 `getOrDownload()`：本地已有的组件不走许可检查，
本地缺件才转去远端解析，而远端件要先接受许可——报错就是这么串出来的。
正解是把缺的组件装上（native 891.8 MB + previewer 215.2 MB，这工程一个都不用，但 hvigor 强制要）。

**不要**去伪造 `$SDK/licenses/<id>.sha256` 绕过它，那等于代人接受许可协议。

### #5 装不进设备 00401004

```
错误码: 00401004
当前设备的rpcid.json文件中不包含以下系统能力属性：SystemCapability.Telephony.CallManager,
SystemCapability.Communication.Bluetooth.Core, SystemCapability.Multimedia.Drm.Core, ...
```

**这个工程只用 ArkWeb，一条 Telephony / Bluetooth / DRM 都没 import**，为什么会要求它们？

因为**要求设备具备的能力全集是按 `module.json5` 的 `deviceTypes` 整体取的，与代码 import 无关**。
hvigor 的 `SyscapTransform` 取 `sdk/<api>/ets/api/device-define/<type>.json` 的 `SysCaps` 求交，
写成 `rpcid`。本项目实测：`entry/build/default/intermediates/syscap/default/rpcid.json` 里有
**227 条**能力，协作者设备缺的那 15 条全在里面。

各设备类型的能力条数（OpenHarmony SDK 23 实测）：`default` 227、`2in1` 223、`tablet` 219、
`wearable` 193、`tv` 181、`liteWearable` 17。如果缺失清单里既有 `Telephony.*`
又有几乎所有类型都有的 `Bluetooth.Core` / `WiFi.P2P`，说明目标设备的能力集比任何完整设备类型都小
—— **大概率是模拟器**。

工程里已经放了 `entry/src/main/syscap.json` 来收窄，用的是 `production.removedSysCaps`：

```json
{
  "devices": { "general": ["default"] },
  "production": { "removedSysCaps": ["SystemCapability.Multimedia.Drm.Core"] }
}
```

OpenHarmony 侧实测有效：`rpcid.json` 从 227 条降到 **212** 条，`Web.Webview.Core` 保留，编译仍通过。

⚠️ **在 HarmonyOS 侧是否生效未核实**：那个 task 的 `doTaskAction()` 第一行是
`if (this.targetData.isHarmonyOS()) return;`。如果你在 HarmonyOS + Studio 下加了 `syscap.json`
还是报 00401004，就改 `deviceTypes` 去匹配目标设备类型，或者换真机装。

### #6 未签名的 HAP

`Will skip sign 'hap'. No signingConfigs profile is configured` 只是警告，编译照样成功，
产物是 `entry-default-unsigned.hap`。**但未签名的 HAP 装不进真机。**

- OpenHarmony 侧签名材料是齐的：toolchains 自带 `OpenHarmony.p12`、`OpenHarmonyProfileDebug.pem`、
  `UnsgnedDebugProfileTemplate.json`，不需要华为证书、不需要实名认证。本工程还没配 `signingConfigs`。
- HarmonyOS 真机调试要**实名认证 + AGC 签名**，这一步谁也代办不了。
- 签名证书、私钥、`.p12`/`.cer`/`.p7b`、AGC 账号信息**一律不入库**。

## 命令行编译的三个环境变量

用 DevEco CLI 而不是 Studio 时，这三个都是硬要求：

```sh
source harmony/env.sh                                             # JAVA_HOME、PATH
export DEVECO_CLI_CLT_PATH="$HOME/.local/hmos-toolchain/clt-oh"    # CLT 位置
export OHOS_BASE_SDK_HOME="$HOME/.local/hmos-toolchain/clt-oh/sdk" # SDK 位置
```

⚠️ 官方文档 `ide-deveco-cli-install` 写的是 `DEVECO_CLI_CLI_PATH`，**实测无效**，
真正生效的是 `DEVECO_CLI_CLT_PATH`（少一个字母之差，对照实验见 `experiments/001`）。

## 哪些还没被验证过（别当成已知可用）

这份工程的验证强度只到「编译过」，说清楚免得踩空：

| 事项 | 状态 |
| --- | --- |
| ArkTS 类型检查 | ✅ 过了，且做过反向实验确认编译器真在查（故意把 `postMessageEvent` 写成 `postMessage`，报 `10505001`） |
| OpenHarmony API 23 出 HAP | ✅ 通过 |
| HarmonyOS SDK 上编译 | ❌ 没做过，本项目没有 HarmonyOS SDK |
| 装到设备、页面真的渲染出来 | ❌ **一次都没跑过** |
| 三条通信路径真的通 | ❌ 只有编译期的类型保证，运行期语义（消息时序、`refresh()` 生效时机、错误码）全未验 |
| W6 的 CORS 拦截、W20 的 7,680px 白屏阈值 | ❌ 未验，`rawfile/js/probe.js` 是留着上设备后自报结果的探针 |

所以：**编译通过 ≠ 能跑。** `docs/03` 里 W2/W3/W4/W9/W10/W11/W15 这些运行期规则至今只有文档依据。
你要是真在设备上跑起来了，那些结论比我们的文档值钱得多，欢迎回填。

## 遇到新坑怎么记

- 报错原文优先，别转述。错误码 + `Error Message` 整段贴进 `research-log/YYYY-MM-DD-主题.md`。
- 确认是通用坑（不是你机器的偶发问题）之后，补一行到本文的速查表。
- 如果是「AI 写这段代码容易写错」类的，追加到 `docs/03-arkts-codegen-rules.md`
  的 R / W 规则集——那是本仓库最有复用价值的产出。
- 写结论前先分清三档，措辞别混：**未编译验证** < **已过 OpenHarmony API 23 编译** < **已运行验证**。





