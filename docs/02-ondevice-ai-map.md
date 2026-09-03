# 端侧 AI 能力地图

最后更新：2026-09-01 ｜ 事实来源：华为官方文档，经 `tools/hwdoc.py` 取回（明细见各 Kit 细节笔记文末来源表）｜ 代码片段**全部未编译验证**：端侧 AI 已转为参考资料、没有落进 `harmony/HybridShell/`，所以 2026-09-03 就位的编译链没有校验过它们

## 结论摘要

- 官方开发指南「AI」节点下**恰好 10 个 Kit**，分四层：原子能力（Core 系）、场景化控件（场景化系）、推理运行时、意图与智能体。清单以目录为准，不多不少。
- **Core 系给算法，场景化系给成品交互**，二者是同级而非父子关系。官方定性原文见 `docs/ai-kit/scenario-kits.md`。
- 三套推理运行时是**分层不是竞品**：应用 → MindSpore Lite Kit → NNRt → CANN Kit → NPU 驱动。
- 想让 Agent 端到端做出可验证的东西，现实路径只有 **Core Speech / Core Vision / 场景化控件 / MindSpore Lite 的 ArkTS 接口**。NNRt 与 CANN 要 Native 工程加特定芯片真机，Intents Kit 要企业资质。
- 两条几乎所有 Kit 都逃不掉的横向约束：**仅中国境内可用**、**多数能力不支持模拟器**。写代码前先看这两栏，比看 API 更重要。
- **「端侧」不要替官方承诺**：Core Vision 的 8 个能力，官方 16 篇正文里没有任何一处写「端侧」「离线」或「需联网」，本仓库一律标 ⚠️ 未确认。明确写了端侧的只有 Core Speech（离线）与 Vision Kit 的人脸活体检测（「纯端侧算法」）。

## 版本口径说明（先读这条）

26.0.0 起官方取消了括号里的整数 API Level，API 版本号改为纯 SemVer `X.Y.Z`；26.0.0 之前写作 `X.Y.Z(N)`，N 才是 OpenHarmony 底座的 API level。本仓库统一写「起始版本」并保留官方原格式（如 `4.1.0(11)`、`26.0.0`），不写「API Level 11」这种已过时的措辞。详见 `docs/glossary.md`、`docs/01-platform-landscape.md`。

## 四层结构

```
        应用（ArkTS / ArkUI）
                │
  ┌─────────────┼──────────────┬───────────────────┐
  │             │              │                   │
场景化系      Core 系      意图与智能体        自带模型
控件级        原子 API      系统入口            推理运行时
  │             │              │                   │
Speech Kit   Core Speech   Intents Kit      MindSpore Lite Kit
Vision Kit   Core Vision   Agent Framework        │
Natural                                      NNRt（仅 C，需 NPU）
Language                                          │
（无 UI）                                    CANN Kit（Kirin）
                                                  │
                                             NPU 驱动 / 芯片
```

Natural Language Kit 放在这一列是因为它同为原子 API、零 UI；官方目录里它与场景化 Kit 同级，**但它不是场景化 Kit，也不存在「Core Natural Language Kit」**。

## 总表

| Kit | 层 | 主要能力 | 端侧？ | 接口 / 导入路径 | 起始版本 | 细节 |
| --- | --- | --- | --- | --- | --- | --- |
| Core Speech Kit | 原子 | 文本转语音、语音识别 | **是，纯离线** | ArkTS `@kit.CoreSpeechKit` | 4.1.0(11)，部分 5.1.1(19) | [笔记](ai-kit/core-speech-kit.md) |
| Core Vision Kit | 原子 | OCR、人脸检测、人脸比对、主体分割、多目标识别、骨骼点检测、图像超分、文本搜图（8 项） | ⚠️ 官方未标注 | ArkTS `@kit.CoreVisionKit` | 4.0.0(10) ~ 26.0.0（按能力） | [笔记](ai-kit/core-vision-kit.md) |
| Natural Language Kit | 原子 | 分词、实体抽取 | ⚠️ 仅间接证据 | ArkTS，无 UI | 5.0.0(12) | [笔记](ai-kit/scenario-kits.md) |
| Speech Kit | 场景化 | 朗读控件 TextReader、AI 字幕控件 AICaptionComponent | ⚠️ 未标注；切换音色需 INTERNET | ArkUI 控件 | 5.0.0(12)，IconV2 6.1.1(24) | [笔记](ai-kit/scenario-kits.md) |
| Vision Kit | 场景化 | 人脸活体检测、卡证识别、文档扫描、AI 识图 | 活体检测官方明写「纯端侧算法」，其余 ⚠️ | ArkUI 控件 / 系统页面 | 5.0.0(12) | [笔记](ai-kit/scenario-kits.md) |
| MindSpore Lite Kit | 推理 | 自带 `.ms` 模型做推理 | 是 | ArkTS `@kit.MindSporeLiteKit` + C API | C:9 / ArkTS:10 | [笔记](ai-kit/inference-runtimes.md) |
| Neural Network Runtime Kit | 推理 | 给推理框架用的系统运行时，不提供 CPU 推理 | 是，**必须 NPU** | 仅 C API | runtime.h:9 / core.h:11 | [笔记](ai-kit/inference-runtimes.md) |
| CANN Kit | 推理 | 麒麟芯片异构计算栈、`.om` 模型、端侧 LLM C API | 是，**必须 Kirin NPU** | C API + NAPI | 4.1.0(11)；`llm_engine.h` 6.1.1(24) | [笔记](ai-kit/inference-runtimes.md) |
| Intents Kit | 意图 | 把应用功能声明为意图，供小艺对话/搜索/建议反向调用 | — | 配置文件/装饰器 + 执行器 | 意图共享 4.0.0(10)；配置文件 API 11；装饰器 API 20 | [笔记](ai-kit/intents-and-agent-framework.md) |
| Agent Framework Kit | 智能体 | 应用内拉起智能体、A2A 智能体互调 | — | Function 组件 / `AgentExtensionAbility` | Function 组件 6.0.0(20)；A2A 模块 26.0.0 | [笔记](ai-kit/intents-and-agent-framework.md) |

## 横向约束（比 API 更容易卡死项目）

| 约束 | 情况 |
| --- | --- |
| 地区 | Core Speech、Core Vision、场景化三 Kit 均**仅适用于中国境内**（不含港澳台） |
| 设备 | Core 系与场景化系集中在 Phone / Tablet / PC·2in1；MindSpore Lite 覆盖到 TV / Wearable（Wearable 仅 CPU） |
| 模拟器 | Core Speech 自 6.0.0(20) 起支持；**Core Vision 不支持**；MindSpore Lite 可跑（无 NPU）；NNRt 不支持 |
| 权限 | Core Vision 8 项均无需 `ohos.permission.*`；Core Speech 仅 ASR 实时录音需 `ohos.permission.MICROPHONE` |
| 收费 | 仅发现一处：Vision Kit 的动作活体检测与卡证识别**试用期免费至 2026-12-31** |
| 准入 | Intents Kit 官方明写「仅面向企业开发者，个人开发者无法进行意图能力申请和注册」；Agent Framework 需先在小艺开放平台上线智能体并关联应用 |
| 并发 | Core Vision 同一进程同一特性并发调用返回系统繁忙，不能 `Promise.all` 批量跑；Core Speech 的 TTS 实例上限 3 个是**设备级、跨应用共享** |

## 选型决策路径

1. **需求能被场景化控件直接满足吗？**（朗读、字幕、扫证件、扫文档、活体检测、AI 识图）
   → 用场景化 Kit。代价是 UI 与交互由系统定，定制空间小。
2. **需要自己控制 UI，但算法是常见的？**（OCR、人脸、分割、TTS/ASR、分词、实体抽取）
   → 用 Core 系原子 API。注意 Core Vision 新旧两套 API 风格不通用。
3. **能力清单里没有，或被地区/设备约束卡住？**
   → 自带模型走 **MindSpore Lite Kit**（ArkTS 可用、模拟器可验证），这是自带模型里唯一现实的路径。
4. **要接系统级 AI 入口（小艺对话、搜索、建议）？**
   → Intents Kit，但先确认资质：个人开发者无法完成注册与上架，端到端不可验证。
5. **要在应用里拉起智能体或让智能体互调？**
   → Agent Framework Kit，前置条件是智能体已在小艺开放平台上线。
6. **要写算子、量化模型、榨干 NPU？**
   → NNRt / CANN Kit。需要 Native 工程、特定芯片真机，CANN 的模型转换工具链还要 Ubuntu 64 位。

## 对「Agent 构建鸿蒙应用」的可行性排序

以「本机能否形成写码→编译→看到结果的反馈闭环」为标准（本机现状见 `docs/01-platform-landscape.md`）：

| 可行性 | 能力 | 原因 |
| --- | --- | --- |
| 较高 | Core Speech Kit、MindSpore Lite Kit（ArkTS） | 单一导入路径、Promise 风格、模拟器可跑 |
| 中 | Core Vision Kit、场景化三 Kit | API 清晰，但**不支持模拟器**，需真机；真机又需实名认证 + 签名 |
| 低 | Intents Kit、Agent Framework Kit | 资质与平台审核是硬门槛，与代码质量无关 |
| 很低 | NNRt、CANN Kit | Native 工程 + 特定芯片 + 跨平台工具链 |

## 未确认 / 待核实

- Core Vision 8 项能力的端侧/云侧属性——官方正文零标注。
- Natural Language Kit 是否端侧推理（仅错误码提及「CPU/NPU 占用」作间接证据）。
- 场景化 Kit 中卡证识别、文档扫描、AI 识图是否联网；官方只写「不留存」「云端不存储」，**这不等于「不上传」**。
- 图像超分、文本搜图标注的 `26.0.0` 对应关系，以及官方文档内部若干自相矛盾处（NNRt 是否只支持同步推理、CANN 是否必须有 NPU），见各细节笔记。
- Agent Framework Kit 是否同样限企业开发者。

## 来源

各 Kit 的完整来源表（slug、URL、文档 version、更新时间、访问日期）在对应细节笔记文末，汇总见 `docs/sources.md`。检索方法见 `docs/00-doc-retrieval.md`。
