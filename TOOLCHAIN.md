# 工具链与构建陷阱（鸿蒙侧工程事实）

最后更新：2026-10-08

这份文件是重建时 `docs/` 分流的另一半：**端侧工程事实**（工具链咬合、构建配置陷阱、错误码速查）。
另一半（平台声明与仍成立的技术约束）已搬进 pro 对应里程碑的「平台事实」块，本仓不留副本。

**本机写，另一台验。** 本机只有免登录的 OpenHarmony API 23 链，能出 OpenHarmony HAP，只算编译体检；
交付物（HarmonyOS NEXT 的 HAP）的构建与模拟器运行在另一台 Mac 上，用 DevEco Studio 6.1.0 自带的 SDK
（2026-10-08 起，见下面「另一台机器」）。

本机的链全部装在 `~/.local/hmos-toolchain/`，自成一体，`rm -rf` 即卸载。**不进本仓库、不提交、不改
`~/.zshrc`**——环境变量走 `source harmony/env.sh`。

## 现在有什么

| 组件 | 状态 | 位置 |
| --- | --- | --- |
| DevEco CLI 1.3.0-stable | ✅ `--version` / `create` / `build` 均实测通过 | `cli/` |
| JDK 21（Temurin 21.0.12.1+1 LTS） | ✅ 实测通过，sha256 对过 Adoptium 官方值 | `jdk-21.0.12.1+1/` |
| 官方工程模板（25 个文件） | ✅ 在 CLI 包内 `templates/application/` | 同上 |
| OpenHarmony 链（hvigor 6.26.1 + ohpm + Node 22 + SDK 23） | ✅ 已就位、实测编译成功，全程免登录、逐件对过 sha256 | `clt-oh/`（version.txt: 26.0.0.461） |
| HarmonyOS Command Line Tools ≥ 26.0.0 | ❌ 未就位，下载需华为账号登录 | 应放到 `command-line-tools/` |
| `code-linter` | ❌ `clt-oh` 包内无实体，`$CLT/bin/codelinter` 只是个壳 | — |
| 设备 / 模拟器 | ❌ 本机一个都没有 | — |

### 另一台机器（HarmonyOS 侧的构建与运行面）

2026-10-08 起 M1 在这台上跑通，原样输出在 [`docs/运行记录/M1.md`](docs/运行记录/M1.md)。它只 pull、构建、装、
贴回输出，**不提交**。

| 组件 | 实测 |
| --- | --- |
| 机器 | macOS 27.0（`26A428`）· arm64 |
| DevEco Studio | 6.1.0（`DS-243.24978.46.36.610860`） |
| HarmonyOS SDK | Studio 自带 `6.1.0.105`（API 23，`releaseType` Release），`Contents/sdk/default/` 下**只有这一档** |
| `hdc` | **不在默认 PATH 里**，在 `/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/` |
| 模拟器 | `hdc list targets` 读到 `127.0.0.1:5555` |

```sh
export PATH="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains:$PATH"
hdc list targets
```

那台的工作区里有旧的 `harmony/HybridShell/`、`1~`、`hm-evidence.txt`，是重建前的残留，不该提交。

官方要求 CLT ≥ 26.0.0 配 JDK 21，26.0.0 以下配 JDK 17（`ide-command-line-building-app`）。

## 三个环境变量

```sh
source harmony/env.sh ohos     # 一条命令把下面三样都设好
```

| 变量 | 值 | 说明 |
| --- | --- | --- |
| `JAVA_HOME` | `~/.local/hmos-toolchain/jdk-21.0.12.1+1/Contents/Home` | CLI 按 `JAVA_HOME/bin` → `JAVA_HOME` → `PATH` 找 java |
| `DEVECO_CLI_CLT_PATH` | `…/clt-oh` 或 `…/command-line-tools` | ⚠️ 官方文档 `ide-deveco-cli-install` 写的是 `DEVECO_CLI_CLI_PATH`，**实测完全无效**。CLI 认的四个是 `DEVECO_CLI_STUDIO_PATH` / `DEVECO_CLI_CLT_PATH` / `DEVECO_HOME` / `DEVECO_PATH`。有效性判据：该目录下有 `version.txt` |
| `OHOS_BASE_SDK_HOME` | `…/clt-oh/sdk` | 仅 OpenHarmony 侧要。缺了报 `00303208 Unable to find 'sdk.dir' in 'local.properties' or 'OHOS_BASE_SDK_HOME'`。用环境变量而非往工程里塞 `local.properties`（机器相关，已在 `.gitignore`） |

`version.txt` 首行格式是硬要求，正则 `/^#\s*Version:\s*(\S+)/`。写成裸版本号 `26.0.0` 会报
`Failed to determine Command Line Tools version from version.txt`。

⚠️ `$CLT/sdk/default/openharmony/toolchains` 是 DevEco CLI 的 **hdcPath（设备部署用）**，不是构建期
SDK 布局。构建期 hvigor 找的是 `$CLT/sdk/<apiVersion>/{ets,js,native,toolchains,previewer}`
（`abstract-component-loader.js` 的 `getLocation()`）。两者不要混为一谈。

## 免登录那条链是怎么来的

登录门禁挡住的**只有 HarmonyOS SDK 本体**。hvigor、ohpm、OpenHarmony SDK 全是公开直链：

| 件 | 来源 | 校验 |
| --- | --- | --- |
| CLT 外壳（hvigor 6.26.1 + ohpm 26.0.0.410；`sdk/` 与 `tool/node/` 是空占位） | `repo.huaweicloud.com/openharmony/compiler/hvigor/6.26.1/command-line-tools.zip` | 77,819,058 B，✅ 对上同目录 `.sha256`（`6db6883a…c756079`） |
| `tool/node` | `repo.huaweicloud.com/nodejs/v22.14.0/node-v22.14.0-darwin-arm64.tar.gz` | 47,035,396 B，✅ 对上 **nodejs.org** 的 `SHASUMS256.txt`（不用镜像自报值） |
| `sdk/23/` 五组件 6.1.0.32 | `POST repo.harmonyos.com/sdkmanager/v5/ohos/getSdkList`，体 `{"osType":"darwin","osArch":"arm64","supportVersion":"26.0-ohos-single-1"}` | 55 个组件无鉴权，每项自带 url + size + checksum，✅ 逐件对过 |

⚠️ `osType` 在 OpenHarmony 分支必须填 `darwin`（原值直传，填 `mac` → `139403 参数校验未通过`）。

**五组件合计 1,255 MB（解开 4.0 GB）**，其中两件本项目一个都不用、但 hvigor 强制要：
`native`（NDK）**891.8 MB**、`previewer` **215.2 MB**；要用的是 ets 69.8 + js 56.4 + toolchains 22.2 MB。
缺件时 hvigor 报的是误导性的许可证错误，见 [#4](#4-许可证报错其实是缺组件)。

## API level 上限是 23，不是 24

`--api-level 24` 直接被拒：`Invalid API version 24. Your SDK supports API version 17-23`。
读 `dist/cli.js` 的 `RI()`：下限硬编码 **17**，上限取 `getMaxApiLevel()`、取不到时回落硬编码 **23**。

后果：工程锁在 API 23，也就是 pro 的 M1 定的 `6.1.0(23)` 正好是这条链的上限，不必迁就。
另一台机器上 Studio 6.1.0 自带的 HarmonyOS SDK 也只到 API 23（`6.1.0.105`），两侧同一档。
取值本身归 pro 的 M1 版本档位那一节，本仓不自决。

## 两套 SDK 家族互斥，只能切、不能骗

| 工程里写的 | 机器上装的 | 报什么 |
| --- | --- | --- |
| `runtimeOS: "OpenHarmony"` + 整数 `23` | 只有 HarmonyOS SDK | `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]` |
| `runtimeOS: "HarmonyOS"` + `"6.1.0(23)"` | 只有 OpenHarmony SDK | `00303168 SDK component missing.`（本仓实测） |

两条互为镜像，正好说明两套不能互相顶替。断点确切：靠元数据文件名硬性区分——OpenHarmony 是
`oh-uni-package.json` + metaVersion `3.0.x`，HarmonyOS 是 `sdk-pkg.json` + `1.0.x`，`runtimeOS`
决定加载器走哪一支，**伪造也过不了 metaVersion 白名单**。

切换靠 `bash harmony/switch-runtime.sh [hos|ohos]`，它只重写两个文件里 `>>> PLATFORM BLOCK >>>`
标记之间的内容，往返幂等：

| 文件 | ohos 侧 | hos 侧（仓库默认） |
| --- | --- | --- |
| `harmony/Crab/build-profile.json5` | `runtimeOS: "OpenHarmony"`，`compileSdkVersion`（**必填**）/ `compatibleSdkVersion` / `targetSdkVersion` = 整数 `23` | `runtimeOS: "HarmonyOS"`，`compatibleSdkVersion` / `targetSdkVersion` = `"6.1.0(23)"`，无 `compileSdkVersion` |
| `harmony/Crab/entry/src/main/module.json5` | `deviceTypes: ["default"]` | `deviceTypes: ["phone"]` |

理由：OpenHarmony 侧不填 `compileSdkVersion` 报 `00303034`；OpenHarmony 的
`sdk/23/ets/api/device-define/` 只有 `2in1/default/liteWearable/tablet/tv/wearable`，**没有 `phone`**，
写 `phone` 报 `00303060 系统能力集交集为空`。

仓库提交的是 HarmonyOS 侧的值。这一份配置 **2026-10-08 第一次过了编译器**：另一台机器上 Studio 6.1.0
带 `clean` 从头编，`BUILD SUCCESSFUL`，`switch-runtime.sh` 没切（[运行记录](docs/运行记录/M1.md)）。本机仍只能编
`ohos` 那一侧。

## 需要人做的一步

**另一台机器已经走通了另一条路**（DevEco Studio 6.1.0 自带 SDK + 模拟器，见上）。下面这几步只在要让**本机**
也能出 HarmonyOS HAP、跑模拟器时才需要，现在不挡任何事。

1. 打开 <https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos>，登录下载
   **macOS ARM** 版（≥ 26.0.0）。动态验证码这一环 Agent 代办不了。
2. 按下载页的「工具完整性指导」校验一次。
3. 解压，让 `~/.local/hmos-toolchain/command-line-tools/` 下**直接**是 `version.txt`、`bin/`、
   `sdk/`、`tool/`。zip 内通常已含一层同名目录，别套两层。
4. 判据：`ls ~/.local/hmos-toolchain/command-line-tools/version.txt` 有文件即算就位。
5. 再下一个**模拟器镜像**——M1 到 M4 的观察面全在它上面。模拟器仅支持 Windows X86 与 macOS ARM
   （本机 arm64，满足）。

## 编不过时先看这里

### 三分钟检查清单

按顺序过，90% 的报错都出在这四条上：

1. **打开的目录对不对** —— 工程在 `harmony/Crab/`，**不是仓库根**。根目录没有 `build-profile.json5`，
   DevEco Studio 会直接说「请选择一个工程」。
2. **平台配置跟你的 SDK 对不对** —— 仓库默认是 HarmonyOS 侧。只有 OpenHarmony SDK 就先
   `bash harmony/switch-runtime.sh ohos`。
3. **DevEco Studio 版本够不够新** —— 工程声明 `modelVersion: 6.1.0`，老 Studio 只认 `6.0.1`，
   编译第一步就拦。**Studio 6.1.0 实测认**（2026-10-08）。
4. **装不上不等于代码有问题** —— `00401004` 这类是设备能力/签名问题，跟 ArkTS 代码无关。

### 你走哪条路

| 你的环境 | 平台配置 | 编译命令 | 产物 |
| --- | --- | --- | --- |
| DevEco Studio + HarmonyOS SDK | `switch-runtime.sh hos`（仓库默认） | Studio 里点 Build，或 `hvigorw assembleHap` | HarmonyOS HAP（`hos_hap`）。Studio 6.1.0 实测过（2026-10-08） |
| 只有命令行 + OpenHarmony SDK | `switch-runtime.sh ohos` | `source harmony/env.sh ohos && cd harmony/Crab && devecocli build` | OpenHarmony HAP |

### 错误速查表

| 现象 | 一句话原因 | 怎么修 |
| --- | --- | --- |
| `Select an OpenHarmony or HarmonyOS project` | 打开的目录不是工程根 | 打开 `harmony/Crab/` 这一级 → [#1](#1-选择工程时被拒) |
| `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]` | 工程写着 OpenHarmony，你只有 HarmonyOS SDK | `switch-runtime.sh hos` → [#2](#2-两套-sdk-配错) |
| `00303168 Configuration Error / SDK component missing.` | 反过来：工程写着 HarmonyOS，你只有 OpenHarmony SDK | `switch-runtime.sh ohos` → [#2](#2-两套-sdk-配错) |
| `00303028 Unsupported modelVersion of Hvigor 6.1.0` | Studio 自带的 hvigor 只认 `6.0.1` | 升到 Studio 6.1.0 或以上 → [#3](#3-modelversion-对不上) |
| `00303034 For the OpenHarmony project, Please configure compileSdkVersion` | OpenHarmony 侧必填这个字段 | `switch-runtime.sh ohos` 会带上 |
| `00303060` 系统能力集交集为空 | `deviceTypes: ["phone"]` 在 OpenHarmony SDK 里不存在 | 同上，脚本会改成 `["default"]` |
| `00303208 Unable to find 'sdk.dir' in 'local.properties' or 'OHOS_BASE_SDK_HOME'` | 没告诉 hvigor SDK 在哪 | `source harmony/env.sh ohos`，别往工程里塞 `local.properties` |
| `00308018 The SDK license agreement is not accepted` | **误导性报错**，真因是本地缺 SDK 组件 | 把缺的 native / previewer 装上 → [#4](#4-许可证报错其实是缺组件) |
| `00401004` 设备缺一批 `SystemCapability.*` | 要求的能力集来自 `deviceTypes`，与代码无关 | → [#5](#5-装不进设备-00401004) |
| `10505001 ArkTS Compiler Error` | 这才是真的代码错 | 按文件行号改，编译器会指到具体位置 |
| `Will skip sign 'hap'. No signingConfigs profile is configured` | 只是警告，产物未签名 | 装真机才需要签名 → [#6](#6-未签名的-hap) |
| `Failed to determine Command Line Tools version from version.txt` | `version.txt` 首行格式不对 | 必须是 `# Version: 26.0.0` 这种形式 |
| `Invalid API version 24. Your SDK supports API version 17-23` | DevEco CLI 的 api-level 上限是 23 | 用 `--api-level 23` |
| `Command failed with ENOENT: <CLT>/tool/node/bin/node` | CLT 里缺 Node / ohpm 实体 | 见上面「现在有什么」 |
| `Installing pnpm@8.13.1` / `1 high severity vulnerability` | Studio 自己拉构建依赖 | **无关噪音，忽略** |

### 逐条详解

#### #1 选择工程时被拒

`Select an OpenHarmony or HarmonyOS project` 只说明**当前目录不像一个工程**。两种可能：

- 打开的是仓库根。工程在 `harmony/Crab/`，判据是那一级有 `build-profile.json5` 和 `oh-package.json5`。
- 拉到的代码里真的没有工程。曾经就是这个原因——工程提交在本地分支上没推。
  核一下：`git ls-tree -r --name-only origin/main | grep '^harmony/Crab/'` 应该有几十个文件。

#### #2 两套 SDK 配错

目前最容易撞的一条，且**两个方向各有一条报错，互为镜像**（对照表与断点见上面那一节）。一条命令切：

```sh
bash harmony/switch-runtime.sh          # 只看当前在哪一侧
bash harmony/switch-runtime.sh hos      # 切 HarmonyOS
bash harmony/switch-runtime.sh ohos     # 切 OpenHarmony
```

它只重写 `harmony/Crab/build-profile.json5` 与 `harmony/Crab/entry/src/main/module.json5` 里
`>>> PLATFORM BLOCK >>>` 标记之间的内容，注释和其他配置不动，往返幂等。
**不要手改那四处**，漏一处就撞另一条报错。

⚠️ 提交前切回 `hos`（仓库默认），否则下一个用 Studio 的人又撞 #2。

#### #3 modelVersion 对不上

```
00303028 Configuration Error
Error Message: Unsupported modelVersion of Hvigor 6.1.0.
  > The supported Hvigor modelVersion is 6.0.1.
```

工程两处声明 `6.1.0`（`hvigor/hvigor-config.json5`、`oh-package.json5`），是 `devecocli create`
（DevEco CLI 1.3.0-stable）落盘时写的。报这条说明**你的 DevEco Studio 比生成工程的 CLI 老一档**。

⚠️ **`modelVersion` 要分清「模板里写的」和「生成出来的」**：CLI 包内
`templates/application/hvigor/hvigor-config.json5` 磁盘上是 `6.0.2`，`create` 落盘时替换成 `6.1.0`。

**建议升 Studio，而不是把工程降到 6.0.1**：工程还锁着 `compatibleSdkVersion: "6.1.0(23)"`，只认
model 6.0.1 的 Studio 大概率也没有 API 23 SDK，降 modelVersion 只是把报错往后挪一格。
**DevEco Studio 6.1.0（`DS-243.24978.46.36.610860`）实测认 `modelVersion 6.1.0`**（2026-10-08，从头编过）。
比它老的哪一版开始认，没查到可信来源，别往下推。

真要降，把三样一起降到你实际装了的级别：`hvigor/hvigor-config.json5` 的 `modelVersion`、
`oh-package.json5` 的 `modelVersion`、`build-profile.json5` 的三个 SDK 版本号。

#### #4 许可证报错其实是缺组件

```
00308018 Cause: The SDK license agreement is not accepted.
... re-download the Native:6.1.0.32,Previewer:6.1.0.32 SDK
```

**不是许可证问题。** 读 `oh-sdk-info-handler.js` 的 `getOrDownload()`：本地已有的组件不走许可检查，
本地缺件才转去远端解析，而远端件要先接受许可——报错就是这么串出来的。正解是把缺的组件装上
（native 891.8 MB + previewer 215.2 MB，这工程一个都不用，但 hvigor 强制要）。

**不要**伪造 `$SDK/licenses/<id>.sha256` 绕过它，那等于代人接受许可协议。

#### #5 装不进设备 00401004

```
错误码: 00401004
当前设备的rpcid.json文件中不包含以下系统能力属性：SystemCapability.Telephony.CallManager,
SystemCapability.Communication.Bluetooth.Core, SystemCapability.Multimedia.Drm.Core, ...
```

**这个工程一条 Telephony / Bluetooth / DRM 都没 import**，为什么会要求它们？因为**要求设备具备的
能力全集是按 `module.json5` 的 `deviceTypes` 整体取的，与代码 import 无关**。hvigor 的
`SyscapTransform` 取 `sdk/<api>/ets/api/device-define/<type>.json` 的 `SysCaps` 求交，写成 `rpcid`
（产物在 `entry/build/default/intermediates/syscap/default/rpcid.json`）。

各设备类型的能力条数（OpenHarmony SDK 23 实测）：`default` 227、`2in1` 223、`tablet` 219、
`wearable` 193、`tv` 181、`liteWearable` 17。缺失清单里既有 `Telephony.*`、又有几乎所有类型都有的
`Bluetooth.Core` / `WiFi.P2P` 时，说明目标设备的能力集比任何完整设备类型都小——**大概率是模拟器**。
M1 的「装进模拟器」正好撞在这个形状上，所以工程里预先放了
`harmony/Crab/entry/src/main/syscap.json` 收窄：`devices.general` 取 `["default"]`，
`production.removedSysCaps` 列 15 条（蜂窝 5 条、近场与分布式硬件 4 条、分布式数据 2 条、
媒体转码与 DRM 2 条、应用域名校验与企业设备管理 2 条）。逐条理由写在那个文件的注释里。

机制依据读的是 hvigor 6.26.1 的实现而非文档：`abstract-syscap-transform.js` 的
`processProductionSysCap()` 在写 `rpcid` 之前按 `addedSysCaps` / `removedSysCaps` 增删集合。
**在 OpenHarmony 侧实测有效**：`rpcid.json` 从 227 条降到 **212** 条，`Web.Webview.Core` 保留，
编译仍通过（2026-09-17 在重建后的 `harmony/Crab/` 上复核过一次，与上一轮工程同数）。

⚠️ **在 HarmonyOS 侧是否生效未核实**：那个 task 的 `doTaskAction()` 第一行是
`if (this.targetData.isHarmonyOS()) return;`。2026-10-08 装进 HarmonyOS 模拟器时**没撞 `00401004`**，但那台
机器上没读 `rpcid.json`，所以分不清是 `syscap.json` 起了作用、还是模拟器能力集本来就够——仍算未核。HarmonyOS + Studio 下加了 `syscap.json` 还报 00401004，
就改 `deviceTypes` 去匹配目标设备类型。**但不要为了装上去而改成真机验收**——那是 pro 定的范围级问题，
回 pro 议（pro 的 M2 与 M5 都有交代）。

#### #6 未签名的 HAP

`Will skip sign 'hap'. No signingConfigs profile is configured` 只是警告，编译照样成功，产物是
`entry-default-unsigned.hap`。**但未签名的 HAP 装不进真机。**

- OpenHarmony 侧签名材料齐：toolchains 自带 `OpenHarmony.p12`、`OpenHarmonyProfileDebug.pem`、
  `UnsgnedDebugProfileTemplate.json`，不需要华为证书、不需要实名认证。本仓未配 `signingConfigs`。
- HarmonyOS 真机调试要**实名认证 + AGC 签名**，这一步谁也代办不了。
- ⚠️ **HarmonyOS 模拟器收不收未签名 HAP 未核**：2026-10-08 那次产物未签名（`Will skip sign 'hos_hap'`），
  应用也装上了，但 `hdc install` 的输出没留，分不清是直装还是 Studio 运行时自动签了名。下次装要留输出。
- 签名证书、私钥、`.p12` / `.cer` / `.p7b`、AGC 账号信息**一律不入库**。

## 遇到新坑怎么记

- 报错原文优先，别转述。错误码 + `Error Message` 整段贴进来。
- 确认是通用坑（不是你机器的偶发问题）之后，补一行到上面的速查表。
- 「AI 写这段代码容易写错」类的，追加到 [`ARKTS-RULES.md`](ARKTS-RULES.md)。
- 挖出来的是**平台事实**（平台声明、平台层面的技术约束）就不进本仓，归 pro 对应里程碑的「平台事实」块。
- 写结论前先分清三档，措辞别混：**未编译验证** < **已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK
  上编译，未运行** < **已运行验证**。

## 边界

- **免登录拿 HarmonyOS（非 OpenHarmony）SDK 没找到可信途径**：HOS 的 `getSdkList` 虽免鉴权，但只返回
  模拟器系统镜像，没有 ets / toolchains；三方转载包无官方 sha256 可校验、且含会进入编译产物链路的
  可执行二进制，**不采用**。
- **不伪造 `$SDK/licenses/<id>.sha256`**——那等于代人接受许可协议。
- 签名证书、私钥、`.p12` / `.cer` / `.p7b`、AGC 账号信息一律不入库。`.gitignore` 拦一层，以人工确认为准。
- OpenHarmony 侧签名材料倒是齐的，不需要华为证书、不需要实名认证；本仓未配 `signingConfigs`，
  产物是 `entry-default-unsigned.hap`。**HarmonyOS 真机调试要实名认证 + AGC 签名，谁也代办不了。**
- 工程结构由 `devecocli create` 从官方模板生成，**不手搓**。`create` 只校验参数 + 落模板，不碰 SDK；
  唯一门禁是 `DEVECO_CLI_CLT_PATH` 下有个能解析的 `version.txt`。
- `create` 参数：`--app-name`（必填，`^[a-zA-Z][a-zA-Z0-9_]*$`）、`--project-path`（默认
  `./<app-name>`，已存在则必须为空）、`--bundle-name`（默认 `com.example.<小写名>`）、
  `--api-level`（整数 17–23）。本仓这一份的生成命令记在 [`README.md`](README.md)。
