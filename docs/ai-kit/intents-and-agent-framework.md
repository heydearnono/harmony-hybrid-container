# Intents Kit 与 Agent Framework Kit（意图框架 / 智能体框架）

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段**未编译验证**（未落进 `harmony/HybridShell/`；编译链已于 2026-09-03 就位，但没校验过这些片段）

## 一句话

- **Intents Kit（意图框架服务）**：把应用内功能封装成「意图」注册给系统，由**系统入口反向调用应用**——小艺对话 / 小艺搜索 / 小艺建议。方向是「系统 → 应用」。
- **Agent Framework Kit（智能体框架服务，HMAF）**：在应用界面里放一个入口控件把**已上线的智能体拉起来**，并让应用内智能体通过 A2A 协议与其它智能体（含小艺）互相调用。方向是「应用 → 智能体」＋「智能体 ↔ 智能体」。

两者不是从属关系，也不互相替代；共同点是**都要在小艺开放平台注册并过华为审核**。

## 两者关系

| 维度 | Intents Kit（意图框架服务） | Agent Framework Kit（智能体框架服务） |
| --- | --- | --- |
| 官方定位 | 「HarmonyOS 级的意图标准体系」，连接应用内业务功能，做智慧分发 | 「提供了拉起指定智能体的能力」＋ A2A 智能体间通信 |
| 谁调用谁 | 系统入口调用应用（意图调用）；应用向系统上报数据（意图共享） | 应用主动拉起智能体；A2A 中系统应用（小艺）作客户端、三方应用作服务端 |
| 系统入口 | 小艺对话、小艺搜索、小艺建议 | 应用自己的界面（Function 组件）；A2A 场景下由小艺发起 |
| 特性类别 | 习惯推荐、事件推荐、位置推荐、技能调用-语音、本地搜索 | Function 组件（图标/按钮）、A2A 协议模块 |
| 端侧承载组件 | UIAbility / UIExtensionAbility / FormExtensionAbility / ServiceExtensionAbility + `InsightIntentUIExtensionAbility` | `AgentExtensionAbility`（extensionAbilities `type: "agent"`） |
| 声明文件 | `resources/base/profile/insight_intent.json` | `resources/base/profile/agent_config.json`（AgentCard） |
| 关键 Kit 包 | `@kit.IntentsKit`（共享）＋ `@kit.AbilityKit`（意图定义与执行） | `@kit.AgentFrameworkKit`（组件与 A2A）＋ `@kit.AbilityKit`（Extension 组件） |
| 起始版本 | 意图共享 `insightIntent` 4.0.0(10)；配置文件开发意图 API 11；装饰器开发意图 API 20 | Function 组件 6.0.0(20)；`AgentExtensionAbility` API 24；A2A 协议模块 26.0.0 |
| 支持设备 | Phone、Tablet、PC/2in1；HarmonyOS 5.0 及以上 | Phone、Tablet |
| 国家/地区 | 仅中国境内（不含港澳台） | 仅中国境内（不含港澳台） |
| 模拟器 | 不支持 | 不支持 |
| 开发主体 | **官方明文：仅面向企业开发者，个人开发者无法进行意图能力申请和注册等操作** | 文档未列「支持的开发主体」⚠️ 待核实（见「准入门槛」） |

**必须记住的边界**（最容易混）：

- 「意图」这套东西在系统里叫 **InsightIntent（意图框架）**，属于 `@kit.AbilityKit`，有独立的开发指南（`insight-intent-overview` 等）；**Intents Kit（`@kit.IntentsKit`）只提供意图共享/删除、SID 获取和 `InsightIntentUIExtensionAbility`**，其余（意图声明、意图执行器、装饰器）都在 AbilityKit 里。Intents Kit 的文档是「怎么接入小艺智慧分发」，AbilityKit 的意图文档是「意图本身怎么写」。
- 同理，Agent Framework Kit 的 A2A 服务端承载组件 `AgentExtensionAbility` 属于 `@kit.AbilityKit`，另有一套系统级文档「端侧 A2A 框架」（`agent-overview`），官方称其为「HMAF（Harmony Agent Framework）框架在端侧能力的延伸」。

## 接入应用要改什么

### A. Intents Kit（接入小艺智慧分发）

| 步骤 | 做什么 | 来源 slug |
| --- | --- | --- |
| 1 选特性定意图 | 按目标体验选定系统入口 + 特性类型，从已发布特性列表挑意图 | `intents-access-flow` |
| 2 AGC 能力申请 | AGC「开发与服务 → 项目 → 应用 → 项目设置 > 开放能力管理」，点「意图框架」的「申请」，按模板写申请原因；**1~3 个工作日**反馈 | `intents-access-flow` |
| 3 意图调试申请 | 审核通过后提交测试信息开通调试权限：应用名称、应用包名、接入意图名称、应用图标、APP ID、Client ID、**华为账号 UID** | `intents-access-flow` |
| 4 意图声明 | 编辑 `insight_intent.json`（见下） | `intents-habit-rec-access-programme`、`intents-skill-all-rec-configuration` |
| 5 意图共享（视特性） | 调 `insightIntent.shareIntent()` 上报行为/实体数据 | `intents-habit-rec-access-programme` |
| 6 意图调用实现 | 继承 `InsightIntentExecutor` 或 `InsightIntentEntryExecutor<T>` 实现落地页/业务逻辑 | 同上 |
| 7 端到端联调 | 华为侧测试能力 + 设备端自测；本地可用「意图框架调试」开关 | `intents-access-flow`、`insight-intent-debug` |
| 8 上架 | 先在 AGC 上架 App，再到**小艺开放平台**「意图框架」页签注册意图并提交审核，**3~5 个工作日**，通过后状态「已上架」 | `intents-kit-listing-standard-protocol` |

**配置文件字段（`insight_intent.json`）**——路径 `src/main/resources/base/profile/insight_intent.json`，Intents Kit 文档明确「整个工程中只能存在一个」：

```json
{
  "insightIntents": [
    {
      "intentName": "PlayMusic",
      "domain": "MusicDomain",
      "intentVersion": "1.0.1",
      "srcEntry": "./ets/entryability/InsightIntentExecutorImpl.ets",
      "uiAbility": { "ability": "EntryAbility", "executeMode": ["background", "foreground"] },
      "uiExtension": { "ability": "insightIntentUIExtensionAbility" }
    }
  ]
}
```
（未编译验证；字段逐字抄自 `intents-habit-rec-access-programme` / `intents-skill-all-rec-configuration`）

- 顶层字段只有两个被官方示例用到：`insightIntents`（意图列表）与 `insightIntentsSrcEntry`（装饰器方式声明执行文件路径，来源 `insight-intent-decorator-development`）。
- 意图内可选承载：`uiAbility`{`ability`,`executeMode`}、`uiExtension`{`ability`}、`form`{`ability`,`formName`}；`executeMode` 取值 `"foreground"` / `"background"`。
- 参数定义：`inputParams`（数组，整体参考 JSON-Schema，`properties` → `type` / `enum`[{`value`,`displayName`,`keywords`,`displayDescription`,`icon`}]），用于「功能一步达」场景。来源 `intents-skill-all-rec-one-step`。
- FAQ 里给出的 `inputParams` 同级合法键完整清单：`"intentName"`、`"domain"`、`"intentVersion"`、`"srcEntry"`、`"uiAbility"`、`"serviceExtension"`、`"uiExtension"`、`"form"`（来源 `intents-frequently-asked-questions-two` 标题）。
- **配置文件方式的 `intentName` 只能用预置垂域意图，不允许自定义**；自定义意图必须走装饰器方式。

**装饰器方式（API 20+，官方推荐）**——来源 `insight-intent-decorator-development`、`intents-skill-all-rec-decorator-overview`：

| 装饰器 | 用途 | 约束 |
| --- | --- | --- |
| `@InsightIntentEntry` | 新建意图逻辑，绑定 UIAbility / UIExtensionAbility；执行器继承 `InsightIntentEntryExecutor<T>` 实现 `onExecute()` | 由 `executeMode` 决定前后台 |
| `@InsightIntentLink` | 把已有 DeepLink / AppLink 的 uri 变成意图 | 仅前台执行；需在 `module.json5` 配 `abilities > skills > uris` |
| `@InsightIntentPage` | 把页面路由变成意图 | 仅前台执行，仅支持 Navigation 架构 |
| `@InsightIntentFunction` + `@InsightIntentFunctionMethod` | 把静态方法变成意图 | 仅后台执行 |
| `@InsightIntentForm` | 把卡片变成意图 | 由 FormComponent 创建 |
| `@InsightIntentEntity` | 定义意图实体，传递复杂参数 / 支持应用内数据查询 | 可选 |

- 标准意图：只填 `schema` + `intentVersion`，参数与结果定义由标准规范给出（`insight-intent-access-specifications`）。
- 自定义意图：需自己写 `llmDescription`、`keywords`、`parameters`（JSON-Schema 格式：`type`/`properties`/`description`/`required`）。命名规范见 `intents-skill-all-rec-specification`（动词+名词大驼峰、参数小驼峰、一个意图只做一件事）。
- **自定义意图的触发语料必须包含应用/元服务名称**（例：「打开 XX 商城的购物车」）。
- 若执行文件未被其它文件 import，需在 `insight_intent.json` 的 `insightIntentsSrcEntry` 里声明 `srcEntry`，否则不参与编译。

**窗口化展示**：`InsightIntentUIExtensionAbility`（`@kit.IntentsKit`，5.0.0(12)）继承自 UIExtensionAbility；对应 `module.json5` 的 `extensionAbilities` → `type` 取值为 **`insightIntentUI`**（「为开发者提供能被系统入口调用，以窗口形态呈现内容的扩展能力」，来源 `module-configuration-file`）。

### B. Agent Framework Kit

| 步骤 | 做什么 | 来源 slug |
| --- | --- | --- |
| 1 前置 | 在小艺（智能体）开放平台**开发 Agent**并**关联应用**；设备已登录华为账号且联网 | `hmaf-function` |
| 2 UI 入口 | 页面里放 `FunctionComponent`，必填 `agentId` + `onError`；可先用 `isAgentSupport()` 判断可用性；`controller.on('agentDialogOpened' / 'agentDialogClosed')` 订阅开关事件 | `hmaf-function`、`hmaf-function-component` |
| 3 A2A 服务端组件 | 新建 `ets/agentextability/AgentExtAbility.ets`，继承 `AgentExtensionAbility`，实现 `onCreate` / `onConnect` / `onData` / `onAuth` / `onDisconnect` / `onDestroy` | `agent-extension-ability` |
| 4 module.json5 注册 | `extensionAbilities` 里 `type` 设为 `"agent"`（见下） | `agent-extension-ability` |
| 5 AgentCard | `resources/base/profile/agent_config.json`，根字段 `agentCards`（对象数组）；一个 `agent_config.json` 只能被一个 `AgentExtensionAbility` 引用 | `agent-extension-configuration` |
| 6 A2A 逻辑 | `onCreate` 里 `createA2AServer(this.context.agentCard, onData, want)`；`onConnect` → `server.start()`；`onData` → `server.onMessage(data, cb)`；`onDisconnect`/`onDestroy` → `server.stop()` | `hmaf-a2a-dev-guide` |

```json
{
  "module": {
    "extensionAbilities": [
      {
        "name": "AgentExtAbility",
        "icon": "$media:icon",
        "description": "agent",
        "type": "agent",
        "exported": true,
        "srcEntry": "./ets/agentextability/AgentExtAbility.ets",
        "metadata": [
          { "name": "ohos.extension.agent", "resource": "$profile:agent_config" }
        ]
      }
    ]
  }
}
```
（逐字抄自 `agent-extension-ability`；未编译验证。注意 `metadata.name` 是固定串 `ohos.extension.agent`）

`agent_config.json` → `agentCards[]` 字段（来源 `agent-extension-configuration`）：

| 必填 | 字段 | 说明 |
| --- | --- | --- |
| 是 | `agentId` | 应用内唯一，≤64 字节 |
| 是 | `name` / `description` | 名称 ≤64 字节；描述 ≤512 字节 |
| 是 | `version` | 语义化版本，≤32 字节 |
| 是 | `defaultInputModes` / `defaultOutputModes` | MIME 类型数组，skill 级可覆盖 |
| 是 | `skills` | 对象数组，至少一个技能 |
| 是 | `iconUrl` / `category` / `extension` | `extension` 为 JSON 字符串（开场白、协议版本号等），≤5120 字节 |
| 否 | `provider` | `{ organization, url }` |
| 否 | `documentationUrl`、`capabilities`、`appInfo` | — |
| 否 | `type` | `0`/`APP`、`1`/`ATOMIC_SERVICE`，默认 APP，**从 26.0.0 开始支持** |

`capabilities`：`streaming`（SSE 流式）、`pushNotifications`、`stateTransitionHistory`、`extendedAgentCard`（均布尔，默认 false）、`extension`（JSON 字符串 ≤2048 字节）。

## 关键 API

| 用途 | 类 / 方法 | 导入路径 | 起始 API Level | 来源 slug |
| --- | --- | --- | --- | --- |
| 拉起智能体的 UI 控件 | `FunctionComponent`（`agentId` 必填、`onError` 必填、`options`、`controller`） | `@kit.AgentFrameworkKit` | 6.0.0(20)，元服务 6.0.1(21) | `hmaf-function-component` |
| 控件控制器 / 可用性查询 | `FunctionController`、`AgentController.isAgentSupport(context, agentId): Promise<boolean>`、`on/off('agentDialogOpened'\|'agentDialogClosed')` | `@kit.AgentFrameworkKit` | 6.0.0(20) | `hmaf-function-component` |
| 控件参数 | `BaseOptions`（`title`/`titleFontSize`/`iconSize`/`iconColors`）、`FunctionOptions`（`queryText`/`controlSize`/`buttonType`/`isShowShadow`）、`ButtonType`（`CIRCLE`/`CAPSULE`） | `@kit.AgentFrameworkKit` | 6.0.0(20) | `hmaf-function-component` |
| 创建 A2A 服务端 | `createA2AServer(agentCard: common.AgentCard, onData: OnDataCallback, want?: Want): Server` | `@kit.AgentFrameworkKit` | 26.0.0 | `hmaf-a2a-protocol` |
| A2A 服务端控制 | `Server.start()` / `stop()` / `onMessage()` / `onAuth()` / `updateStatus()` / `addArtifact()` | `@kit.AgentFrameworkKit` | 26.0.0 | `hmaf-a2a-protocol` |
| A2A 请求上下文 | `RequestContext.getAgentId()` / `getTaskId()` / `getContextId()` / `getMessage()` / `getUserInput()` / `getMetadata()` / `getCurrentTask()` / `getRelatedTasks()` | `@kit.AgentFrameworkKit` | 26.0.0 | `hmaf-a2a-protocol` |
| A2A 数据类型 | `Message`、`Part`、`Task`、`TaskStatus`、`Artifact`、`TaskArtifactParam`、`TaskState`、`Role`、`OnDataCallback`、`ProxySender` | `@kit.AgentFrameworkKit` | 26.0.0 | `hmaf-a2a-protocol` |
| 智能体服务端组件 | `AgentExtensionAbility`：`onCreate(want)` / `onConnect(want, proxy)` / `onData(proxy, data)` / `onAuth(proxy, handshakeData)` / `onDisconnect(want, proxy)` / `onDestroy()`；属性 `context: AgentExtensionContext` | `@kit.AbilityKit` | API 24（不支持在 har 包中使用） | `js-apis-app-agent-agentextensionability` |
| 服务端 → 客户端 | `common.AgentHostProxy.sendData(data: string)` / `authorize(authResult)`（须主线程调用） | `@kit.AbilityKit` | API 24 | `js-apis-inner-application-agenthostproxy` |
| 读取自身 AgentCard | `AgentExtensionContext.agentCard`；`AgentCard` / `AgentProvider` / `AgentCapabilities` / `AgentSkill` / `AgentAppInfo` | `@kit.AbilityKit`（`common`） | API 24（`type` 字段 26.0.0） | `js-apis-inner-application-agentextensioncontext`、`js-apis-inner-application-agentcard` |
| 意图共享 / 删除 | `insightIntent.shareIntent(context, intents[, callback])`、`deleteIntent`、`deleteEntity`、`getSid`；数据结构 `InsightIntent`（`intentName`/`intentVersion`/`identifier`/`intentActionInfo`/`intentEntityInfo`） | `@kit.IntentsKit` | 4.0.0(10)，元服务 5.0.0(12)；`IntentActionInfo`/`IntentEntityInfo` 类型 5.0.0(12) | `intents-arkts-api-insightintent` |
| 意图窗口化界面 | `InsightIntentUIExtensionAbility`（`onSessionCreate` 里 `session.loadContent()`） | `@kit.IntentsKit` | 5.0.0(12) | `intents-arkts-api-insightintent-uiextension` |
| 意图执行器（配置文件方式） | `InsightIntentExecutor.onExecuteInUIAbilityForegroundMode()` / `onExecuteInUIAbilityBackgroundMode()` / `onExecuteInUIExtensionAbility()` / `onExecuteInServiceExtensionAbility()` | `@kit.AbilityKit` | API 11 | `js-apis-app-ability-insightintentexecutor` |
| 意图执行器（装饰器方式） | `InsightIntentEntryExecutor<T>.onExecute(): Promise<insightIntent.IntentResult<T>>` | `@kit.AbilityKit` | API 20 | `js-apis-app-ability-insightintententryexecutor` |
| 意图装饰器 | `@InsightIntentEntry`、`@InsightIntentLink`、`@InsightIntentPage`、`@InsightIntentFunction`、`@InsightIntentFunctionMethod`、`@InsightIntentForm`、`@InsightIntentEntity`（配套 `EntryIntentDecoratorInfo` 等 Info 类型、`LinkIntentParamMapping`、`LinkParamCategory`） | `@kit.AbilityKit` | API 20 | `js-apis-app-ability-insightintentdecorator` |
| 意图基础类型 | `insightIntent.ExecuteMode`（`UI_ABILITY_FOREGROUND`=0 / `UI_ABILITY_BACKGROUND`=1 / `UI_EXTENSION_ABILITY`=2）、`ExecuteResult` | `@kit.AbilityKit` | API 11 | `js-apis-app-ability-insightintent` |
| 意图基础类型（新增） | `IntentEntity`、`IntentResult<T>`（API 20）；`ReturnMode`（API 23）；`QueryType`、`QueryEntityParam`、`AppIntentEntity`、`onQueryEntity`（26.0.0） | `@kit.AbilityKit` | 见左列 | `js-apis-app-ability-insightintent` |

共享限额（`intents-arkts-api-insightintent`）：默认**每应用每天最多 20 次**（超限 `1000101104`）、**单次 ≤50KB**（`1000101105`）、**全部接入方每天合计 3000 次**（`1000101106`）；未注册意图报 `1000101101`。

## 准入门槛

| 关卡 | Intents Kit | Agent Framework Kit |
| --- | --- | --- |
| 开发主体 | **仅企业开发者**（原文：「仅面向企业开发者，个人开发者无法进行意图能力申请和注册等操作」，`intents-introduction`） | 文档未声明 ⚠️ 待核实 |
| AGC 能力申请 | 必须（「项目设置 > 开放能力管理 > 意图框架」，1~3 工作日人工反馈） | 未见同类申请入口 ⚠️ 待核实 |
| 白名单 / 调试权限 | 需单独申请意图调试权限，要提交测试华为账号 UID（`intents-appendix-a-get-uid` 讲怎么取 UID） | 未提及 |
| 平台注册 | 小艺开放平台「意图框架」页签注册 + 提交审核，**3~5 工作日**；前提是 App 已在 AGC 上架 | 需先在小艺开放平台**上线智能体**并**关联应用**才能拿到 `agentId` |
| 人工审核 | 意图上架必审；MCP 上架按渠道：「智能体」渠道免人工审核，「小艺对话」「插件市场」渠道必审 | ⚠️ 待核实 |
| IDE 侧 | DevEco Studio 添加意图插件**仅支持团队账号登录**，个人账号需实名认证并加入团队（`ide-insight-intent2`） | 同一入口（Application Agent）创建智能体，同样受团队账号约束 |

**个人开发者结论**：

1. 想把功能接到小艺对话/搜索/建议并上架 —— **不行**。这是官方明文写死的主体限制，不是流程摩擦。
2. 想在本机把「意图」写出来并跑通 —— **可以**。意图定义（`insight_intent.json` / 装饰器）、意图执行器、`InsightIntentUIExtensionAbility` 都属于 `@kit.AbilityKit`/系统能力，且官方提供了**不依赖华为审核的本地调试通道**：设置 → 系统 → 开发者选项 → 「意图框架调试」→ 查看设备上所有意图 / 执行意图（仅手机，API ≥ 20，来源 `insight-intent-debug`）。这条路适合本项目做代码生成规则验证。
3. `insightIntent.shareIntent()` 会返回 `1000101101 The application has not been registered with the InsightIntent`——未注册就调用必然失败，所以「意图共享」这一侧个人开发者无法验证。
4. Agent Framework Kit：`FunctionComponent` 依赖平台侧 `agentId`，没有智能体就没有可用入口；`AgentExtensionAbility` 的客户端是系统应用（小艺），三方无公开 client API。因此**即使代码能编译，也无法在无平台资质的情况下端到端验证**。是否彻底禁止个人开发者，⚠️ 待核实。

## A2A 协议要点

- **是什么**：Agent-to-Agent 开放协议，定义智能体之间的能力描述、数据交换、安全认证、技能调用。官方称端侧实现是「HMAF 框架在端侧能力的延伸，支持统一 A2A 协议规范和端云互调」（`agent-overview`，API 24 起）。
- **角色**：Client 负责建连、发任务请求、收响应、查状态；Server 负责收请求、触发智能体执行、更新任务状态、返回结果。**三方应用做 Server**（`AgentExtensionAbility`），**系统应用（小艺）做 Client**。
- **典型场景**：应用内智能体调用小艺智能体完成任务；小艺编排多个应用的智能体（旅行规划：天气 + 机票 + 酒店）；小艺感知当前 App 后向其智能体请求推荐内容（AgentChips）。
- **核心概念**：`Agent Card`（JSON 元数据，描述身份/能力/端点/技能/认证要求，用于发现）、`Task`（有唯一标识与生命周期的有状态工作单元）、`Message`（一次通信单元，含 role `"user"`/`"agent"`）、`Part`（内容容器：文本 / 文件引用 / 结构化数据）、`Artifact`（有产物 ID 和名称的交付物）、`Context`（服务端生成，逻辑关联多个任务）、`TaskState`（已提交、工作中、需要用户输入、已完成、已取消、已失败、已拒绝、需要认证）。
- **业务流程**：客户端凭 Agent Card 发现并连接 → 发送请求 → 服务端触发智能体执行并生成产物 → 更新状态并返回结果。
- **`OnDataCallback` 的 `method` 取值**（`hmaf-a2a-protocol`）：
  - `'Execute'`：小艺发送「对话交互」「长任务陪伴」「UI 控制陪伴」「原生控制」时触发，客户端方法为 `SendMessage` / `SendStreamingMessage`。
  - `'Cancel'`：客户端发 `CancelTask`。
  - `'PerceptionSuggest'`：小艺初始化时取「感知建议 chips」。
  - `'GetOpening'`：小艺初始化时取应用开场白。
  - 其余取值见官方「A2A 消息指令定义」（该页未在开发指南目录树中找到，⚠️ 未取到）。
- **消息形态**（抄自官方示例，未编译验证）：
  - 状态更新：`server.updateStatus(taskId, { state: TaskState.WORKING, message: { messageId, role: Role.AGENT, parts: [{ mediaType: 'text/plain', text: '...' }] } })`
  - 产物：`server.addArtifact(taskId, { artifactId, parts: [{ mediaType: 'application/json', data: {...} }], append: false, lastChunk: true })`
  - AgentChips 回复的 `data` 结构为 `{ suggestionCandidates: [{ text, reply }] }`
  - **状态语义**：一旦状态更新为非 `WORKING` 且非 `SUBMITTED`，即认为本次执行完成。
- **认证**：双向可选。客户端发起，服务端在 `onAuth()` 处理后用 `proxy.authorize()` 回复。
- **UI**：服务端可通过 `AgentUIExtensionAbility` 在客户端应用中展示界面（`agent-overview` 提及，细节未读）。

## AI 容易写错的点

1. **`AgentExtensionAbility`，不是 `AgentAbilityExtension`**。官方指南标题写的是「通过 AgentAbilityExtension 实现智能体间 A2A 协议通信」，但正文、所有代码、API 参考页（`@ohos.app.agent.AgentExtensionAbility`）都是 `AgentExtensionAbility`。标题是笔误，以 API 参考为准。
2. **两个同名 `insightIntent` 命名空间**：
   - `import { insightIntent } from '@kit.AbilityKit'` → `ExecuteMode` / `ExecuteResult` / `IntentResult<T>`（意图执行侧）
   - `import { insightIntent } from '@kit.IntentsKit'` → `shareIntent` / `InsightIntent` / `IntentActionInfo` / `IntentEntityInfo`（意图共享侧）
   写代码时两者可能同时出现在一个模块里，别混。
3. **Agent 相关类跨两个 Kit**：`AgentExtensionAbility`、`common.AgentHostProxy`、`common.AgentCard`、`Want` 来自 `@kit.AbilityKit`；`createA2AServer`、`Server`、`RequestContext`、`TaskState`、`Role`、`OnDataCallback` 来自 `@kit.AgentFrameworkKit`；`FunctionComponent`/`FunctionController` 也在 `@kit.AgentFrameworkKit`。
4. **意图不写在 `module.json5` 里**。意图声明文件是 `resources/base/profile/insight_intent.json`。`module.json5` 只在三处相关：`extensionAbilities.type = "agent"`（A2A 服务端）、`extensionAbilities.type = "insightIntentUI"`（意图窗口化界面）、`abilities > skills > uris`（`@InsightIntentLink` 的前提）。
5. **官方 A2A 示例里有 Python 味的语法错误**：开发指南 `hmaf-a2a-dev-guide` 写 `createA2AServer(card, this.agentOnData, want=want)`；API 参考 `hmaf-a2a-protocol` 写 `createA2AServer(card, this.agentOnData, want)`。ArkTS 没有关键字参数，照抄前者会得到「赋值表达式」而非命名参数。以 API 参考为准。
6. **配置文件方式不能自定义意图名**：`intentName` 只能取预置垂域意图（否则编译期提示 `Intent 'xxx' is not included in domain 'xxx'`；官方在「功能一步达」页说明该提示不影响编译运行，可忽略）。自定义意图只能走装饰器方式，且触发语料必须带应用名。
7. **`type: "agent"` 在 `module.json5` 参考文档里查不到**：`module-configuration-file`（V235，2026-09-01 核实）的 `type` 取值表中只有 `partnerAgent23+` 与 `insightIntentUI`，没有 `agent`。指南 `agent-extension-ability` 明确要求 `"type": "agent"`。以指南为准，但这条 ⚠️ 待核实（可能是参考文档未同步）。
8. **版本号有三种写法，别互相换算**：`6.0.0(20)` 括号里才是 API Level；`API version 24`（`AgentExtensionAbility`）；`26.0.0`（A2A 协议模块、部分新增字段）。文档同一页可能混用「起始版本」和「元服务 API 起始版本」两个口径。
9. **`insight_intent.json` 全工程唯一**：Intents Kit 的接入方案页明确「整个工程中只能存在一个 `insight_intent.json` 文件」；AbilityKit 的意图文档只说「放在 `resources/base/profile`」。多 module 工程按前者处理。
10. **`agent_config.json` 与 `AgentExtensionAbility` 一对一**：一个 `agent_config.json` 只能被一个 `AgentExtensionAbility` 引用，但文件内 `agentCards` 是数组。
11. **`isAgentSupport` 挂在 `AgentController` 上**（`FunctionController` 继承它，当前版本无额外实现），需要传 `common.UIAbilityContext`，通常用 `this.getUIContext().getHostContext() as common.UIAbilityContext` 取。

## 未确认 / 待核实

- ⚠️ Agent Framework Kit 是否对个人开发者开放；小艺开放平台「开发 Agent」「关联应用」的资质要求——对应页面不在 `harmonyos-guides` / `harmonyos-references` 目录树中（应在小艺开放平台自有文档）。
- ⚠️ 三方应用能否作为 **A2A 客户端**主动连接别人的 `AgentExtensionAbility`：指南只写「系统应用可以连接其他应用实现的 AgentExtensionAbility 组件」，未找到公开的 client 端连接 API（在 API 参考里检索 `connectAgent` / `agentManager` 无结果）。
- ⚠️ 「A2A 消息指令定义」「感知建议 chips」「小艺 AgentChips 交互流程」的完整报文规范：文档中为跳转链接，正文未取到。
- ⚠️ Agent Framework Kit / A2A / Intents Kit 是否需要在 `requestPermissions` 里申请权限：所读页面均未出现 `ohos.permission.*` 相关要求，但不能据此断定不需要。
- ⚠️ `module.json5` 中 `type: "agent"` 的起始 API Level（参考文档未收录该取值）。
- ⚠️ `AgentUIExtensionAbility`（`@ohos.app.ability.AgentUIExtensionAbility`，参考页 `js-apis-agent-agentuiextensionability`）细节未读。
- ⚠️ Intents Kit 简介与 Agent Framework Kit 简介的「约束与限制」小节在抓取到的正文中为空（疑为图片承载），文字约束未取到。
- ⚠️ 各垂域「意图 Schema」清单、标准意图接入规范（`insight-intent-access-specifications`）未逐条核对。
- ⚠️ 云侧意图 / REST API（`intents-rest-api-intent-share`、`intents-rest-api-revoke-event`）未展开。
- 未做：任何编译或真机验证（本机无 DevEco Studio / hvigorw / ohpm）。

## 来源

全部经 `tools/hwdoc.py` 直接抓取站点 JSON 接口取得正文，**访问日期均为 2026-09-01**。URL 前缀：开发指南 `https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/`，API 参考 `https://developer.huawei.com/consumer/cn/doc/harmonyos-references/`。`updated` 为接口返回的 `updatedDate`，括号内为页面展示的更新时间 `displayUpdateTime`。

| 文档标题 | slug | URL | version / 更新时间 | 访问日期 |
| --- | --- | --- | --- | --- |
| Agent Framework Kit（智能体框架服务） | `harmony-agent-framework-kit-guide` | guides/harmony-agent-framework-kit-guide | V169 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| Agent Framework Kit简介 | `hmaf-introduction` | guides/hmaf-introduction | V169 / 2026-08-31（展示 2026-07-28） | 2026-09-01 |
| 通过Function组件拉起智能体 | `hmaf-function` | guides/hmaf-function | V169 / 2026-08-31（展示 2026-06-16） | 2026-09-01 |
| 通过AgentAbilityExtension实现智能体间A2A协议通信 | `hmaf-a2a-dev-guide` | guides/hmaf-a2a-dev-guide | V11 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| Agent Framework Kit术语 | `hmaf-glossary` | guides/hmaf-glossary | V2 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 端侧A2A框架概述 | `agent-overview` | guides/agent-overview | V23 / 2026-08-31（展示 2026-06-09） | 2026-09-01 |
| 开发端侧智能体 | `agent-development` | guides/agent-development | V22 / 2026-08-31（展示 2026-06-09） | 2026-09-01 |
| 使用AgentExtensionAbility组件实现智能体服务 | `agent-extension-ability` | guides/agent-extension-ability | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| AgentExtensionAbility配置文件说明 | `agent-extension-configuration` | guides/agent-extension-configuration | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| Intents Kit（意图框架服务） | `intents-kit-guide` | guides/intents-kit-guide | V233 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| Intents Kit简介 | `intents-introduction` | guides/intents-introduction | V233 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| Intents Kit接入流程 | `intents-access-flow` | guides/intents-access-flow | V233 / 2026-08-31（展示 2026-06-27） | 2026-09-01 |
| 习惯推荐方案 · 接入方案 | `intents-habit-rec-access-programme` | guides/intents-habit-rec-access-programme | V233 / 2026-08-31（展示 2026-05-19） | 2026-09-01 |
| 技能调用方案 · 概述 | `intents-skill-all-rec-introduction` | guides/intents-skill-all-rec-introduction | V188 / 2026-08-31（展示 2026-03-09） | 2026-09-01 |
| 技能调用方案 · 接入方案概述 | `intents-skill-all-rec-access-introduction` | guides/intents-skill-all-rec-access-introduction | V169 / 2026-08-31（展示 2026-04-20） | 2026-09-01 |
| 任务执行类场景方案（配置文件接入方式） | `intents-skill-all-rec-configuration` | guides/intents-skill-all-rec-configuration | V169 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 装饰器接入方式 · 方案概述 | `intents-skill-all-rec-decorator-overview` | guides/intents-skill-all-rec-decorator-overview | V169 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 自定义意图相关信息定义规范 | `intents-skill-all-rec-specification` | guides/intents-skill-all-rec-specification | V169 / 2026-08-31（展示 2026-06-27） | 2026-09-01 |
| 功能一步达场景方案 | `intents-skill-all-rec-one-step` | guides/intents-skill-all-rec-one-step | V188 / 2026-08-31（展示 2026-08-11） | 2026-09-01 |
| 意图标准协议上架指导 | `intents-kit-listing-standard-protocol` | guides/intents-kit-listing-standard-protocol | V169 / 2026-08-31（展示 2026-07-28） | 2026-09-01 |
| MCP协议上架指导 | `intents-kit-listing-mcp-protocol` | guides/intents-kit-listing-mcp-protocol | V169 / 2026-08-31（展示 2026-07-28） | 2026-09-01 |
| Intents Kit术语 | `intents-glossary` | guides/intents-glossary | V2 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 意图框架概述 | `insight-intent-overview` | guides/insight-intent-overview | V189 / 2026-08-31（展示 2026-03-09） | 2026-09-01 |
| 使用配置文件开发意图 | `insight-intent-config-development` | guides/insight-intent-config-development | V189 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 使用装饰器开发意图 | `insight-intent-decorator-development` | guides/insight-intent-decorator-development | V189 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| 调试意图 | `insight-intent-debug` | guides/insight-intent-debug | V189 / 2026-08-31（展示 2026-03-09） | 2026-09-01 |
| 意图装饰器生成和小艺智能体创建 | `ide-insight-intent2` | guides/ide-insight-intent2 | V87 / 2026-08-28（展示 2026-07-15） | 2026-09-01 |
| module.json5配置文件 | `module-configuration-file` | guides/module-configuration-file | V235 / 2026-08-31（展示 2026-09-01） | 2026-09-01 |
| FunctionComponent（功能组件） | `hmaf-function-component` | references/hmaf-function-component | V169 / 2026-08-31（展示 2026-09-01） | 2026-09-01 |
| A2A（A2A协议） | `hmaf-a2a-protocol` | references/hmaf-a2a-protocol | V11 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| insightIntent（Intents Kit） | `intents-arkts-api-insightintent` | references/intents-arkts-api-insightintent | V232 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| InsightIntentUIExtensionAbility | `intents-arkts-api-insightintent-uiextension` | references/intents-arkts-api-insightintent-uiextension | V232 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| @ohos.app.ability.insightIntent（意图框架基础定义） | `js-apis-app-ability-insightintent` | references/js-apis-app-ability-insightintent | V233 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| @ohos.app.ability.InsightIntentExecutor | `js-apis-app-ability-insightintentexecutor` | references/js-apis-app-ability-insightintentexecutor | V233 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| @ohos.app.ability.InsightIntentEntryExecutor | `js-apis-app-ability-insightintententryexecutor` | references/js-apis-app-ability-insightintententryexecutor | V208 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| @ohos.app.ability.InsightIntentDecorator | `js-apis-app-ability-insightintentdecorator` | references/js-apis-app-ability-insightintentdecorator | V208 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| @ohos.app.agent.AgentExtensionAbility | `js-apis-app-agent-agentextensionability` | references/js-apis-app-agent-agentextensionability | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| AgentCard | `js-apis-inner-application-agentcard` | references/js-apis-inner-application-agentcard | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| AgentExtensionContext | `js-apis-inner-application-agentextensioncontext` | references/js-apis-inner-application-agentextensioncontext | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
| AgentHostProxy | `js-apis-inner-application-agenthostproxy` | references/js-apis-inner-application-agenthostproxy | V36 / 2026-08-31（展示 2026-08-29） | 2026-09-01 |
