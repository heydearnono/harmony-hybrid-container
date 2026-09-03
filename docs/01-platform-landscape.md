# 平台与工具链现状

最后更新：2026-09-03 ｜ 事实来源见文末来源表 ｜ 本机工具链状态：**编译链已就位并实测通过**（免登录 OpenHarmony API 23），缺 HarmonyOS SDK 与设备/模拟器

## 结论摘要

1. **当前正式版是「HarmonyOS 开发套件 26.0.0 Release」**，2026-08-29 发布，配套 DevEco Studio 26.0.0 Release(26.0.0.821) 与 HarmonyOS SDK 26.0.0 Release（底座 OpenHarmony SDK `Ohos_sdk_public 26.0.0.105`）。来源 A：`overview-2600`。
2. **从 26.0.0 起不再有「整数 API Level」**。官方把版本号改成纯语义化版本 `X.Y.Z`，API 版本号 = 版本号本身。26.0.0 之前是 `X.Y.Z(N)` 格式，括号里的 `N` 才是通常说的 API Level（如 `6.1.1(24)` → API 24）。来源 A：`version-number-26`。
3. **HarmonyOS 5 / 6 / 7 的关系**：OS 版本与 API 版本是两条线。HarmonyOS 5.x → API 12~19；6.x → API 20~24；**HarmonyOS 7.0 是当前 OS 版本，其配套 API 版本就是 26.0.0**。官方页面把两者并列成两列，明确写着「7.0.0 Beta2 ↔ API 版本 26.0.0 Beta2」。来源 A：`sdk-version-percentage`、`upgrade-adaptation`。
4. **媒体说的「HarmonyOS 7 Developer Beta / API 26」有官方依据，但措辞要修正**：官方从不写「API 26」，写的是「API 版本 26.0.0」。首个 Beta 在 HDC.2026 发布（媒体报道 2026-06-12，可信度 B），Release 于 2026-08-29（可信度 A）。
5. **「HarmonyOS NEXT」已不是版本名**。它是 5.0.0(12) 那一轮（2024）Developer Beta / Beta / Release 的命名，现在只作为**设备口径**残留（官方原话「HarmonyOS 7.0 将陆续面向全网 HarmonyOS NEXT 设备发布」）。用 NEXT 指代当前版本 = 过时表述。
6. **现网主力仍是 6.1.1(24)（84.93%）**，26.0.0 系设备仅 4.65%（截至 2026-08-20）。这直接决定 `compatibleSdkVersion` 该配多低。来源 A：`sdk-version-percentage`。
7. **工具链两套入口**：DevEco Studio（IDE，仅 Windows/macOS，SDK/Node.js/Hvigor/ohpm/模拟器全部内置）与 Command Line Tools（Windows/macOS/Linux，同样内置 SDK，用于 CI）。构建是 `hvigorw`（Hvigor 6.26.4），依赖是 `ohpm`（26.0.0.630），设备调试是 `hdc`。
8. **AI Coding 已是官方一等公民，且与本项目高度相关**：`DevEco Code`（基于开源 OpenCode + 华为 BitFun 的终端 Agent）与 `DevEco CLI`（把鸿蒙工具链 + 知识库 + Skills 封装成 CLI / MCP / LSP，供 Cursor、OpenCode 等任意 Agent 调用）。两者均通过 npm 分发，2026-07 首发。
9. **本机（macOS 15.7.3 / arm64 / Node v24.6.0 / 无 JDK）在硬性要求上是够的**，但一个鸿蒙工具都没装：可以写代码、查文档、设计架构，**不能编译、不能签名、不能上真机或模拟器**。

> ⚠️ 排雷提示：`hwdoc.py` 输出的 `labels: ["hmos-503"]` **不是内容版本标记**。已交叉验证——26.0.0、6.1.1、5.0.0 的版本概览页、指南页、API 参考页全部返回同一个 `hmos-503`，它是站点侧的常量标签，不可用来判断文档对应哪个版本。判断版本请看正文与 `updatedDate`。

## 版本与 API Level

### 1）开发套件版本 ↔ API Level ↔ DevEco Studio

「HarmonyOS 开发者版本」在官方口径里**就等于 API 版本**。全表来自 `overview-allversion`（可信度 A，文档 version=V51，更新 2026-08-29）。

| 开发套件版本（= API 版本） | API Level | 配套 DevEco Studio | 发布时间 | 状态 | 官方使用建议 |
| --- | --- | --- | --- | --- | --- |
| **26.0.0** | 无独立整数 Level（SemVer） | DevEco Studio 26.0.0 Release (26.0.0.821) | 2026/08/28 ⚠️ 见下方冲突 | **正式 Release** | 推荐使用 / 推荐升级 |
| 6.1.1(24) | 24 | DevEco Studio 6.1.1 Release | 2026/05/26 | 已 Release | 按需使用 |
| 6.1.0(23) | 23 | DevEco Studio 6.1.0 Release | 2026/04/20 | 已 Release | 按需使用 |
| 6.0.2(22) | 22 | DevEco Studio 6.0.2 Release | 2026/01/21 | 已 Release | 按需使用 |
| 6.0.1(21) | 21 | DevEco Studio 6.0.1 Release | 2025/11/20 | 已 Release | 按需使用 |
| 6.0.0(20) | 20 | DevEco Studio 6.0.0 Release | 2025/09/25 | 已 Release | 推荐使用 / 推荐升级 |
| 5.1.1(19) | 19 | DevEco Studio 5.1.1 Release | 2025/06/30 | 已 Release | 新应用 NA，建议直升 6.0.0(20) |
| 5.1.0(18) | 18 | DevEco Studio 5.1.0 Release | 2025/06/11 | 已 Release | 同上 |
| 5.0.5(17) | 17 | DevEco Studio 5.0.5 Release | 2025/05/14 | 已 Release | 同上 |
| 5.0.4(16) | 16 | DevEco Studio 5.0.4 Release | 2025/03/29 | 已 Release | 同上 |
| 5.0.3(15) | 15 | DevEco Studio 5.0.3 Release | 2025/03/15 | 已 Release | 同上 |
| 5.0.2(14) | 14 | DevEco Studio 5.0.2 Release | 2025/01/27 | 已 Release | 同上 |
| 5.0.1(13) | 13 | DevEco Studio 5.0.1 Release | 2024/11/30 | 已 Release | 同上 |
| 5.0.0(12) | 12 | DevEco Studio 5.0.0 Release | 2024/10/22 | 已 Release | 同上 |
| HarmonyOS 3.1/4.0（API 9） | 9 | DevEco Studio 3.1 Release | 2023/05/15 | 已 Release | NA |

⚠️ **日期冲突**：`overview-allversion` 写 26.0.0 发布时间 `2026/08/28`，`overview-2600` 的配套表写 API 版本 / DevEco Studio / SDK 均为 `2026/08/29`，正文也说「于 8 月 29 日正式 Release 发布」。两者都是 A 类来源，未在官方页面找到调和说明。本文按 **2026-08-29** 使用，并保留冲突记录。

### 2）OS 版本 ↔ API 版本（两条线，别混用）

来源 A：`sdk-version-percentage`（截至 2026-08-20，约 15 天更新一次）。「设备量占比」同时是选 `compatibleSdkVersion` 的现实依据。

| HarmonyOS（OS）版本 | API 版本 | 存量设备占比 |
| --- | --- | --- |
| 7.0.0 Beta2 | 26.0.0 Beta2 | 4.65% |
| 6.1.1 | 6.1.1(24) | **84.93%** |
| 6.1.0 | 6.1.0(23) | 7.69% |
| 6.0.2 | 6.0.2(22) | 1.79% |
| 6.0.1 | 6.0.1(21) | 0.45% |
| 6.0.0 | 6.0.0(20) | 0.04% |
| 5.1.1 | 5.1.1(19) | 0.11% |
| 5.1.0 | 5.1.0(18) | 0.08% |

注：该表快照日期（2026-08-20）早于 26.0.0 Release（2026-08-29），所以 26.0.0 一栏显示的是 Beta2。⚠️ **HarmonyOS 7.0.0 正式版（非 Beta）是否已面向公众设备推送，未在官方文档中查到明确说法**；`upgrade-adaptation` 只写「HarmonyOS 7.0 将陆续面向全网 HarmonyOS NEXT 设备发布」，用的是将来时。

### 3）版本号格式规则（26.0.0 是分水岭）

来源 A：`version-number-26`。

| 时间线 | 格式 | 含义 |
| --- | --- | --- |
| 26.0.0 起 | `X.Y.Z`（SemVer） | X 主版本（可能不兼容，需适配）；Y 次版本（原则上向后兼容）；Z 修订（修 bug，向后兼容）。目的是与底座 OpenHarmony 版本号体系统一 |
| 26.0.0 之前 | `X.Y.Z(N)` | X 取值 1-99、Y 0-99、Z 0-99；`N` 即整数 API Level |

近期 API 版本大小关系（官方给出的显式排序，AI 最容易在这里排错）：
`26.0.0 > 6.1.1(24) > 6.1.0(23) > 6.0.2(22) > 6.0.1(21) > 6.0.0(20) > 5.1.1(19) > 5.1.0(18) > 5.0.5(17)`

### 4）26.0.0 Release 的完整配套版本号

来源 A：`deveco-studio-new-features-2600`（DevEco Studio 26.0.0.821 兼容性配套关系）。这些数字是「AI 最容易凭印象写错」的典型，需要时请回查原页。

| 组件 | 版本 | 说明 |
| --- | --- | --- |
| HarmonyOS SDK | HarmonyOS 26.0.0 Release SDK | 内置于 IDE / 命令行工具 |
| OpenHarmony SDK（底座） | `Ohos_sdk_public 26.0.0.105` | 来源 `overview-2600` |
| DevEco Studio | 26.0.0 Release (26.0.0.821) | — |
| Command Line Tools | 26.0.0.821 | 与 IDE 同版本号 |
| Hvigor / hvigorw | 6.26.4 | 适用于 API 10 及以上工程 |
| ohpm | 26.0.0.630 | — |
| codelinter | 6.0.240 | — |
| hstack | 6.1.0 | — |
| HarmonyOS Emulator | 26.0.0.400 | — |
| Node.js（内置） | 24.14.1 | Hvigor / ohpm / codelinter 等的运行时 |
| modelVersion | 26.0.0 | 开发态版本号 |
| compileSdkVersion | 26.0.0 | 只能配成 IDE 自带 SDK 版本 |
| compatibleSdkVersion | 最低可配 4.0.0(10) | — |
| targetSdkVersion | 4.0.0(10) ~ 26.0.0 | — |

### 5）工程里的三个 SDK 版本字段（配在 `build-profile.json5` 的 `products` 下）

来源 A：`app-compatibility-influence-factor`、`ide-hvigor-build-profile-app`。约束：`compatibleSdkVersion ≤ targetSdkVersion ≤ compileSdkVersion`，违反会报错。

| 源码字段（build-profile.json5） | 打包后字段（module.json5） | 含义 |
| --- | --- | --- |
| `compileSdkVersion` | `compileSdkVersion` | 编译用 SDK 版本，决定可联想的 API 范围与工具链版本；只能配为当前 IDE 自带 SDK 版本 |
| `targetSdkVersion` | `targetAPIVersion` | 目标 SDK 版本，默认等于 compileSdkVersion；系统按它做 API 行为变更隔离 |
| `compatibleSdkVersion` | `minAPIVersion` | 可安装的最低设备 API 版本；低于此值的设备装不上 |

**格式陷阱（AI 极易写错）**：从 API 26.0.0 起，三个字段在 HarmonyOS 与 OpenHarmony 下统一为**字符串**，例：`"compileSdkVersion": "26.0.0"`。26.0.0 之前则区分运行环境：HarmonyOS 用字符串 `"6.1.1(24)"`，OpenHarmony 用数值 `24`。同一 `products` 节点还需配 `runtimeOS`（如 `"HarmonyOS"`）。

## 工具链

「本机是否可用」= 2026-09-01 在本机（macOS 15.7.3 / arm64 / Node v24.6.0 / 无 JDK）实测 `command -v` 的结果。

| 工具 | 作用 | 获取方式 | 本机是否可用 |
| --- | --- | --- | --- |
| **DevEco Studio** | 一站式 IDE：AI 辅助编程、编译构建、UI 实时预览、跨语言调试、Profiler、AppAnalyzer、模拟器。基于 IntelliJ IDEA 社区版 | `https://developer.huawei.com/consumer/cn/download/deveco-studio`（下载中心，需登录华为账号；页面提供完整性校验指导） | ❌ 未安装（`/Applications/DevEco-Studio.app` 不存在） |
| **HarmonyOS SDK** | 开放能力（Kit）声明与工具链 | 已内嵌于 DevEco Studio（`DevEco Studio/sdk`，macOS 在 `Contents` 下）及 Command Line Tools，**无需单独下载** | ❌ |
| **Command Line Tools** | CI / 命令行场景的工具集合：codelinter、hstack、hvigorw、ohpm + SDK 内工具 | `https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos`，解压后把 `command-line-tools/bin` 加进 `PATH` | ❌ 未安装 |
| **hvigorw** | Hvigor 的 wrapper：自动装 Hvigor 与插件依赖并执行构建任务（`clean`、`assembleHap` 等）。Hvigor 是 TS 实现的任务编排工具，**可独立于 IDE 运行** | Command Line Tools 的 `bin/`，或 IDE 内置 | ❌ `hvigorw: NOT FOUND` |
| **ohpm** | 三方库/共享包（HAR、HSP）包管理，DevEco Studio 默认包管理器。靠软链接构建依赖关系 | 同上。支持 Windows / macOS / Linux | ❌ `ohpm: NOT FOUND` |
| **ohpm-repo** | 自建轻量级鸿蒙三方库私仓，与 ohpm 兼容 | 文档 `ide-ohpm-repo`，随 IDE 生态提供 | ❌ |
| **hdc**（HarmonyOS Device Connector） | 设备交互调试、装包、传文件、抓日志。client/server/daemon 三段结构，server 默认监听本机 **8710** 端口（可用 `OHOS_HDC_SERVER_PORT` 改） | SDK 内 `sdk/default/openharmony/toolchains`（IDE 或 Command Line Tools 里都有）。支持 Windows / Linux / macOS，可拷出 `hdc` + `libusb_shared` 独立运行 | ❌ `hdc: NOT FOUND` |
| **codelinter** | ArkTS/TS 代码检查与快速修复，可进门禁/CI。规则集含 `@typescript-eslint/*`、`@compatibility/*`（含 API 兼容性检查、废弃 API 检查） | Command Line Tools `bin/` | ❌ |
| **hstack** | 把 Release 混淆后的 crash 堆栈还原为源码堆栈 | Command Line Tools `bin/` | ❌ |
| **arktsdoc** | ArkTSDoc 文档生成 | Command Line Tools | ❌ |
| **Emulator（命令行）** | 命令行创建/启动模拟器 | Command Line Tools / IDE | ❌ |
| SDK 内命令行工具 | `hdc`、`aa`（Ability 助手：拉起组件、强停进程）、`bm`（装/卸/查应用）、`hilog`（日志）、打包工具、拆包工具 | SDK 的 `toolchains` 目录 | ❌ |
| **JDK** | hvigorw 构建与 `keytool` 生成签名密钥所需 | 自行安装。26.0.0 及以上版本 Command Line Tools **推荐 JDK 21**；26.0.0 以下推荐 JDK 17 | ❌ `Unable to locate a Java Runtime` |
| **Node.js** | Hvigor / ohpm / codelinter 的运行时 | 优先用工具包内置的（26.0.0 配套 24.14.1）；DevEco Code / CLI 另要求 22+ | ✅ v24.6.0（满足 22+，但**不是**官方配套的 24.14.1） |

**hvigorw 使用约束**：`hvigorw -v` / `--version` / `version` / `-h` / `--help` 从 hvigorw **5.18.4** 起支持在任意路径执行，其余命令必须在工程根目录执行。

## AI Coding 相关官方工具

官方在指南目录里已把 AI Coding 拆成独立一级章节，且同时给出了一个**已标记「不推荐」**的旧方案，取舍很明确。

| | DevEco Code | DevEco CLI |
| --- | --- | --- |
| 定位 | 面向鸿蒙应用开发的 **AI Agent 本体**（终端交互式） | 把鸿蒙能力**封装成给别的 Agent 调用的接口** |
| 技术底座 | 华为 BitFun 技术 + 开源 **OpenCode**；保留 OpenCode 的终端交互与 Model / Provider / MCP / Skill 配置能力 | 鸿蒙工具集 + 鸿蒙知识库 + 精品 Skills，封装为 CLI / MCP / LSP |
| 目标用户 | 直接用它写鸿蒙代码的开发者 | Cursor、OpenCode 等**通用 AI 开发工具**（官方点名这两个） |
| 能力 | 代码编写、编译构建、运行调试、ArkTS 问题修复、文档查阅；有 Agent 模式与 Goal 模式 | 见下方命令族 |
| 分发 | npm `@deveco/deveco-code`（`@stable` 为稳定版）；`deveco --version` / `deveco upgrade` | npm `@deveco/deveco-cli`；`devecocli --version` / `devecocli update` |
| 版本 | 0.2.0（2026-08）；0.1.1（2026-07）首发 | 1.3.0（2026-08）；1.2.0（2026-07）首发 |
| 支持 OS | Windows 11 22H2+ / macOS 15 Sequoia+ | Windows / macOS / **Linux（Linux 从 1.3.0 起）** |
| 前置依赖 | Node 22+；**（可选）** DevEco Studio 6.1.0+，不装会影响编译构建与推包；可选 `DEVECO_HOME` 指向 IDE 安装目录 | Node 22+（推荐）；DevEco Studio **6.0.0+**；Linux 下需 `export DEVECO_CLI_CLI_PATH=/opt/command-line-tools` |
| 其他环境要求 | RAM 8GB+（长会话/编译/调试 16GB+）；磁盘 8GB+（涉及编译与模拟器调试需 20GB+）；macOS 终端要 Zsh，Windows 要 PowerShell 5.1+（推荐 7+） | 文档未单列硬件要求 |

**DevEco CLI 的命令族**（来源 `ide-deveco-cli-options`，全量锚点）：
`help` / `init` / `auth login|status|team list|logout` / **`docs search|read|catalog`** / `create` / `build` / `build clean` / `signature generate` / `run` / `log` / **`check lint`** / **`check compat`** / `check compat versions` / `emulator …`（list/start/stop/create/delete/image/license/shake/power/rotate/volume/fold/battery/geolocation/scene/sensor）/ `device list|view` / `skills list|find|add|remove` / `ui …`（layout/window list/screenshot/click/doubleclick/longclick/swipe/fling/dircfling/drag/text）/ **`serve mcp`** / **`serve lsp`**

`devecocli init` 是关键入口：`--skill` 把 deveco-cli Skill 装进已检测到的智能体，`--mcp` 配置用户级或工程级（配合 `--project`）MCP 服务，`--agent <name>` 指定智能体，`-f` 覆盖重装。

### 对本项目意味着什么

- **`docs search` / `docs read` / `docs catalog` 是官方版的文档检索通道**，功能上与本仓 `tools/hwdoc.py` 重叠。装上 DevEco CLI 后，它可作为**同源交叉验证手段**（同为 A 类来源），但 `hwdoc.py` 不需要装任何鸿蒙工具，短期仍是本项目唯一可用的取证方式。
- **`check compat`（对目标 SDK 版本做 API 变更扫描）与 `check lint` 正好命中本项目最怕出错的地方**：API 起始版本、废弃 API、ArkTS 语法。这意味着「AI 写错鸿蒙 API」这件事**存在官方的机器校验手段**，是 `docs/03-arkts-codegen-rules.md` 未来最值得对接的验证器。
- **`serve mcp` / `serve lsp` 说明华为主动把鸿蒙能力开放给第三方 Agent**，Ducc 这类外部 Agent 不必绑定 DevEco Studio 的 IDE 内 AI，路线上是被官方支持的。
- **但它们都不解决本机无工具链的问题**：编译、推包、签名仍要 DevEco Studio 或 Command Line Tools 提供底层工具。DevEco Code 明说不装 IDE 会影响编译构建与推包；DevEco CLI 在 Linux 上也必须指向一份 `command-line-tools`。
- **旧资料排雷**：指南中「使用 AI 智能辅助编程」整节（`ide-codegenie` / CodeGenie，含智能问答、页面生成、万能卡片生成、自定义智能体配置等）在目录标题上已被官方标注**（不推荐）**。⚠️ 但 `ide-tools-overview`（displayUpdateTime 2026-06-15）正文仍把「CodeGenie AI 辅助编程」列为 IDE 特性，两处口径不一致；遇到 2026 年中以前的 AI 编程资料应默认按过时处理。

## 标准工程结构

Stage 模型的 ArkTS 工程结构，**支持 API Version 10 及以上**。来源 `ide-project-structure`（version=V108，更新 2026-08-28）与 `application-package-structure-stage`（version=V235，更新 2026-08-31），均为 A 类。

⚠️ 原文的目录树是**截图**，`hwdoc.py` 取不到图片。下面的树是**按原文条目列表逐条还原**的，路径与文件名逐个对得上原文，但**层级缩进属于重建，不是官方原样**。

```
MyApplication/                       # 工程根目录
├── AppScope/                        # DevEco Studio 自动生成，目录名不可改（改名会导致配置和资源加载失败）
│   ├── app.json5                    # 应用全局配置
│   └── resources/                   # 应用级资源
├── entry/                           # 模块（Module）目录；名字可由 IDE 生成（entry/library…）也可自定义
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/                 # ArkTS 源码（.ets）
│   │   │   │   ├── entryability/    # 应用/元服务入口
│   │   │   │   ├── entrybackupability/  # 扩展备份恢复能力
│   │   │   │   └── pages/           # 页面
│   │   │   ├── resources/
│   │   │   │   ├── base/element/    # boolean/color/float/intarray/integer/pattern/plural/strarray/string.json
│   │   │   │   ├── base/media/      # .png/.gif/.mp3/.mp4 等
│   │   │   │   └── rawfile/         # 任意格式原始资源，按路径+文件名引用，不做设备状态匹配
│   │   │   └── module.json5         # 模块配置
│   │   ├── mock/                    # 测试框架 Mock 配置
│   │   ├── ohosTest/                # Instrument Test
│   │   └── test/                    # Local Test
│   ├── build-profile.json5          # 模块级：模块信息、buildOption、targets
│   ├── hvigorfile.ts                # 模块级构建任务脚本
│   ├── obfuscation-rules.txt        # 混淆规则（Release 编译时生效）
│   └── oh-package.json5             # 模块依赖：包名、版本、入口（类型声明）、依赖项
├── oh_modules/                      # 三方库依赖的落地目录
├── build-profile.json5              # 应用级：签名、产品（products）配置等
├── code-linter.json5                # 代码检查范围与生效规则
├── hvigorfile.ts                    # 应用级构建任务脚本
├── oh-package.json5                 # 全局配置：overrides / overrideDependencyMap / parameterFile
└── oh-package-lock.json5            # 锁定应用级依赖版本 + 缓存依赖元数据
```

C++（Stage 模型）工程在此基础上多出：`entry/libs/{abi}/`（放 `.so`，`{abi}` 如 `arm64-v8a`，默认打进产物）、`entry/src/main/cpp/`（`CMakeLists.txt`、`napi_init.cpp`、`types/libentry/index.d.ts`、`types/libentry/oh-package.json5`）。

### 关键文件作用

| 文件 / 目录 | 层级 | 作用 | 来源 slug |
| --- | --- | --- | --- |
| `AppScope/app.json5` | 应用级 | 应用全局配置：`bundleName`、`versionCode`、`versionName`、`icon`、`label`、`minAPIVersion`、`targetAPIVersion`、`debug`、`multiAppMode`、`alternateIcons`、`appEnvironments` 等。**每个工程必须有且仅有一个** | `app-configuration-file`、`ide-project-structure` |
| `entry/src/main/module.json5` | 模块级 | 模块基本信息与运行期声明：`name`、`type`、`mainElement`、`deviceTypes`、`pages`、`abilities`、`extensionAbilities`、`skills`、`requestPermissions`、`dependencies`、`routerMap` 等。**每个模块必须有一个** | `module-configuration-file` |
| `build-profile.json5`（工程级） | 应用级 | 签名（`signingConfigs`）与产品（`products`：`compileSdkVersion`/`targetSdkVersion`/`compatibleSdkVersion`/`runtimeOS`）、`buildOption`、`packOptions`、`arkOptions`、`strictMode`、`externalNativeOptions` 等 | `ide-hvigor-build-profile-app` |
| `build-profile.json5`（模块级） | 模块级 | 当前模块信息与编译信息：`buildOption`、`targets`、`nativeLib` 等 | `ide-hvigor-build-profile` |
| `hvigorfile.ts` | 两级各一份 | 编译构建任务脚本，可自定义构建工具版本与构建行为参数 | `application-package-structure-stage` |
| `oh-package.json5` | 两级各一份 | 模块级=依赖声明（包名/版本/入口/依赖项）；工程级=全局依赖治理（`overrides`、`overrideDependencyMap`、`parameterFile`） | `ide-project-structure`、`ide-oh-package-json5` |
| `oh-package-lock.json5` | 工程级（C++ 工程另在模块级列出） | 锁定依赖版本 + 缓存依赖元数据 | `ide-project-structure` |
| `code-linter.json5` | 应用级 | 代码检查范围与生效规则 | `ide-project-structure` |
| `obfuscation-rules.txt` | 模块级 | 混淆规则；Release 编译时做编译+混淆+压缩 | `ide-project-structure` |
| `oh_modules/` | 应用级 | 三方库依赖落地目录（ohpm 用软链接构建依赖关系） | `ide-project-structure`、`ide-ohpm-system-platform` |

### 开发态 → 编译态 → 发布态

来源 `application-package-structure-stage`（A）：

- `ets/` 源码编译为 `.abc` 字节码。
- `AppScope/resources` **合入**模块资源目录；**重名文件只保留 AppScope 版本**。
- `AppScope/app.json5` 的字段**合入**模块的 `module.json5`，编译后生成最终的 `module.json`。
- 模块按类型编译为 `.hap` / `.har` / `.hsp`；HAR 会被**直接编译进** HAP/HSP，所以打成 APP 后只有 `.hap` 与 `.hsp`。
- 一个应用的全部 `.hap` + `.hsp` 合称 **Bundle**，`bundleName` 是应用唯一标识；上架时打成一个 `.app` 文件（**App Pack**），并自动生成 `pack.info` 描述各 HAP/HSP 属性。App Pack 是上架应用市场的基本单元。

## 开发环境要求

### 操作系统

| 目标 | 支持的 OS | 备注 |
| --- | --- | --- |
| **DevEco Studio** | Windows 10 64 位 / Windows 11 64 位；**macOS(X86) 11/12/13/14/15、macOS(ARM) 12/13/14/15** | **没有 Linux 版**。macOS 是一等支持。Windows 建议内存 16GB+，macOS 8GB+；两者硬盘均 100GB+，分辨率 1280×800+ |
| **Command Line Tools** | Windows / macOS / Linux | Linux 侧要求：64 位、**GLIBC 2.28+**、内存最小 8GB（推荐 16GB+）、硬盘 100GB+ |
| **hdc** | Windows / Linux / macOS | — |
| **ohpm** | Windows（NTFS）/ macOS（APFS）/ Linux（EXT4、Btrfs、XFS、ZFS） | 依赖符号链接；FAT32/exFAT 等不支持符号链接的文件系统不可用；Windows 下源码依赖不允许跨盘符 |
| **DevEco Code** | Windows 11 22H2+ / macOS 15 Sequoia+ | macOS 需 Zsh；Windows 需 PowerShell 5.1+（推荐 7+） |
| **DevEco CLI** | Windows / macOS / Linux（Linux 自 1.3.0 起） | — |
| **模拟器** | Windows(X86) / macOS(ARM) | **macOS 只支持 Apple Silicon，不支持 Intel 芯片**；macOS 12.5+；两平台都不支持在虚拟机里跑；不支持 ARM CPU 的 Windows |

DevEco Studio 是「开箱即用」打包：HarmonyOS SDK、Node.js、Hvigor、OHPM、模拟器平台**合一分发，无需另装**。SDK 位于安装目录 `sdk`（macOS 在 `Contents` 下）。若要做 OpenHarmony 应用开发，需另在 `File > Settings > OpenHarmony SDK` 下载 OpenHarmony SDK。IDE 依赖网络，企业受限网络需配代理。

### 模拟器额外要求

- Windows：Windows 10 企业版/专业版/教育版及以上且系统版本 ≥ 10.0.18363；CPU 需 64 位 + SLAT + AES 指令集 + VM 监视器模式扩展（Intel VT-c）、2017 年后型号；RAM 最低 16GB（推荐 32GB+）；磁盘最低 16GB（推荐 32GB+）；GPU 支持 OpenGL 4.1。
- macOS：RAM 最低 8GB（推荐 16GB+）。
- 支持的设备类型：Phone（直板 / 双折叠 / 阔折叠 / 三折叠）、Tablet、2in1、2in1 Foldable、Wearable、WearableKid、TV、**Car（26.0.0 起）**。其中 Phone / Tablet / 2in1 / TV / Car **仅支持在中国境内（不含港澳台）使用**；Wearable / WearableKid 未标此限制。
- 用 x86 模拟器时，C++ 工程与三方库必须编译出 `x86_64` 版 `.so`（在 `build-profile.json5` 的 `externalNativeOptions.abiFilters` 中加 `"x86_64"`）。

### 账号、认证与签名（这是真机调试的真正门槛）

来源 `application-dev-overview`、`ide-signing`、`ide-signing-auto`、`ide-run-device`、`ide-command-line-building-app`，均为 A 类。

- **必须注册华为开发者联盟账号并完成实名认证**，才能使用联盟开放的能力与服务；再到 AppGallery Connect（AGC）创建项目与 HarmonyOS 应用。
- **模拟器与预览器调试无需配置签名**；**真机调试必须对 HAP 签名**。
- 签名两条路：
  - **自动签名**：覆盖大部分调试场景。分「关联注册应用」（DevEco Studio 6.0.0 Beta5 起支持，与 AGC 应用绑定，可在 IDE 里开通开放能力与 ACL 权限）与「未关联注册应用」。要求**本地系统时间与北京时间（UTC+8）一致**，否则签名失败。DevEco Studio 6.1.1 Beta1 及以上，关联注册应用的自动签名支持各国家/地区；更低版本仅支持中国境内（不含港澳台）。26.0.0 起支持在 AGC 注册设备后再签名。
  - **手动签名**：跨设备调试、跨应用交互调试、断网调试、多人共享密钥、Kit 需配置指纹等场景**必须**用。需要三件套：密钥 `.p12`、数字证书 `.cer`、Profile `.p7b`；`.p12` 用 JDK 的 `keytool` 生成（`-keyalg EC -groupname secp256r1 -sigalg SHA256withECDSA`）。
- 真机调试还需：设备系统 **≥ HarmonyOS NEXT Developer Beta1**；在「设置 > 具体设备名称」连点软件版本 7 次开启开发者选项，再开 USB 调试。Wearable 仅支持无线连接，Lite Wearable 不支持真机运行。无线连接从 DevEco Studio 6.1.1 Release(6.1.1.300) 起可用 `Tools > IP Connection`。
- 若用到 Account Kit / Game Service Kit / Health Service Kit 等开放能力，需**预先添加公钥指纹**才能正常调试。
- **发布到应用市场必须用应用市场颁发的发布证书签名。**

### 地域限制（会影响能不能用）

`ide-tools-overview` 明列以下功能**仅支持中国境内（不含港澳台）**：Partner SDK、Template Market 模板市场、端云一体化工程创建与开发、软件包及符号表上传、日志回传、Operation Analyzer 运维服务、AppAnalyzer 体检、AI 辅助编程工具 DevEco CodeGenie、OHPM Index 开源中心仓、API 变更查询。

## 在没有 DevEco Studio 的机器上能做什么

本机实测（2026-09-01）：macOS 15.7.3 (24G419) / arm64 / `node v24.6.0` / `npm 11.5.1` / `python3 3.9.6`；`java` 未安装；`hvigorw` `ohpm` `hdc` `codelinter` `deveco` `devecocli` 全部 `NOT FOUND`；`/Applications/DevEco-Studio.app` 不存在。

> **⚠️ 下面这张表是 2026-09-01 的快照，已被 2026-09-03 的实测大幅推翻。**
> 现状：DevEco CLI + JDK 21 + 免登录 OpenHarmony 编译链（hvigor 6.26.1 + ohpm + Node 22 + SDK 23）
> 都装在 `~/.local/hmos-toolchain/`，**「编译构建 HAP」「安装依赖」「生成官方标准工程骨架」三项已从
> 「不能做」变成「已做到」** —— `harmony/HybridShell/` 出了 110,930 B 的 HAP。
> 仍然不能做的是：**HarmonyOS SDK 上编译**（需人登录下载 CLT）、**静态检查**（该 CLT 包内无 codelinter 实体）、
> **真机/模拟器运行**（无设备）、**签名到发布**（无 AGC 证书）。见 `harmony/README.md`。

**硬件与系统层面本机是够的**：macOS 15 ≥ DevEco Studio 的 macOS(ARM) 12-15 要求、≥ DevEco Code 的 macOS 15+ 要求；Apple Silicon 满足模拟器「只支持 Apple Silicon」的要求；Node 24.6.0 ≥ DevEco Code/CLI 要求的 22+。**缺的只是没装。**

| 能做 | 不能做 |
| --- | --- |
| 用 `tools/hwdoc.py` 直连文档中心 JSON 接口取证（零鸿蒙依赖），把事实沉淀进 `docs/` | 编译构建 HAP / HSP / APP —— 缺 `hvigorw` + HarmonyOS SDK + JDK |
| 写 ArkTS / `.ets` 源码与 `app.json5` / `module.json5` / `build-profile.json5` 草稿，**一律标注「未编译验证」** | 安装依赖 —— 缺 `ohpm`，`oh_modules/` 无法生成 |
| 做版本 ↔ API Level ↔ SDK 对照、Kit 能力调研、架构设计 | 跑静态检查 —— 缺 `codelinter`（也就无法用 `@compatibility/*` 规则验证 API 起始版本） |
| 积累 `docs/03-arkts-codegen-rules.md`（AI 易错点），本项目最有复用价值的产出 | 真机 / 模拟器运行调试 —— 缺 SDK、`hdc`、模拟器镜像 |
| 读官方给出的**准确字段名与格式**（如三个 SdkVersion 字段、`runtimeOS`），避免凭印象 | 签名 —— 缺 `keytool`（无 JDK）、缺 AGC 的 `.cer`/`.p7b`、缺 IDE 的自动签名入口 |
| 装 **DevEco CLI / DevEco Code**（`npm i -g @deveco/deveco-cli@stable` / `@deveco/deveco-code@stable`），环境要求已满足 | UI 实时预览 / 双向预览 —— 预览器只存在于 DevEco Studio 内 |
| 用 DevEco CLI 的 `docs search|read|catalog` 做官方文档检索，与 `hwdoc.py` 交叉验证 | 断言任何代码「已验证可运行」——**这条是纪律，不是能力问题** |
| **补齐路径（推荐）**：装 Command Line Tools（macOS 支持）+ JDK 21，即可 `hvigorw` 构建、`ohpm` 装依赖、`codelinter` 检查、`hdc` 连设备，**全程不需要 DevEco Studio** | 生成「官方标准」工程骨架 —— 工程由 IDE 模板生成；`CLAUDE.md` 也明确禁止在 `harmony/` 下造半成品 |

**关键判断**：本项目卡住的不是「没有 IDE」，而是「没有 Command Line Tools + JDK」。官方明确支持纯命令行构建（`ide-command-line-building-app` 整篇就是讲 CI 流水线，且说「在调用命令行任务上，Windows/macOS 与 Linux 没有区别」），Hvigor 也明确「可独立于 DevEco Studio 运行」。因此**「装 Command Line Tools + JDK 21」是让本项目从纯调研跨到可编译验证的最小一步**，代价是需要华为账号登录下载中心。而**真机运行**这一步绕不过实名认证与 AGC 签名材料。

## 未确认 / 待核实

| # | 待核实项 | 已查过哪里 |
| --- | --- | --- |
| 1 | **HarmonyOS 7.0.0 正式版（非 Beta）是否已向公众设备推送**。官方只有将来时表述「HarmonyOS 7.0 将陆续面向全网 HarmonyOS NEXT 设备发布」 | `upgrade-adaptation`、`sdk-version-percentage`（快照 2026-08-20 仍只有 7.0.0 Beta2）、`support-device` |
| 2 | **26.0.0 发布日期 2026/08/28 与 2026/08/29 冲突**，两个 A 类页面不一致，未找到调和说明 | `overview-allversion` vs `overview-2600` |
| 3 | **是否存在过 API 25 / HarmonyOS 6.2**。官方版本清单从 `6.1.1(24)` 直接跳到 `26.0.0`；releases 目录树里 26.0.0 的子节点 slug 用 `7001/7002/7003`（= 7.0.0 Beta1/Beta2/Release），暗示内部沿用 HarmonyOS 7 序列，但**没有任何官方文字说明 API 25 是否被跳过或如何映射** | `overview-allversion`、`version-number-26`、`harmonyos-releases` 全量目录树 |
| 4 | **「HarmonyOS 7.0.0 Release」是否为官方正式 OS 版本号写法**。文档里只见 `7.0.0 Beta2` 与「HarmonyOS 7.0」两种写法 | `sdk-version-percentage`、`upgrade-adaptation` |
| 5 | **下载页上实际可下载的最新 DevEco Studio 版本号**。本文的 26.0.0.821 来自文档，未打开下载页核实（下载中心页面需登录，`hwdoc.py` 只覆盖文档中心） | `https://developer.huawei.com/consumer/cn/download/deveco-studio` 未访问 |
| 6 | **hdc 版本配套表**具体内容（哪个 hdc 版本配哪个设备 API 版本） | `hdc` 页有该锚点，未取正文 |
| 7 | **HarmonyOS 5.x / 6.x 的维护与 EOL 政策**。只查到「建议直升 6.0.0(20)」的使用建议，无生命周期承诺 | `overview-allversion` |
| 8 | **Command Line Tools 在 macOS(ARM) 上的最低系统版本 / 具体包名**。官方只给了 Linux 的系统平台要求，macOS 侧仅说「根据实际情况下载对应版本」 | `ide-commandline-get`、`ide-command-line-building-app` |
| 9 | **DevEco Code 的「Agent 模式」与「Goal 模式」区别** | 未读 `ide-deveco-code-agent`、`ide-deveco-code-options` |
| 10 | **模块级 `oh-package-lock.json5` 在 ArkTS 工程中是否存在**。ArkTS 工程结构未列，C++ 工程结构列出了 | `ide-project-structure` |
| 11 | **本机 Node v24.6.0 与官方配套 24.14.1 不一致是否有实际影响** | 无法验证（未装工具链） |
| 12 | **元服务（Atomic Service）与应用在工程结构、签名、上架上的差异**，本文未覆盖 | 未查 |
| 13 | `hwdoc.py` 的 `versionLabels` 恒为 `hmos-503` 的**真实语义**（是站点常量还是遗留字段） | 已交叉验证它与内容版本无关，但未找到官方解释 |

## 来源

URL 拼法：`https://developer.huawei.com/consumer/cn/doc/<catalog>/<slug>`。全部经 `tools/hwdoc.py` 于 **2026-09-01** 取回，`version` / `updated` 为接口返回的文档自身元信息。

### A 类：华为官方文档 — `harmonyos-releases`（版本说明）

| 主题 | 标题 | slug | version | updated |
| --- | --- | --- | --- | --- |
| 26.0.0 版本信息与配套 | 版本概览 | `overview-2600` | V6 | 2026-08-29 |
| 版本号格式规则 | 版本号格式调整说明 | `version-number-26` | V5 | 2026-08-29 |
| 全量版本 ↔ API ↔ IDE 对照 | 所有 HarmonyOS 开发套件版本 | `overview-allversion` | V51 | 2026-08-29 |
| 现网设备 API 分布 | 存量设备 API 版本使用数量参考 | `sdk-version-percentage` | V43 | 2026-08-29（数据截至 2026-08-20） |
| 各版本配套设备型号 | 各版本支持设备型号清单 | `support-device` | V62 | 2026-08-29 |
| OS 版本 / NEXT 措辞 / 升级流程 | 应用升级适配指导——向 26.0.0 升级 | `upgrade-adaptation` | V49 | 2026-08-29 |
| 三个 SdkVersion 字段语义 | 影响应用兼容性的关键信息 | `app-compatibility-influence-factor` | V30 | 2026-08-29 |
| DevEco Studio 26.0.0 配套版本号 | 新增和增强特性 | `deveco-studio-new-features-2600` | V6 | 2026-08-29 |
| 「HarmonyOS NEXT」历史命名证据 | 版本概览（5.0.0(12)） | `overview-500` | V47 | 2026-08-29 |
| 兼容性总入口 | 应用兼容性说明 | `app-compatibility` | V43 | 2026-08-29 |

### A 类：华为官方文档 — `harmonyos-guides`（开发指南）

| 主题 | 标题 | slug | version | updated |
| --- | --- | --- | --- | --- |
| IDE 下载 / OS 要求 | 下载与安装 DevEco Studio | `ide-software-install` | V108 | 2026-08-28 |
| 工具全景 / 地域限制 | 工具概述 | `ide-tools-overview` | V112 | 2026-08-28（显示更新 2026-06-15） |
| 工程目录结构 | 工程目录结构介绍 | `ide-project-structure` | V108 | 2026-08-28 |
| 开发态/编译态/发布态包结构 | 应用程序包结构 | `application-package-structure-stage` | V235 | 2026-08-31 |
| app.json5 字段 | app.json5 配置文件 | `app-configuration-file` | V235 | 2026-08-31 |
| module.json5 字段 | module.json5 配置文件 | `module-configuration-file` | V235 | 2026-08-31 |
| 工程级构建配置 / SdkVersion 格式 | 工程级 build-profile.json5 文件 | `ide-hvigor-build-profile-app` | V107 | 2026-08-28 |
| Hvigor 是什么 / 可独立运行 | 概述（构建应用） | `ide-hvigor` | V107 | 2026-08-28 |
| Hvigor 各版本变更 | 版本说明（Hvigor） | `ide-hvigor-releasenote` | V23 | 2026-08-28 |
| hvigorw 命令与路径约束 | 命令行构建工具（hvigorw） | `ide-hvigor-commandline` | V113 | 2026-08-28 |
| SDK 内命令行工具清单 | SDK 命令行工具简介 | `command-line-tools-overview` | V178 | 2026-08-31 |
| Command Line Tools 获取与配置 | 获取 Command Line Tools | `ide-commandline-get` | V110 | 2026-08-28 |
| 纯命令行构建 / JDK / Node / 签名三件套 | 搭建流水线 | `ide-command-line-building-app` | V114 | 2026-08-28 |
| hdc 定位、端口、获取路径 | hdc | `hdc` | V237 | 2026-08-31 |
| ohpm 定位 | 三方依赖管理工具（ohpm） | `ide-ohpm-cli` | V110 | 2026-08-28 |
| ohpm 系统与文件系统要求 | 系统平台要求 | `ide-ohpm-system-platform` | V110 | 2026-08-28 |
| DevEco Code 定位（OpenCode + BitFun） | 工具概述 | `ide-deveco-code-overview` | V6 | 2026-08-28 |
| DevEco Code 环境要求与安装 | 下载与安装 | `ide-deveco-code-install` | V6 | 2026-08-28 |
| DevEco Code 版本 | 版本说明 | `ide-deveco-code-releasenote` | V1 | 2026-08-28 |
| DevEco CLI 定位 | 工具概述 | `ide-deveco-cli-overview` | V6 | 2026-08-28 |
| DevEco CLI 环境与安装 | 快速入门 | `ide-deveco-cli-install` | V6 | 2026-08-28 |
| DevEco CLI 版本与新特性 | 版本说明 | `ide-deveco-cli-releasenote` | V1 | 2026-08-28 |
| DevEco CLI 全量命令 | 命令 | `ide-deveco-cli-options` | V6 | 2026-08-28 |
| 实名认证 / AGC / 签名前提 | 应用开发准备 | `application-dev-overview` | V225 | 2026-08-31 |
| 调试签名两条路 | 配置调试签名 | `ide-signing` | V111 | 2026-08-28 |
| 自动签名约束 | 自动签名 | `ide-signing-auto` | V1 | 2026-08-28 |
| 真机调试前提 | 使用本地真机运行应用 | `ide-run-device` | V107 | 2026-08-28 |
| 模拟器定位 | 概述（模拟器） | `ide-emulator-overview` | V107 | 2026-08-28 |
| 模拟器硬件要求 | 使用环境 | `ide-emulator-requirements` | V109 | 2026-08-28 |
| 模拟器设备类型与地域限制 | 设备支持类型 | `ide-emulator-devicetype` | V103 | 2026-08-28 |
| CodeGenie 已标「不推荐」 | 目录节点「使用 AI 智能辅助编程（不推荐）」 | 目录树，节点下首篇为 `ide-codegenie` | — | 目录树取自 2026-09-01 |

### A 类：华为官方文档 — `harmonyos-references`（API 参考）

| 主题 | 标题 | slug | version | updated |
| --- | --- | --- | --- | --- |
| API 版本标记规则 / SysCap / Kit 导入 | 开发说明 | `development-intro-api` | V233 | 2026-08-31 |

### B 类：媒体对官方发布会的转述（仅用于交叉印证 HarmonyOS 7 Beta 的时间点）

| 主题 | 标题 | URL | 可信度 |
| --- | --- | --- | --- |
| HDC.2026 发布 HarmonyOS 7 Developer Beta / API 26 | HarmonyOS 7 developer beta 1 upgrades platform to API 26 | `https://www.huaweicentral.com/harmonyos-7-developer-beta-1-upgrades-platform-to-api-26/` | B |
| 同上 | Huawei Launches HarmonyOS 7 Developer Beta With Upgraded API 26（2026-06-12） | `https://dataconomy.com/2026/06/12/huawei-harmonyos-7-developer-beta-api-26/` | B |
| HarmonyOS 7 Developer Beta 支持机型与新特性 | HarmonyOS 7 Developer Beta: Supported models, new features | `https://nokiapoweruser.com/harmonyos-7-developer-beta-hdc-2026/` | B |

媒体口径与官方口径的差异已在「结论摘要」第 4 条写明：官方不写「API 26」，写「API 版本 26.0.0」。

### 本机实测（非文档来源）

`sw_vers` / `uname -m` / `command -v` 于 2026-09-01 在本机执行，结果见「在没有 DevEco Studio 的机器上能做什么」开头。







