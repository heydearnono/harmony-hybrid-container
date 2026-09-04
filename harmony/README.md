# harmony/ — 工程位

最后更新：2026-09-04 ｜ **`HybridShell/` 已真编译通过，产出 HAP。**
走的是免登录的 OpenHarmony API 23 链（`BUILD SUCCESSFUL in 3 s 399 ms`）。
**产物是 OpenHarmony HAP，装不进 HarmonyOS NEXT 真机**；要 HarmonyOS HAP 仍需人登录下载 Command Line Tools。

## 先做这一步：确认平台配置对得上你的 SDK

工程有两套互斥的平台配置，**仓库里提交的是 HarmonyOS 侧**（= `devecocli create` 的原值），
用 DevEco Studio 打开可以直接编译。本机这条免登录链只有 OpenHarmony SDK，编译前要先切过去：

```sh
bash harmony/switch-runtime.sh          # 只看当前是哪一侧
bash harmony/switch-runtime.sh ohos     # 切到 OpenHarmony（本机编译走这个）
bash harmony/switch-runtime.sh hos      # 切回 HarmonyOS（仓库默认，提交前切回来）
```

配错了会撞上这两条错误，**都不是代码问题，是 SDK 家族对不上**：

| 现象 | 谁在报 | 原因 |
| --- | --- | --- |
| `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]` | HarmonyOS 侧 hvigor / DevEco Studio | 工程写着 `runtimeOS: "OpenHarmony"`，但机器上只有 HarmonyOS SDK → 切 `hos` |
| `00303168 Configuration Error / SDK component missing.` | 本机 OpenHarmony 链（2026-09-04 实测） | 工程写着 `runtimeOS: "HarmonyOS"`，但机器上只有 OpenHarmony SDK → 切 `ohos` |
| `00303028 Unsupported modelVersion of Hvigor 6.1.0` | 对方 DevEco Studio 自带的 hvigor | Studio 比生成工程的 CLI 老，只认 modelVersion `6.0.1`；工程两处写 `6.1.0`（`hvigor/hvigor-config.json5`、`oh-package.json5`）→ 升 Studio 为主 |
| `00401004` 设备缺一批 `SystemCapability.*` | 安装期（设备/模拟器） | 要求的 syscap 全集来自 `deviceTypes`，与代码 import 无关；见 `docs/03` 的 **R22** 与 `entry/src/main/syscap.json` |

两条错误互为镜像，正好说明两套 SDK 不能互相顶替（依据见本文「另一条路 → 边界」）。
**面向使用者的完整坑点清单在 [`HybridShell/README.md`](HybridShell/README.md)**，本文只记工具链本身。
脚本只重写两个文件里 `>>> PLATFORM BLOCK >>>` 标记之间的内容，注释与其余配置不动。

## 现在是什么状态

| 事项 | 状态 |
| --- | --- |
| 工程骨架 `HybridShell/` | ✅ 由 `devecocli create` 从包内官方模板生成，30 个文件 |
| 混合容器代码（`Index.ets` 281 行 + `rawfile/`） | ✅ 已写入 |
| `devecocli build` 出 HAP | ✅ **已通过**（OpenHarmony API 23，110,930 B 未签名 HAP） |
| ArkTS 类型检查 | ✅ 已过，且用反向实验确认编译器真在查类型（见下） |
| HarmonyOS SDK 上编译 | ❌ 未做，需人登录下载 CLT |
| 装设备、跑三条通信路径 | ❌ 未开始，本机无 OpenHarmony 设备/模拟器 |
| `code-linter` 静态检查 | ❌ 该 CLT 包内无 codelinter 实体，`$CLT/bin/codelinter` 只是个壳 |

所以现在的准确说法是 **「已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行」** ——
比「未编译验证」强，比「已验证可运行」弱。

### 编译器真的在查类型（W1 的机器证据）

把 `sendToH5()` 里 W1 的正确写法故意改错再编译：

```diff
- this.ports[1].postMessageEvent(JSON.stringify(payload));
+ this.ports[1].postMessage(JSON.stringify(payload));
```

```
10505001 ArkTS Compiler Error
Error Message: Property 'postMessage' does not exist on type 'WebMessagePort'.
  At File: .../entry/src/main/ets/pages/Index.ets:177:21
```

`BUILD SUCCESSFUL` 不是空过。推论：靠 API 签名成立的规则（W1/W5/W12/W16、R2/R16 等）都过了类型检查；
但 W2/W3/W4/W9/W10/W11/W15 是**运行期语义**，编译通过**不构成**验证。

`HybridShell/` 的生成方式见「骨架是怎么生成的」一节——**没有手搓**。

## 工具链：编译链已齐（走 OpenHarmony），HarmonyOS SDK 仍缺

全部装在 `~/.local/hmos-toolchain/`（自成一体，`rm -rf` 即卸载）：

| 组件 | 状态 | 位置 |
| --- | --- | --- |
| DevEco CLI 1.3.0-stable | ✅ `--version`/`create`/`build` 均实测通过 | `~/.local/hmos-toolchain/cli/` |
| JDK 21（Temurin 21.0.12.1+1 LTS） | ✅ 实测通过，sha256 已对官方值 | `~/.local/hmos-toolchain/jdk-21.0.12.1+1/` |
| 官方工程模板（25 个文件） | ✅ 就在 CLI 包内 `templates/application/` | 同上 |
| **OpenHarmony 编译链（hvigor 6.26.1 + ohpm + Node 22 + SDK 23）** | ✅ **已就位并编译成功**，全部免登录、逐件对过 sha256 | `~/.local/hmos-toolchain/clt-oh/` |
| HarmonyOS Command Line Tools ≥ 26.0.0 | ❌ 未就位，下载需华为账号登录 | 应放到 `~/.local/hmos-toolchain/command-line-tools/` |
| `code-linter` | ❌ `clt-oh` 包内无实体 | — |

环境变量走 `source harmony/env.sh`，**不改动 `~/.zshrc`**。

## 骨架是怎么生成的（含一个桩，需知情）

`devecocli create` 只做两件事：校验参数、把包内 `templates/application/` 的 25 个文件做变量替换后落盘。
**它不碰 SDK。** 唯一的门禁是 `DEVECO_CLI_CLT_PATH` 指向的目录里得有一个能解析的 `version.txt`。

所以 2026-09-03 用了这个办法把骨架先落下来：

```sh
# ~/.local/hmos-toolchain/clt-stub/version.txt 内容首行为：# Version: 26.0.0
export DEVECO_CLI_CLT_PATH="$HOME/.local/hmos-toolchain/clt-stub"
devecocli create --app-name HybridShell --project-path harmony/HybridShell \
  --bundle-name com.example.hybridshell --api-level 23
```

- `version.txt` 的格式是硬要求，正则 `/^#\s*Version:\s*(\S+)/`。写成 `26.0.0` 裸版本号会报
  `Failed to determine Command Line Tools version from version.txt`。
- 桩目录叫 `clt-stub`，**故意不叫 `command-line-tools`**，免得和真 CLT 的位置混掉。
  真 CLT 到位后请 `rm -rf ~/.local/hmos-toolchain/clt-stub`。
- **产物是官方模板的原样输出**，CLI 自己打了 `Template integrity check passed.`。
  这不违反 `CLAUDE.md` 的「不手搓」——手搓的是后来加的业务代码，不是工程结构。

## `build` 缺什么（历史记录，已解决）

桩 CLT 下 `devecocli build` 的失败点是：

```
[ohpm install] Running...
Command failed with ENOENT: <CLT>/tool/node/bin/node <CLT>/ohpm/bin/pm-cli.js install --all
```

即 CLT 里必须真有 `tool/node/bin/node` 与 `ohpm/bin/pm-cli.js`。
**桩只能过 `create`，过不了 `build`。** 这两个洞后来由免登录的 OpenHarmony 链填上了（见「另一条路」）。

## API level 上限是 23，不是 24

`--api-level 24` 会被直接拒绝：

```
Invalid API version 24. Your SDK supports API version 17-23
```

读 `dist/cli.js` 的 `RI()` 确认了规则：下限硬编码 **17**；上限取 `getMaxApiLevel()`，
取不到时回落硬编码的 **23**。⚠️ 桩 CLT 下 `getMaxApiLevel()` 为何返回 23 而非 undefined 未查清，
但两条路径的结果都是 23。

后果：工程锁在 API 23。OpenHarmony 侧现在是整数 `23`；`docs/01` 记的 HarmonyOS 现网主力是
**6.1.1(24)**（2026-08-20 占 84.93%）。**真 CLT 到位后要重新确认它带的 SDK 支持到哪一级。**

## 需要人做的一步（仅在需要 HarmonyOS HAP 时）

编译本身已经不卡了——下面这步只解决「产物是 HarmonyOS HAP 而非 OpenHarmony HAP」。

CLT 的下载页需要**华为开发者账号登录**（第三方 CLI `hdx` 也要求 Huawei ID + 动态验证码），
动态验证码这一环 Agent 无法代办。所以：

1. 打开 <https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos>，登录并下载 **macOS ARM** 版（≥ 26.0.0）。
2. 按下载页的「工具完整性指导」校验一次。
3. 解压，让 `~/.local/hmos-toolchain/command-line-tools/` 下**直接**是 `version.txt`、`bin/`、`sdk/`、`tool/`。
   注意 zip 内通常已含一层 `command-line-tools/` 目录，别套两层。

判据：`ls ~/.local/hmos-toolchain/command-line-tools/version.txt` 能看到文件即算就位——
DevEco CLI 正是读这个文件来认 CLT（见 `experiments/001` 步 2 对 `dist/cli.js` 的核对）。

之后 `bash harmony/switch-runtime.sh hos`（仓库默认已是这一侧），再 `devecocli build`。
桩也可以删了：`rm -rf ~/.local/hmos-toolchain/clt-stub`。

## 一个必须知道的坑

官方文档 `ide-deveco-cli-install` 写的环境变量名是 `DEVECO_CLI_CLI_PATH`，**实测完全无效**。
真正生效的是 **`DEVECO_CLI_CLT_PATH`**（对照实验见 `experiments/001` 步 2）。`env.sh` 已按实测值写好。

## 工程实际长什么样

`devecocli create` 生成 30 个文件（模板 25 个 + `.gitignore` 等），结构与
`docs/01-platform-landscape.md` 的「标准工程结构」一致：

```
AppScope/{app.json5, resources/...}
build-profile.json5  oh-package.json5  hvigorfile.ts  code-linter.json5
hvigor/hvigor-config.json5
entry/{build-profile.json5, oh-package.json5, hvigorfile.ts, obfuscation-rules.txt}
entry/src/main/module.json5
entry/src/main/ets/{entryability/EntryAbility.ets, entrybackupability/EntryBackupAbility.ets, pages/Index.ets}
entry/src/main/resources/base/{element/..., media/..., profile/{backup_config,main_pages}.json}
entry/src/main/resources/dark/element/color.json
```

本项目在此之上加的（不属于模板）：

```
entry/src/main/resources/rawfile/index.html      # H5 侧，三条通信路径的自报测试台
entry/src/main/resources/rawfile/js/probe.js     # W6 探针，预期加载失败
entry/src/main/ets/pages/Index.ets               # 改写为混合容器
entry/src/main/module.json5                      # 加 ohos.permission.INTERNET
entry/src/main/syscap.json                       # 收窄 rpcid 要求的 syscap，见 docs/03 的 R22
```

⚠️ **`modelVersion` 要分清「模板里写的」和「生成出来的」**：CLI 包内
`templates/application/hvigor/hvigor-config.json5` 磁盘上就是 `6.0.2`，
但 `create` 落盘时替换成了 **`6.1.0`**（工程里现在是 6.1.0）。
本文此前只写「模板实测是 6.1.0」不够准确，已改。

`create` 参数：`--app-name`（必填，`^[a-zA-Z][a-zA-Z0-9_]*$`）、`--project-path`（默认 `./<app-name>`，
已存在则必须为空）、`--bundle-name`（默认 `com.example.<小写名>`）、`--api-level`（整数 17–23，见上）。

## 另一条路：免登录的 OpenHarmony 链（2026-09-03 **已采用并跑通**）

登录门禁挡住的**只有 HarmonyOS SDK 本体**。hvigor、ohpm、OpenHarmony SDK 全是公开直链。
装在 `~/.local/hmos-toolchain/clt-oh/`，每件都对过官方 sha256：

| 件 | 来源 | 校验 |
| --- | --- | --- |
| CLT 外壳（hvigor 6.26.1 + ohpm 26.0.0.410；`sdk/` 与 `tool/node/` 是空占位） | `repo.huaweicloud.com/openharmony/compiler/hvigor/6.26.1/command-line-tools.zip` | 77,819,058 B，✅ 对上同目录 `.sha256` `6db6883a…c756079` |
| `tool/node` | `repo.huaweicloud.com/nodejs/v22.14.0/node-v22.14.0-darwin-arm64.tar.gz` | 47,035,396 B，✅ 对上 **nodejs.org** 的 `SHASUMS256.txt`（不是镜像自报值） |
| `sdk/23/` 五组件 6.1.0.32 | `POST repo.harmonyos.com/sdkmanager/v5/ohos/getSdkList`，体 `{"osType":"darwin","osArch":"arm64","supportVersion":"26.0-ohos-single-1"}` | 55 个组件无鉴权；每项自带 url + size + checksum，✅ 逐件对过 |

⚠️ `osType` 在 OpenHarmony 分支必须填 `darwin`（原值直传，填 `mac` → `139403 参数校验未通过`）。

### 五组件合计 1,255 MB（解开 4.0 GB），比预估大很多

| 组件 | 下载 | 本工程要不要 |
| --- | --- | --- |
| ets / js / toolchains | 69.8 + 56.4 + 22.2 MB | 要 |
| **native**（NDK） | **891.8 MB** | 不要，但 hvigor 强制 |
| **previewer** | **215.2 MB** | 不要，但 hvigor 强制 |

缺 native / previewer 时 hvigor 报的是一条**误导性**错误：

```
00308018 Cause: The SDK license agreement is not accepted.
... re-download the Native:6.1.0.32,Previewer:6.1.0.32 SDK
```

它不是真的许可证问题，而是「本地缺件 → 转去远端解析 → 远端件需先接受许可」。
读 `oh-sdk-info-handler.js` 的 `getOrDownload()`：本地已有的件不走许可检查。
所以正解是把缺的件装上，**不是**去伪造 `$SDK/licenses/<id>.sha256`（那等于代人接受许可协议）。

### 怎么用

```sh
source harmony/env.sh
export DEVECO_CLI_CLT_PATH="$HOME/.local/hmos-toolchain/clt-oh"
export OHOS_BASE_SDK_HOME="$HOME/.local/hmos-toolchain/clt-oh/sdk"
bash harmony/switch-runtime.sh ohos          # 仓库默认是 HarmonyOS 侧，先切过来
cd harmony/HybridShell && devecocli build
```

`OHOS_BASE_SDK_HOME` 是硬要求，缺了报
`00303208 Unable to find 'sdk.dir' in 'local.properties' or 'OHOS_BASE_SDK_HOME'`。
用环境变量而非往工程里放 `local.properties`（机器相关，且已在 `.gitignore`）。

### 工程侧要改两处，都是平台差异不是代码缺陷

**这两处现在由 `harmony/switch-runtime.sh` 代劳**（见文首），下表是它改了什么、为什么改：

| 文件 | 改动 | 为什么 |
| --- | --- | --- |
| `build-profile.json5` | `runtimeOS` → `"OpenHarmony"`；`compileSdkVersion`（**新增，必填**）/`compatibleSdkVersion`/`targetSdkVersion` → 整数 `23` | hvigor 报 `00303034 For the OpenHarmony project, Please configure compileSdkVersion`；schema 的 type 是 `["integer","string"]`，OpenHarmony 用整数 |
| `entry/src/main/module.json5` | `deviceTypes` `["phone"]` → `["default"]` | OpenHarmony 的 `sdk/23/ets/api/device-define/` 只有 `2in1/default/liteWearable/tablet/tv/wearable`，无 `phone`，否则 `00303060 系统能力集交集为空` |

⚠️ **仓库提交的是 HarmonyOS 侧的值**，也就是说*入库那一份配置本身没有被编译器验过*
（本机没有 HarmonyOS SDK）。跑通编译的是 `ohos` 那一侧，`switch-runtime.sh ohos` 后可复现。
这是为了让别人下载后能用 DevEco Studio 直接打开而做的取舍。

### 边界

- **产物是 OpenHarmony HAP**，预期装不进 HarmonyOS NEXT 真机（⚠️ 未实测，无设备）。
  这条路兑现的是「ArkTS/ArkUI/ArkWeb 代码被真编译器检验」，**不是**「HarmonyOS 基座跑起来」。
- 伪装成 HarmonyOS 走不通，断点确切：两个 SDK 家族靠元数据文件名硬性区分
  （OpenHarmony 是 `oh-uni-package.json` + metaVersion `3.0.x`；HarmonyOS 是 `sdk-pkg.json` + `1.0.x`），
  `runtimeOS` 决定加载器走哪一支，伪造也过不了 metaVersion 白名单。
- 免登录拿 **HarmonyOS**（非 OpenHarmony）SDK 的途径未找到可信的：HOS 的 `getSdkList` 虽免鉴权，
  但只返回模拟器系统镜像，没有 ets / toolchains；三方转载包无官方 sha256 可校验、且含可执行二进制，
  会直接进入编译产物链路，**不采用**。
- 签名材料倒是齐的：toolchains 自带 `OpenHarmony.p12` + `OpenHarmonyProfileDebug.pem` +
  `UnsgnedDebugProfileTemplate.json`，不需要华为证书、不需要实名认证。本轮没配 `signingConfigs`，
  产物是 `entry-default-unsigned.hap`。

完整过程与五个报错原文见 `research-log/2026-09-03-免登录编译打通.md`。

## 落地时的注意事项

- 签名证书、私钥、`.p12`/`.cer`/`.p7b`、AGC 账号信息一律不入库。`.gitignore` 拦了一层，但以人工确认为准。
- 真机调试需实名认证 + AGC 签名；模拟器仅支持 Windows X86 与 macOS ARM（本机 arm64，满足）。
- 目标 API 版本建议看现网分布而非最新版：截至 2026-08-20，6.1.1(24) 占 84.93%，26.0.0 对应的 7.0.0 Beta2 仅 4.65%。
- 工具链不要装进本仓库，也不要提交。装在 `~/.local/hmos-toolchain/` 就是为了这个。
