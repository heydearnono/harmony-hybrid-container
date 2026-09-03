# 术语表

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 全部经 `tools/hwdoc.py` 取正文，访问日期 2026-09-01

## 最容易混的几组

| 容易混的一组 | 区别一句话 | 依据 slug |
| --- | --- | --- |
| HarmonyOS / HarmonyOS NEXT / OpenHarmony | HarmonyOS 是操作系统本体；HarmonyOS NEXT 是 2024 年「全新架构」发布时的命名（首个 Release 5.0.0，2024-10-22）；OpenHarmony 是 2020 年捐给开放原子开源基金会的开源项目，是 NEXT 架构的**操作系统底座** | `glossary` |
| Stage 模型 / FA 模型 | Stage 是当前主推（API 9 起），多组件共享一个 ArkTS 引擎实例；FA 是早期模型（API 7 起），每组件独享引擎实例，官方口径是「已不再主推」，**不是「已废弃」** | `ability-terminology`、`stage-model-development-overview` |
| UIAbility / ExtensionAbility / AbilityStage | 前两个是 Stage 模型的「组件类型」（带 UI / 特定场景扩展），AbilityStage 是 **Module 级别的组件管理器**，不是组件 | `glossary`、`ability-terminology` |
| HAP / HAR / HSP | HAP 是安装运行的基本单元（.hap）；HAR 编译态复用（.har，多包引用会重复拷贝）；HSP 运行时复用（.hsp，不重复拷贝） | `application-package-glossary` |
| app.json5 / module.json5 | app.json5 应用级、位于 `AppScope/`、全工程唯一；module.json5 模块级、位于 `<模块>/src/main/`、每模块一个。编译后两者合并成 `module.json` | `app-configuration-file`、`module-configuration-file`、`application-configuration-file-overview-stage` |
| Hvigor / hvigorw | Hvigor 是构建任务编排工具本体；hvigorw 是它的 wrapper，负责自动安装 Hvigor 与插件依赖并执行构建命令 | `ide-hvigor`、`ide-hvigor-commandline` |
| DevEco CLI / Command Line Tools | DevEco CLI 是面向 **AI Agent** 的命令行接口封装（工具集＋知识库＋Skills）；Command Line Tools 是流水线用的工具合集（codelinter / ohpm / hstack / hvigorw） | `ide-deveco-cli-overview`、`ide-tools-overview` |
| Core Speech Kit / Speech Kit | Core = 基础语音 AI 能力接口（TextToSpeech、SpeechRecognizer）；无 Core = 场景化，直接给控件（TextReader 朗读控件、AICaptionComponent AI 字幕控件） | `core-speech-introduction`、`speech-production` |
| Core Vision Kit / Vision Kit | Core = 机器视觉基础能力（OCR、人脸检测/比对、主体分割）；无 Core = 场景化控件与服务（人脸活体检测、卡证识别、文档扫描、AI 识图控件） | `core-vision-introduction`、`vision-introduction` |
| API 版本 / API level | 当前官方中文文档统一说「API 版本」；「API level」只出现在 26.0.0 之前 `X.Y.Z(N)` 格式的 N 字段释义里，指 **OpenHarmony 底座 API level** | `version-number-26` |

## 词条

### 系统与生态

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| HarmonyOS | 「新一代的智能终端操作系统，为不同设备的智能化、互联与协同提供了统一的语言」 | 术语页同条目内补充：2024 年以全新架构发布并命名 HarmonyOS NEXT | `glossary` |
| HarmonyOS NEXT | 官方术语表**没有独立词条**；仅在 HarmonyOS 条目内写：「2024年HarmonyOS以全新架构发布，命名为HarmonyOS NEXT」，2024-06-21 首个 Developer Beta，2024-10-22 首个 Release（5.0.0），「采用OpenHarmony作为操作系统底座，并通过OpenHarmony兼容性标准认证」 | 26.0.0 与 6.x 的版本文档通篇只用「HarmonyOS + API 版本号」，「HarmonyOS NEXT」只残留在 5.0.0(12) 时期的 changelog/apidiff 节点名中 → **当前不宜用它指代版本（本项目推论）** | `glossary`、`overview-2600`、`overview-allversion` |
| OpenHarmony | 「2020年，华为将HarmonyOS基础能力捐赠给开放原子开源基金会，形成OpenHarmony开源项目。OpenHarmony能够提供操作系统底层能力，包括应用框架及UI框架，基础服务…基础应用…」 | 是底座与开源项目，不是华为商用发行版；26.0.0 起版本号体系与 OpenHarmony 统一 | `glossary`、`version-number-26` |

### 版本、SDK 与兼容性

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| API 版本 | 「HarmonyOS开发套件版本号统一采用API版本进行描述。API版本号可在搭载HarmonyOS的设备的设置中查询」（设置 > 关于本机 > API版本） | 「对应用兼容性起到决定因素的是API版本」 | `version-number-26`、`app-compatibility-intro` |
| 版本号格式（26.0.0 起） | 语义化版本 SemVer `X.Y.Z`：X 主版本（含重要变更，可能需适配）／Y 次版本（新功能，原则上向后兼容）／Z 修订版本（修复，向后兼容） | 26.0.0 是首个完全语义化的版本 | `version-number-26` |
| 版本号格式（26.0.0 之前） | `X.Y.Z(N)`，X 主／Y 次／Z 修订（各 0–99），**N＝OpenHarmony 底座 API level（1–99）** | 例：`6.1.1(24)`、`5.0.5(17)`。官方给出的大小关系：26.0.0 > 6.1.1(24) > 6.1.0(23) > 6.0.2(22) > 6.0.1(21) > 6.0.0(20) > 5.1.1(19) > 5.1.0(18) > 5.0.5(17) | `version-number-26`、`app-compatibility-influence-factor` |
| SDK | 「用于创建应用软件的开发工具和开放能力的集合」 | HarmonyOS SDK 自 Kit 维度组织开放能力 | `glossary`、`application-dev-guide` |
| compileSdkVersion | 「编译应用工程的SDK版本，该字段决定了应用开发过程中可自动联想的API范围和使用的工具链版本」；配在 build-profile.json5，打包后落到 module.json5 同名字段 | 只能配成当前 DevEco Studio 自带的 SDK 版本 | `app-compatibility-influence-factor` |
| targetSdkVersion | 「应用运行的目标SDK版本」；打包后字段名变为 **targetAPIVersion** | 决定经过 API 版本隔离的行为按哪个版本呈现 | `app-compatibility-influence-factor` |
| compatibleSdkVersion | 「应用运行要求的最低SDK版本」；打包后字段名变为 **minAPIVersion** | 设备 API 版本低于此值无法安装；不能高于目标 SDK 版本 | `app-compatibility-influence-factor` |
| API 参考里的起始版本标记 | 「本模块首批接口从API version 7开始支持」（模块级）；「uid8+」（特性级）。另有各设备类型的起始版本标记 | 废弃接口用上标 `deprecated` 标注，并标废弃起始版本；官方说明「未来可能移除」但会提前通知 | `development-intro-api` |

### 语言与框架

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| ArkTS | 「HarmonyOS应用的默认开发语言，在TypeScript（简称TS）生态基础上做了扩展，保持TS的基本风格」 | 自 API version 10 起进一步强化静态检查：强制静态类型、禁止运行时改对象布局、限制运算符语义、不支持 structural typing | `arkts-get-started` |
| ArkUI | 「方舟开发框架，是为HarmonyOS平台开发极简、高性能、跨设备应用设计研发的UI开发框架」 | 名字里没有 Kit；文档里 ArkUI 与「方舟开发框架」同指 | `glossary` |
| ArkCompiler | 「方舟编译器，是华为自研的统一编程平台，包含编译器、工具链、运行时等关键部件」 | 产物是 `.abc`（方舟字节码），发布态打进 HAP | `glossary`、`arkts-glossary` |
| ArkTS 声明式开发范式 | ArkUI 提供的两种开发范式之一：「基于ArkTS的声明式开发范式（简称"声明式开发范式"）」，ArkTS 语言 + 数据驱动更新；另一种是「兼容JS的类Web开发范式」（JS 语言，界面较简单的程序和卡片） | 写 UI 代码前先确认范式，两者语法完全不同 | `start-overview`、`arkts-ui-development-overview` |

### 应用模型与组件

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| Stage 模型 | 「当前系统主推的应用模型…提供了AbilityStage组件管理器和WindowStage窗口管理器，分别作为应用组件与窗口的"舞台"，故得名"Stage模型"」；支持多组件共享同一 ArkTS 引擎实例 | **从 API 9 开始支持**，「主推且会长期演进」；「除非另有说明，文档中提及的"应用模型"均指"Stage 模型"」 | `ability-terminology`、`stage-model-development-overview` |
| FA 模型 | 「早期的应用模型…每个应用组件独享一个ArkTS引擎实例，适用于简单应用的开发。目前该模型已不再主推」 | **从 API 7 开始支持；官方措辞是「不再主推」而非「废弃」**，「当前FA模型主要用于Lite Wearable设备」。⚠️ 未查到废弃/移除的起始版本号 | `ability-terminology`、`stage-model-development-overview` |
| Ability | ⚠️ 未在官方术语页检索到「Ability」的独立定义（术语页只定义 UIAbility / ExtensionAbility / AbilityStage / PageAbility） | API 参考里有 `@ohos.app.ability.Ability`（Ability 基类）。写文档时避免单独用「Ability」指代组件 | `ability-terminology`、`js-apis-app-ability-ability` |
| UIAbility | 「Stage模型中的组件类型名，即UIAbility组件，包含UI，提供展示UI的能力，主要用于和用户交互」；「是系统调度的基本单元，为应用提供绘制界面的窗口」 | 入口 UIAbility＝skills 的 entities 含 `entity.system.home` 且 actions 含 `ohos.want.action.home` | `glossary`、`ability-terminology`、`application-package-glossary` |
| ExtensionAbility | 「Stage模型中的组件类型名…提供特定场景（如卡片、输入法）的扩展能力」 | 「开发者并不直接从ExtensionAbility组件派生，而是需要使用ExtensionAbility组件的派生类」（FormExtensionAbility、InputMethodExtensionAbility 等）；三方应用不能开发自定义服务 | `glossary`、`stage-model-development-overview` |
| AbilityStage | 「AbilityStage是一个Module级别的组件管理器」 | 「每个Entry类型或者Feature类型的HAP在运行期都有一个AbilityStage实例」——它不是应用组件 | `ability-terminology`、`stage-model-development-overview` |
| PageAbility | 「FA模型下的包含UI、提供展示UI能力的应用组件」 | FA 侧对应 Stage 的 UIAbility，不要混写 | `ability-terminology` |

### 包、模块与配置文件

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| HAP | 「Harmony Ability Package，是应用安装和运行的基本单元…由代码、资源、第三方库及配置文件组成，文件后缀为.hap。分为entry和feature两种类型，支持独立安装和运行」 | — | `application-package-glossary` |
| HAR | 「静态共享包，用于编译态复用…文件后缀为 .har…可发布到OHPM…但多包引用会造成代码和资源重复拷贝」 | 由 Static Library 类型模块编译生成 | `application-package-glossary` |
| HSP | 「动态共享包，运行时复用…文件后缀为.hsp…多包引用时不会造成重复拷贝，有效控制应用包大小」 | 由 Shared Library 类型模块编译生成；另有「集成态HSP」解决 bundleName 与签名强耦合 | `application-package-glossary` |
| Bundle | 「一个应用中所有HAP与HSP文件的集合，其bundleName是应用的唯一标识」 | — | `application-package-glossary` |
| Module | 「应用的一部分，每个模块都有独立的module.json5配置文件…Entry、Feature、HSP和HAR均为应用模块」 | 分 Ability 类型（编译出 HAP）与 Library 类型（编译出 HAR/HSP） | `application-package-glossary`、`application-package-overview` |
| entry 模块 | 「应用的主模块，包含应用的入口界面、入口图标和主功能特性，编译后生成entry类型的HAP。每一个应用分发到同一类型的设备上的应用程序包，只能包含唯一一个entry类型的HAP，也可以不包含」 | 与 feature（动态特性模块，可多个）成对理解 | `application-package-overview` |
| AppScope | 「AppScope目录由DevEco Studio自动生成，该目录名称更改会导致当前目录下配置文件和资源加载失败，导致编译报错问题，因此该目录名称请勿修改」 | 存放 `app.json5` 与应用级 `resources`；不是术语页词条，定义取自工程结构文档 | `application-package-structure-stage`、`ide-project-structure` |
| app.json5 | 「应用级配置文件，包含应用的全局配置信息和特定设备类型的配置信息…每个工程下必须包含一个app.json5配置文件，文件所在目录为工程名称/AppScope/app.json5」 | 含 bundleName、应用名称、图标、版本号等 | `app-configuration-file` |
| module.json5 | 「模块级配置文件，包含模块的基本配置信息、UIAbility组件和ExtensionAbility组件信息，以及应用运行过程中需要的权限信息…文件所在目录为工程名称/模块名称（例如entry）/src/main/module.json5」 | 编译后 app.json5 与 module.json5 「会合并到一个module.json文件中」 | `module-configuration-file`、`application-configuration-file-overview-stage` |
| build-profile.json5 | 工程级：「应用级配置信息，包括签名、产品配置等」（app / signingConfigs / modules / products / buildModeSet 等）；模块级：apiType / targets / buildOption 等 | compileSdkVersion、targetSdkVersion、compatibleSdkVersion 配在这里 | `ide-project-structure`、`ide-hvigor-build-profile-app`、`ide-hvigor-build-profile` |
| oh-package.json5 | 「从OHPM 5.0.0版本开始，支持区分工程级与模块级」：工程级描述全局配置（overrides、overrideDependencyMap、parameterFile）；模块级「描述包名、版本、入口文件（类型声明文件）和依赖项等信息」 | 发布到中心仓的包必须含模块级 oh-package.json5；锁版本用 `oh-package-lock.json5` | `ide-oh-package-json5`、`ide-project-structure` |

### 工具链

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| DevEco Studio | 「HUAWEI DevEco Studio…基于IntelliJ IDEA Community开源版本打造，面向HarmonyOS应用/元服务开发场景的一站式集成开发环境」 | 26.0.0 的配套是 DevEco Studio 26.0.0 Release | `ide-tools-overview`、`overview-allversion` |
| Hvigor | 「编译构建工具DevEco Hvigor…一款基于TS实现的构建任务编排工具，主要提供任务管理机制…可独立于DevEco Studio运行」 | 完成 HAP/APP 的构建打包 | `ide-hvigor` |
| hvigorw | 「hvigorw作为Hvigor的wrapper包装工具，支持自动安装Hvigor构建工具和相关插件依赖，以及执行Hvigor构建命令」 | 用法 `hvigorw [taskNames...] <options>`；需先配 JDK、Node.js、hvigor 环境变量 | `ide-hvigor-commandline` |
| ohpm | 「ohpm作为OpenHarmony三方库的包管理工具，支持OpenHarmony共享包的发布、安装和依赖管理」；「ohpm是DevEco Studio默认的包管理工具」 | 私仓工具是 ohpm-repo | `ide-ohpm-cli`、`ide-tools-overview` |
| hdc | 「hdc（HarmonyOS Device Connector）是提供给开发人员的命令行调试工具，用于与设备进行交互调试、数据传输、日志查看以及应用安装等操作」 | 三部分：client（电脑端命令进程）／server（电脑端后台服务）／daemon（设备端） | `hdc` |
| Command Line Tools | 「针对流水线或命令行开发场景，推荐使用Command Line Tools命令行工具，其中集合了HarmonyOS应用开发所用到的系列工具，包括代码检查工具codelinter、三方包管理工具ohpm、堆栈解析工具hstack、命令行构建工具hvigorw」 | 与 DevEco CLI 是两个东西 | `ide-tools-overview`、`ide-commandline-get` |
| DevEco CLI | 「一款面向各类AI Agent使用的AI产品，将HarmonyOS工具集、HarmonyOS知识库和精品Skills封装为适配AI调用的命令行接口，全面开放给各类通用AI开发工具（如Cursor、OpenCode等）」 | 需 DevEco Studio 6.0.0 及以上；1.3.0 起支持 Linux。**对本项目最相关的工具** | `ide-deveco-cli-overview`、`ide-deveco-cli-install` |

### Kit 与开放能力

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| Kit | 「是一个功能内聚的开放能力集合，可以支撑开发者完成一个特定场景的功能开发」 | 「从HarmonyOS NEXT Developer Preview1（API 11）版本开始，HarmonyOS SDK以Kit维度提供丰富、完备的开放能力，涵盖应用框架、系统、媒体、图形、应用服务、AI六大领域」 | `glossary`、`application-dev-guide` |
| `@kit.*` 导入约定 | 「从HarmonyOS NEXT Developer Preview 1版本开始引入Kit概念。SDK对同一个Kit下的接口模块进行了封装…**在代码开发中，推荐通过导入Kit方式使用开放能力**」 | 三种写法：`import { UIAbility } from '@kit.AbilityKit'`（单模块）、`import { UIAbility, Ability, Context } from '@kit.AbilityKit'`（多模块）、`import * as module from '@kit.AbilityKit'`（全量，官方提示「请谨慎使用」，会让 HAP 变大）。旧式 `import UIAbility from '@ohos.app.ability.UIAbility'` 仍可用但不推荐 | `introduction-to-arkts`、`development-intro-api` |

### 端云与 AGC

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| 端侧 / 云侧 | ⚠️ 未在官方术语页检索到独立定义。正文用法：「端云数据同步功能（端云协同），指将端侧设备（如手机、PC、平板等）数据同步到云侧」 | 本项目关注的「端侧 AI」＝在设备本地推理，与「云侧」相对。官方 Kit 简介里对应的表述是「支持的模型类型：离线」等能力约束，而非「端侧」二字 | `data-cloud-sync-overview`、`core-speech-introduction`、`agc-harmonyos-clouddev-overview` |
| AGC（AppGallery Connect） | 正文中定义为缩写来源：「项目是您在AppGallery Connect（以下简称AGC）资源的组织实体，您可以将一个应用的不同平台版本添加到同一个项目中」 | ⚠️ 未在 harmonyos-guides / harmonyos-references 检索到 AGC 的独立定义页（`AppGallery-Connect` 目录树接口返回空）。发布到华为应用市场须用应用市场颁发的发布证书签名 | `agc-harmonyos-clouddev-createproject`、`ide-tools-overview` |

### 本项目高频：语音与视觉 Kit

| 术语 | 定义（官方口径） | 备注/坑 | 依据 slug |
| --- | --- | --- | --- |
| Core Speech Kit（基础语音服务） | 「集成了语音类基础AI能力，包括文本转语音（TextToSpeech）及语音识别（SpeechRecognizer）能力…实现将实时输入的语音与文本之间相互转换」 | 定位＝**基础能力接口**。约束：文本转语音 ≤10000 字符，中／英；语音识别仅中文普通话、「支持的模型类型：离线」，短语音 ≤60s、长语音 ≤8h；设备 Phone/Tablet/PC-2in1；仅中国境内 | `core-speech-introduction` |
| Speech Kit（场景化语音服务） | 「集成了语音类AI能力，包括朗读控件（TextReader）和AI字幕控件（AICaptionComponent）能力」 | 定位＝**场景化控件**，开箱可用的 UI，不是底层 API | `speech-production` |
| Core Vision Kit（基础视觉服务） | 「提供了机器视觉相关的基础能力，例如通用文字识别（即OCR…）、人脸检测、人脸比对以及主体分割等能力」 | 定位＝**基础能力接口**；官方建议「结合Vision Kit的UI控件能力…提升交互体验」 | `core-vision-introduction` |
| Vision Kit（场景化视觉服务） | 「集成了视觉类AI能力，包括人脸活体检测（interactiveLiveness）能力、卡证识别（CardRecognition）能力、文档扫描（DocumentScanner）能力、AI识图控件（visionImageAnalyzer）能力」 | 定位＝**场景化控件/服务**。「动作活体检测能力、卡证识别能力实施试用期免费的计费政策，试用期至2026年12月31日」——本项目唯一见到明确计费的 AI Kit | `vision-introduction` |
| Agent Framework Kit（智能体框架服务） | 术语页定义：Agent「一种能够自主执行任务、提供智能服务的应用组件」；A2A「用于智能体（Agent）之间的通信」；Agent Card「Agent的元数据描述文档」；Artifact「智能体在任务执行生命周期中生成的不可变、可标识的交付物」 | 相关组件：`AgentExtensionAbility`、`AgentUIExtensionAbility`（API 参考中已有条目） | `hmaf-glossary` |

## 未确认 / 待核实

1. ⚠️ 「HarmonyOS NEXT」是否仍是官方当前称谓：官方术语表**无独立词条**，仅作为 2024 年架构发布时的命名出现；26.0.0 / 6.x 版本文档不再使用。「已不作为当前版本称谓」是本项目推论，未见官方明文废止说明。
2. ⚠️ FA 模型的**废弃起始版本**：官方仅写「不再主推」「主要用于 Lite Wearable 设备」，未检索到「废弃 / 移除」的版本号。
3. ⚠️ 「Ability」作为独立术语的官方定义：未在任何术语页检索到（只有 API 参考里的 Ability 基类）。
4. ⚠️ 「端侧 / 云侧」的官方术语定义：未检索到独立词条，仅有正文用法。
5. ⚠️ AGC 的官方独立定义页：未检索到；`AppGallery-Connect` 目录 `getCatalogTree` 返回空树，AGC 自有文档区未通过本项目的取文通道打通。
6. ⚠️ 「API Level」这一措辞：当前中文文档统一用「API 版本」；「API level」仅指 26.0.0 之前 `X.Y.Z(N)` 中的 N（OpenHarmony 底座 API level）。用「API Level 12」这类说法与官方口径不完全一致。
7. ⚠️ DevEco CLI 与 Command Line Tools 的定位边界（是否互相替代、能力是否重叠）未在官方文档中明确说明。
8. ⚠️ 文档接口返回的 `versionLabels`（如 `hmos-503`）与 HarmonyOS 版本号的对应关系待核实（同 `docs/00-doc-retrieval.md`）。
9. 本文所有 API 名称、导入路径均**未编译验证**（本文的词条没有落进 `harmony/HybridShell/`；
   编译链本身已于 2026-09-03 就位，见 `harmony/README.md`）。

## 来源

catalog 缩写：G＝`harmonyos-guides`，R＝`harmonyos-references`，L＝`harmonyos-releases`。
URL 规则：`https://developer.huawei.com/consumer/cn/doc/<catalog>/<slug>`。全部访问日期＝2026-09-01。

| 文档标题 | slug | catalog | version | updatedDate |
| --- | --- | --- | --- | --- |
| HarmonyOS术语 | `glossary` | G | V233 | 2026-08-31 |
| 应用程序包术语 | `application-package-glossary` | G | V235 | 2026-08-31 |
| Ability Kit术语 | `ability-terminology` | G | V174 | 2026-08-31 |
| ArkTS术语 | `arkts-glossary` | G | V21 | 2026-08-31 |
| Agent Framework Kit术语 | `hmaf-glossary` | G | V2 | 2026-08-31 |
| 应用开发导读 | `application-dev-guide` | G | V233 | 2026-08-31 |
| 开发准备（快速入门） | `start-overview` | G | V233 | 2026-08-31 |
| 初识ArkTS语言 | `arkts-get-started` | G | V233 | 2026-08-31 |
| ArkTS语言介绍 | `introduction-to-arkts` | G | V233 | 2026-08-31 |
| UI开发（ArkTS声明式开发范式）概述 | `arkts-ui-development-overview` | G | V235 | 2026-08-31 |
| 应用模型概述 | `stage-model-development-overview` | G | V234 | 2026-08-31 |
| 应用程序包概述 | `application-package-overview` | G | V235 | 2026-08-31 |
| 应用程序包结构 | `application-package-structure-stage` | G | V235 | 2026-08-31 |
| 应用配置文件概述 | `application-configuration-file-overview-stage` | G | V235 | 2026-08-31 |
| app.json5配置文件 | `app-configuration-file` | G | V235 | 2026-08-31 |
| module.json5配置文件 | `module-configuration-file` | G | V235 | 2026-08-31 |
| 工具概述（DevEco Studio） | `ide-tools-overview` | G | V112 | 2026-08-28 |
| 工程目录结构介绍 | `ide-project-structure` | G | V108 | 2026-08-28 |
| 概述（Hvigor） | `ide-hvigor` | G | V107 | 2026-08-28 |
| 工程级build-profile.json5文件 | `ide-hvigor-build-profile-app` | G | V107 | 2026-08-28 |
| 模块级build-profile.json5文件 | `ide-hvigor-build-profile` | G | V110 | 2026-08-28 |
| 命令行构建工具（hvigorw） | `ide-hvigor-commandline` | G | V113 | 2026-08-28 |
| 三方依赖管理工具（ohpm） | `ide-ohpm-cli` | G | V110 | 2026-08-28 |
| oh-package.json5 | `ide-oh-package-json5` | G | V111 | 2026-08-28 |
| 获取Command Line Tools | `ide-commandline-get` | G | V110 | 2026-08-28 |
| hdc | `hdc` | G | V237 | 2026-08-31 |
| 工具概述（DevEco CLI） | `ide-deveco-cli-overview` | G | V6 | 2026-08-28 |
| 快速入门（DevEco CLI） | `ide-deveco-cli-install` | G | V6 | 2026-08-28 |
| Core Speech Kit简介 | `core-speech-introduction` | G | V233 | 2026-08-31 |
| Speech Kit简介 | `speech-production` | G | V233 | 2026-08-31 |
| Core Vision Kit简介 | `core-vision-introduction` | G | V233 | 2026-08-31 |
| Vision Kit简介 | `vision-introduction` | G | V233 | 2026-08-31 |
| 同应用端云数据同步概述 | `data-cloud-sync-overview` | G | V40 | 2026-08-31 |
| 业务介绍（端云一体化开发） | `agc-harmonyos-clouddev-overview` | G | V109 | 2026-08-28 |
| 在AGC创建项目和HarmonyOS应用/元服务 | `agc-harmonyos-clouddev-createproject` | G | V108 | 2026-08-28 |
| 开发说明（API参考） | `development-intro-api` | R | V233 | 2026-08-31 |
| @ohos.app.ability.Ability (Ability基类) | `js-apis-app-ability-ability` | R | V233 | 2026-08-31 |
| 版本号格式调整说明 | `version-number-26` | L | V5 | 2026-08-29 |
| 关于应用兼容性的介绍 | `app-compatibility-intro` | L | V28 | 2026-08-29 |
| 影响应用兼容性的关键信息 | `app-compatibility-influence-factor` | L | V30 | 2026-08-29 |
| 所有HarmonyOS开发套件版本 | `overview-allversion` | L | V51 | 2026-08-29 |
| 版本概览（26.0.0） | `overview-2600` | L | V6 | 2026-08-29 |

