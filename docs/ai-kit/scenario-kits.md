# 场景化 AI Kit：Natural Language / Speech / Vision

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段**未编译验证**（未落进 `harmony/HybridShell/`；编译链已于 2026-09-03 就位，但没校验过这些片段）

## 一句话

三个 Kit 里只有 **Speech Kit 和 Vision Kit 真的是「场景化」**——它们交付的是可直接放进 `build()` 的 ArkUI 控件与系统内置的整套交互；**Natural Language Kit 不属于这一类**，它交付的是纯原子 API（`textProcessing.getWordSegment` / `getEntity`），也不存在与之配对的「Core Natural Language Kit」。三个 Kit 全部：仅中国境内可用、全部不支持模拟器、起始版本均为 **5.0.0(12)**。

> 目录事实：在开发指南目录中，`Core Speech Kit`、`Core Vision Kit`、`Natural Language Kit`、`Speech Kit`、`Vision Kit` 是 **AI** 分类下的同级节点，Core 系与场景化系并非父子关系，而是并列的两套入口。

## Core 系 vs 场景化系：怎么分工

| 维度 | Core 系（Core Speech Kit / Core Vision Kit） | 场景化系（Speech Kit / Vision Kit） |
| --- | --- | --- |
| 交付物 | **原子 API**：引擎对象 + 方法调用，只返回数据 | **控件 / 整套交互**：ArkUI 组件 + 系统内置 UI 与手势 |
| 导入路径 | `@kit.CoreSpeechKit` / `@kit.CoreVisionKit` | `@kit.SpeechKit` / `@kit.VisionKit` |
| UI 归属 | 应用自己画 | 系统提供，消费者层面交互一致 |
| 可定制度 | 高（自己控流程、控界面） | 低到中（只能通过 config / controller / 回调调节） |
| 典型入口 | `textToSpeech.createEngine()`、`textRecognition.recognizeText()` | `TextReaderIcon`、`AICaptionComponent`、`CardRecognition`、`DocumentScanner` |
| 系统能力命名 | `SystemCapability.AI.OCR.*`、`SystemCapability.AI.Face.*` 等（按算法分） | 多数带 `Component`：`SystemCapability.AI.Component.TextReader` / `.CardRecognition` / `.DocScan` / `.LivenessDetect` |

**官方原文依据**（逐字引用）：

1. Vision Kit《个人数据处理说明》：「**场景化视觉服务通过对基础视觉服务的场景化封装，提供服务于某种场景的场景化能力，同时提供消费者层面一致的交互和开发者层面的控制 API**」——这是最直接的一句定性。
2. 《Core Vision Kit简介》：「开发者可以**结合 Vision Kit 的 UI 控件能力**（例如：人脸活体检测），提升应用的智能化、便捷化交互体验。」
3. 《Core Speech Kit简介》：文本转语音「**实现效果可参考朗读控件**」；语音识别「**实现效果可参考 AI 字幕控件**」——Core 的原子能力对应场景化的成品控件。
4. 《Speech Kit简介》：「Speech Kit（场景化语音服务）集成了语音类 AI 能力，**包括朗读控件（TextReader）和 AI 字幕控件（AICaptionComponent）能力**」。
5. 《Vision Kit简介》：「Vision Kit（场景化视觉服务）集成了视觉类 AI 能力，包括人脸活体检测（interactiveLiveness）能力、卡证识别（CardRecognition）能力、文档扫描（DocumentScanner）能力、AI 识图控件（visionImageAnalyzer）能力。」

一句话概括分工：**Core 系给算法，场景化系给成品交互。** 但注意这不是「上层封装下层」的严格包含关系——AI 识图明确说自己是「聚合 OCR、主体分割、实体识别、多目标识别等 AI 能力」，而卡证识别、文档扫描、活体检测在官方文档中并未声明由哪些 Core 接口拼装而成。

## Natural Language Kit

**定位纠偏**：官方目录把它和 Speech / Vision Kit 放在同一层，但它**没有任何 UI 控件**，也没有「Core 版」。功能形态等同于 Core 系：纯原子 API。

子能力清单（官方目录共 **2** 个）：

| 能力 | 在线/离线 | 是否 UI 控件 | 输入 | 输出 | 起始 API Level | 导入路径 | 来源 slug |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 分词 | ⚠️ 待核实（见下） | 否，纯 API | `text: string`，≤1000 字符 | `Promise<Array<WordSegment>>`，每项含 `word`（词语）+ `wordTag`（词性） | 5.0.0(12) | `import { textProcessing } from '@kit.NaturalLanguageKit';` | `natural-language-getwordsegmentation` |
| 实体抽取 | ⚠️ 待核实 | 否，纯 API | `text: string`（≤1000 字符）+ 可选 `EntityConfig` | `Promise<Array<Entity>>`，每项含 `text` / `charOffset` / `type` / `jsonObject` | 5.0.0(12) | `import { textProcessing, EntityType } from '@kit.NaturalLanguageKit';` | `natural-language-getentity` |

- 完整方法签名（逐字抄自 API 参考）：
  - `getWordSegment(text: string): Promise<Array<WordSegment>>`
  - `getEntity(text: string, entityConfig?: EntityConfig): Promise<Array<Entity>>`
  - `init(): Promise<boolean>` / `release(): Promise<boolean>`（`release()` 后再调用会触发重新初始化，增加耗时）
- 系统能力：`SystemCapability.AI.NaturalLanguage.TextProcessing`；模型约束：仅 Stage 模型。
- 支持的 10 类实体（`EntityType` 枚举值逐字）：`DATETIME`='datetime'、`EMAIL`='email'、`EXPRESS_NO`='expressNo'、`FLIGHT_NO`='flightNo'、`LOCATION`='location'、`NAME`='name'、`PHONE_NO`、`URL`、`VERIFICATION_CODE`、`ID_NO`（后四个的字面值未逐一抄到，⚠️ 待核实）。
- `EntityConfig.timestamp`（参考时间戳，用于指定实体识别的时间上下文）**从 26.0.0 起**才有。
- 支持设备：Phone、Tablet、PC/2in1。国家/地区：**仅适用于中国境内（港澳台除外）**。不支持模拟器。
- 权限：API 参考中**未标注「需要权限」**，即无需申请权限、无需用户交互授权。
- 并发限制（原文）：「不支持同一应用并发调用同一个特性」，同进程同时重复调用返回 **错误码 1011200002**（系统繁忙）；不同进程排队。
- **在线/离线判定**：官方从未写「端侧」或「云侧」。间接证据是错误码 `200 运行超时` 的可能原因写「当前设备 CPU 或者 NPU 占用过高」，指向端侧推理；但这只是推断，标 ⚠️。
- 语种口径不一致：简介写「简体中文、**中文语境下的英文**、繁体中文」，两个子页写「简体中文、**英文**、繁体中文」。⚠️ 以简介为准存疑。

## Speech Kit（场景化语音）

子能力清单（官方目录共 **2** 个控件）：

| 能力 | 在线/离线 | 是否 UI 控件 | 输入 | 输出 | 起始 API Level | 导入路径 | 来源 slug |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 朗读控件 TextReader | 基础朗读未标注；**切换音色需网络权限** | 是 —— `TextReaderIcon` 听筒图标 + 系统播放面板 + Minibar + 通知栏 | `ReadInfo[]`（`id` / `title` / `author` / `date` / `bodyInfo` 正文文本） | 语音播报 + 事件回调（`stateChange`、`readProgress`、`clickArticle`、`requestMore` 等） | 5.0.0(12)；`TextReaderIconV2` 为 **6.1.1(24)** | `import { TextReader, TextReaderIcon, ReadStateCode, WindowManager } from '@kit.SpeechKit';` | `speech-textreader-guide` |
| AI 字幕控件 AICaptionComponent | ⚠️ 待核实（含翻译，可能需网络） | 是 —— 可嵌入页面的 `@Component` 字幕面板 | `AudioData { data: Uint8Array }` 经 `controller.writeAudio()` 写入；**5.1.0(18) 起**支持自动识别应用音频 | 屏幕上的原文/译文字幕；`onPrepared` / `onError` 回调 | 5.0.0(12)；`isCapabilitySupported()` 为 **26.0.0**；`sourceLanguage`/`targetLanguage`/`fontSize`/`fontColor` 为 **6.1.1(24)** | `import { AICaptionComponent, AICaptionController, AICaptionOptions, AICaptionFontSize, AudioInfo, AudioData } from '@kit.SpeechKit';` | `speech-aicaption-guide` |

- 系统能力：朗读控件 `SystemCapability.AI.Component.TextReader`；AI 字幕 `SystemCapability.AI.AICaption`。均仅 Stage 模型。
- 支持设备：Phone、Tablet、PC/2in1。国家/地区：仅中国境内（港澳台除外）。不支持模拟器。AI 字幕「部分机型暂不支持，调用失败返回对应错误码初始化失败」。
- 权限（全部为 system_grant，**无需用户弹窗授权**）：
  - `TextReader.init()` API 参考标注「需要权限：`ohos.permission.KEEP_BACKGROUND_RUNNING`」；错误码 `201 权限校验失败` 的原因即「开发者未配置 `ohos.permission.KEEP_BACKGROUND_RUNNING`」。同时需在 ability 上加 `"backgroundModes": ["audioPlayback"]`，并把 `ReaderParam.keepBackgroundRunning` 设为 `true`。
  - 切换音色需 `ohos.permission.INTERNET` + `ohos.permission.GET_NETWORK_INFO`。
  - AI 字幕控件：guide 与 API 参考均**未提及任何权限**（音频由应用自己写入）。
- 语种/格式限制：朗读控件仅**中文**；AI 字幕**中英文**，音频流仅 `pcm` 编码、16000 采样率、单声道、16 位。译文组合：源为英文时 `targetLanguage` 可 `['zh','en','zh-en']`，源为中文时仅 `['zh']`。
- 2in1 有额外适配步骤：必须在 `EntryAbility.onWindowStageCreate` 里 `WindowManager.setWindowStage(windowStage)`，并**另建一个 ability 承载 2in1 主窗**，否则「将会出现无法拉起播放面板的情况」。
- 无「个人数据处理说明」页（Vision Kit 与 Core Speech Kit 都有，Speech Kit 目录里没有）。

**与 Core Speech Kit 的差异**

| | Core Speech Kit | Speech Kit |
| --- | --- | --- |
| 导入 | `@kit.CoreSpeechKit` | `@kit.SpeechKit` |
| 能力 | `textToSpeech`（文本转语音）、`speechRecognizer`（语音识别） | `TextReader`（朗读控件）、`AICaptionComponent`（AI 字幕控件） |
| 形态 | `createEngine()` 拿引擎，`speak()` / `startListening()`，UI 全自写 | 直接放组件进页面，播放面板/字幕面板由系统绘制 |
| 文本上限 | TTS 不超过 10000 字符；ASR 短语音 ≤60s、长语音 ≤8h | 未给出等价的字符/时长上限（⚠️ 未确认） |
| 离线性 | 语音识别官方明确「支持的模型类型：**离线**」 | 未明确标注 |
| 模拟器 | **从 6.0.0(20) 起支持模拟器** | 不支持模拟器 |

## Vision Kit（场景化视觉）

子能力清单（官方目录共 **4** 个能力 + 1 篇《个人数据处理说明》）：

| 能力 | 在线/离线 | 是否 UI 控件 | 输入 | 输出 | 起始 API Level | 导入路径 | 来源 slug |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 人脸活体检测 `interactiveLiveness` | **纯端侧算法**（官方原文） | 是 —— 跳转到系统提供的独立检测页面 | `InteractiveLivenessConfig`（`actionsNum`、`routeMode` 等），相机实时视频由控件采集 | `startLivenessDetection(): Promise<boolean>`；结果经 `getInteractiveLivenessResult(): Promise<InteractiveLivenessResult>` 取回 | 5.0.0(12)；`DetectionMode` **26.0.0 起废弃** | `import { interactiveLiveness } from '@kit.VisionKit';` | `vision-interactiveliveness` |
| 卡证识别 `CardRecognition` | ⚠️ 未确认 | 是 —— `@Component`，「创建弹窗，并以全模态形式展示」 | `supportType: CardType`、`cardSide: CardSide`、`CardRecognitionConfig`（拍摄模式、是否支持选图等） | `onResult: (params: CardRecognitionResult)`，含 `code` / `cardType` / `cardInfo.front|back|main` 结构化字段 + 卡证图片 | 5.0.0(12)；港澳/台通行证 **6.1.1(24) 起**；`callback` 参数 **5.1.1(19) 起废弃**，改用 `onResult` | `import { CardRecognition, CardRecognitionResult, CardType, CardSide, CardRecognitionConfig, ShootingMode, CardContentConfig, BankCardConfig, IdCardConfig } from '@kit.VisionKit';` | `vision-cardrecognition` |
| 文档扫描 `DocumentScanner` | ⚠️ 未确认 | 是 —— `@Component`，全屏拍摄+编辑界面 | `DocumentScannerConfig`（`supportType`、`isGallerySupported`、`maxShotCount`、`defaultFilterId`、`defaultShootingMode`、`isShareable`、`originalUris`） | `onResult: (code: number, saveType: SaveOption, uris: string[])`，输出图片/PDF 的 uri 列表 | 5.0.0(12) | `import { DocType, DocumentScanner, DocumentScannerConfig, SaveOption, FilterId, ShootingMode, EditTab, DocumentScannerResultCallback, DocumentScannerController } from '@kit.VisionKit';` | `vision-documentscanner` |
| AI 识图 `visionImageAnalyzer` | ⚠️ 识图搜索疑似需网络（返回百科知识、模态窗搜索结果），官方未写 | 是 —— **不是独立控件**，而是挂在 `Image` / `Video` / `XComponent` 基础控件上的能力 + `AIButton` | `PixelMap`（仅 `RGBA_8888`）、最小 100×100、静态非矢量图 | 长按取词/抠图/实体快捷操作；回调 `textAnalysis`、`subjectAnalysis`、`selectedSubjectsChange` 等返回文本与主体分割结果 | 5.0.0(12)；部分接口 **5.1.0(18)** | `import { visionImageAnalyzer } from '@kit.VisionKit';` | `vision-imageanalyzer` |

- 系统能力：`SystemCapability.AI.Component.LivenessDetect` / `SystemCapability.AI.Component.CardRecognition` / `SystemCapability.AI.Component.DocScan` / `SystemCapability.AI.VisionImageAnalyzer`。均仅 Stage 模型。
- 支持设备（官方分能力给出）：活体检测 / 卡证识别 / 文档扫描 **Phone、Tablet**；AI 识图 **Phone、Tablet、PC/2in1**。国家/地区：仅中国境内（港澳台除外）。整个 Kit 不支持模拟器。
- **计费**：「动作活体检测能力、卡证识别能力实施试用期免费的计费政策，**试用期至 2026 年 12 月 31 日**。开始正式收费前，华为将会提前通过正式途径发布计费调整通告。」——三个 Kit 里唯一涉及收费的地方。
- 权限：
  - `interactiveLiveness.startLivenessDetection` API 参考标注「需要权限：`ohos.permission.CAMERA`」。CAMERA 是 user_grant，**需要用户交互授权**；guide 里相应地 `import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit'`。
  - 卡证识别、文档扫描、AI 识图的 API 参考中**均未出现「需要权限」字段**，guide 也未要求配置权限；相机与光照传感器由系统控件自行使用。
- 能力查询接口（写代码前应先调，否则部分机型直接失败）：
  - AI 识图：`aiController.getImageAnalyzerSupportTypes()`，返回 `[]` 即当前设备不支持。
  - 文档扫描表格提取：`new DocumentScannerController().isSheetDetectionSupported()`。
- 活体检测的安全性口径（原文）：「端侧算法在 HarmonyOS NEXT/5.0.x 已完成权威机构（CFCA）检测认证」，「推荐开发者使用在考勤打卡、辅助登录和实名认证等**低危业务场景**中」，减少动作数量会降低安全性；支付/金融场景建议自行做风险评估。不支持横屏、分屏；平板仅竖屏，大折叠仅折叠态、小折叠仅展开态。
- 卡证覆盖范围：中国二代身份证（不含民汉双语）、国内银行卡、中国护照、驾驶证、行驶证、港澳居民来往内地通行证、台湾居民来往大陆通行证。
- 数据留存（《个人数据处理说明》，最后修改 2025/6/13）：图片、视频、光照传感器信息、设备型号、屏幕信息一律「**不留存**」，「云端不存储用户数据」；文档扫描/卡证识别的传感器数据「均在端侧使用」。

**与 Core Vision Kit 的差异**

| | Core Vision Kit | Vision Kit |
| --- | --- | --- |
| 导入 | `@kit.CoreVisionKit` | `@kit.VisionKit` |
| 子能力数 | 8（通用文字识别、人脸检测、人脸比对、主体分割、多目标识别、骨骼点检测、图像超分、通过文本搜索图片） | 4（人脸活体检测、卡证识别、文档扫描、AI 识图） |
| 形态 | `textRecognition.recognizeText()` 之类的函数，输入 `VisionInfo`（PixelMap），输出结构化结果 | 组件 / 页面跳转，自带相机、拍摄引导、编辑、弹窗 |
| 设备 | Phone、Tablet、PC/2in1（全能力统一） | 分能力不同，活体/卡证/扫描仅 Phone、Tablet |
| 计费 | 未提及收费 | 动作活体、卡证识别试用期免费至 2026-12-31 |

## 选型建议

| 需求 | 用哪个 |
| --- | --- |
| 要「跟系统一样」的朗读体验（播放面板、Minibar、通知栏、锁屏播控） | **Speech Kit / TextReader**。自己用 Core Speech 的 `textToSpeech` 重做这些 UI 成本极高 |
| 要自定义 TTS 播放器 UI、或要把合成音频落盘/二次处理 | **Core Speech Kit / textToSpeech**（`onData` 拿音频数据） |
| 要给音视频加实时字幕，接受系统字幕样式 | **Speech Kit / AICaptionComponent** |
| 要拿到识别文本本身做检索、断句、导出字幕文件 | **Core Speech Kit / speechRecognizer**（离线模型） |
| 身份证/银行卡/驾驶证信息填表 | **Vision Kit / CardRecognition**，直接拿结构化字段 |
| 识别非标准卡证、自定义票据、自建版式模板 | **Core Vision Kit / textRecognition**，自己做版式解析 |
| 扫描文档出 PDF、含拍摄引导与滤镜 | **Vision Kit / DocumentScanner** |
| 实名认证要做动作活体 | **Vision Kit / interactiveLiveness**（只有场景化系有，Core 系只有人脸检测/比对，做不了活体） |
| 图片长按取词/抠图这类「系统级」交互 | **Vision Kit / visionImageAnalyzer**，挂在 Image/Video/XComponent 上 |
| 后台批量处理图片、无 UI、要控制并发与时序 | **Core Vision Kit**（场景化控件强绑用户手势与前台界面） |
| 中文分词、从短信/留言里抽手机号快递单号 | **Natural Language Kit**，无 UI，直接调 |

判定规则：**只要需求里出现「用户要看到并操作某个界面」，先去场景化系找现成控件；只要需求里出现「我要那份数据/我要自己画」，就下沉到 Core 系。**

## AI 容易写错的点

1. **包名只差一个 `Core`，且两边同名概念并不互通。** 正确写法：
   - `@kit.CoreSpeechKit` → `textToSpeech`、`speechRecognizer`
   - `@kit.SpeechKit` → `TextReader`、`TextReaderIcon`、`TextReaderIconV2`、`AICaptionComponent`、`AICaptionController`、`AICaptionOptions`、`AICaptionFontSize`、`AudioInfo`、`AudioData`、`ReadStateCode`、`WindowManager`
   - `@kit.CoreVisionKit` → `textRecognition`、`faceDetector`、`faceComparator`、`subjectSegmentation`、`objectDetection`、`skeletonDetection`、`imageSuperResolution`、`textSearchImage`、`visionBase`
   - `@kit.VisionKit` → `interactiveLiveness`、`visionImageAnalyzer`、`CardRecognition`、`DocumentScanner`
   把 `interactiveLiveness` 写成从 `@kit.CoreVisionKit` 导入，或把 `textRecognition` 写成从 `@kit.VisionKit` 导入，都是错的。
2. **命名大小写有规律，别乱套**：场景化系里 ArkUI 组件是大驼峰（`CardRecognition`、`DocumentScanner`、`AICaptionComponent`），命名空间型 API 是小驼峰（`interactiveLiveness`、`visionImageAnalyzer`）；Core 系全部是小驼峰命名空间。
3. **`AudioData` / `AudioInfo` 在两个 Kit 里都存在但不是同一个类型**：`@kit.SpeechKit` 的 `AudioData` 用于 `AICaptionController.writeAudio()`，`@kit.CoreSpeechKit` 的 `speechRecognizer` 也有 `AudioInfo` 和 `writeAudio`。混用会类型不匹配。
4. **`CardRecognition` 的 `callback` 参数从 5.1.1(19) 起废弃**，新代码必须用 `onResult`；官方还提示两者同时配置时只有 `callback` 生效。
5. **`TextReaderIcon` vs `TextReaderIconV2` 按状态管理版本选**：官方原文「应用使用 ArkTS 的状态管理 V1 装饰器时，需要通过 `TextReaderIcon` 组件接口拉起；使用状态管理 V2 装饰器时，需要通过 `TextReaderIconV2`」。`TextReaderIconV2` 起始版本 6.1.1(24)。
6. **`TextReader` 必须先 `init()`**，官方注意事项：「调用朗读控件接口前，必须先调用 `init` 初始化，否则会报错」；2in1 还必须先在 `onWindowStageCreate` 调 `WindowManager.setWindowStage()`。
7. **不要凭直觉给场景化控件加 CAMERA 权限**：只有 `interactiveLiveness.startLivenessDetection` 官方标注需要 `ohos.permission.CAMERA`；卡证识别与文档扫描的官方文档未要求任何权限。
8. **别忘了设备能力查询**：AI 字幕 `isCapabilitySupported()`（26.0.0 起）、AI 识图 `getImageAnalyzerSupportTypes()`、文档扫描 `isSheetDetectionSupported()`。跳过这些在部分机型上会直接失败。
9. **`interactiveLiveness.DetectionMode` 从 26.0.0 起废弃**（`SILENT_MODE` 本就「暂未支持」）。写新代码不要再传检测模式。
10. **不要把 Natural Language Kit 当成有 UI 的场景化 Kit**——它没有任何组件，只有 `textProcessing` 的四个方法。

## 未确认 / 待核实

- ⚠️ **Natural Language Kit 是否端侧推理**：官方未直接写「端侧」/「云侧」。仅错误码 200 提到「设备 CPU 或者 NPU 占用过高」，属间接证据。
- ⚠️ **AI 字幕控件是否需要联网**：涉及语音识别 + 翻译，官方 guide/API 参考均未说明网络依赖，也未要求 INTERNET 权限。
- ⚠️ **AI 识图的「识图搜索」是否需要联网**：返回百科知识与模态搜索结果，强烈暗示需要网络，但官方未写，也未标注权限。
- ⚠️ **卡证识别 / 文档扫描是否端侧完成**：《个人数据处理说明》只写「不留存」「云端不存储用户数据」，未等价于「不上传」。
- ⚠️ **朗读控件基础朗读是否离线**：只知道「切换音色」需要 INTERNET + GET_NETWORK_INFO 权限，基础播报的离线性未标注。
- ⚠️ **NLK 语种口径**：简介写「中文语境下的英文」，子页写「英文」，两者不一致。
- ⚠️ **`EntityType` 中 `PHONE_NO` / `URL` / `VERIFICATION_CODE` / `ID_NO` 的字面枚举值**未逐字核对（前六个已核对）。
- ⚠️ **Speech Kit 的文本长度 / 音频时长上限**：Core Speech 有明确上限（10000 字符 / 60s / 8h），Speech Kit 侧未给出等价数字。
- **未确认**：Speech Kit 没有《个人数据处理说明》页面，其数据处理口径无独立出处。
- 本文所有代码片段均抄自官方文档，**未在本机编译或运行验证**（本机无 DevEco Studio / hvigorw / ohpm）。

## 来源

catalogName 为 `harmonyos-guides` 或 `harmonyos-references`，URL 形如 `https://developer.huawei.com/consumer/cn/doc/<catalogName>/<slug>`。全部访问日期：**2026-09-01**。

| 文档标题 | slug | catalog | 文档 version / 更新时间 |
| --- | --- | --- | --- |
| Natural Language Kit简介 | `natural-language-introduction` | guides | V233 / 2026-08-31（内容更新 2026-08-29） |
| 分词 | `natural-language-getwordsegmentation` | guides | V233 / 2026-08-31（内容更新 2026-04-20） |
| 实体抽取 | `natural-language-getentity` | guides | V233 / 2026-08-31（内容更新 2026-04-20） |
| textProcessing（文本处理） | `natural-language-text-processing-api` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| EntityType（实体类型） | `natural-language-entity-type-api` | references | V11 / 2026-08-31（内容更新 2026-08-29） |
| ArkTS API错误码（NLK） | `errorcode-natural-language` | references | V21 / 2026-08-31（内容更新 2026-07-28） |
| Speech Kit简介 | `speech-production` | guides | V233 / 2026-08-31（内容更新 2026-06-12） |
| 朗读控件 | `speech-textreader-guide` | guides | V233 / 2026-08-31（内容更新 2026-08-29） |
| AI字幕控件 | `speech-aicaption-guide` | guides | V233 / 2026-08-31（内容更新 2026-08-29） |
| TextReader（朗读控件） | `speech-textreader-api` | references | V232 / 2026-08-31（内容更新 2026-09-01） |
| TextReaderIcon（朗读听筒图标） | `speech-textreadericon` | references | V232 / 2026-08-31（内容更新 2026-09-01） |
| TextReaderIconV2（朗读听筒图标） | `speech-textreadericonv2` | references | V36 / 2026-08-31（内容更新 2026-09-01） |
| AICaptionComponent（AI字幕组件） | `speech-aicaptioncomponent` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| WindowManager（窗口管理） | `speech-windowmanager` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| ArkTS API错误码（Speech Kit） | `errorcode-speech` | references | V21 / 2026-08-31（内容更新 2026-06-12） |
| Vision Kit简介 | `vision-introduction` | guides | V233 / 2026-08-31（内容更新 2026-04-30） |
| 人脸活体检测 | `vision-interactiveliveness` | guides | V233 / 2026-08-31（内容更新 2026-08-29） |
| 卡证识别 | `vision-cardrecognition` | guides | V233 / 2026-08-31（内容更新 2026-05-28） |
| 文档扫描 | `vision-documentscanner` | guides | V233 / 2026-08-31（内容更新 2026-07-28） |
| AI识图 | `vision-imageanalyzer` | guides | V233 / 2026-08-31（内容更新 2026-04-29） |
| 个人数据处理说明（Vision Kit） | `visionkit-personal-data` | guides | V213 / 2026-08-31（内容更新 2026-04-20；数据清单最后修改 2025-06-13） |
| interactiveLiveness（人脸活体检测） | `vision-interactive-liveness` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| visionImageAnalyzer（AI识图控件） | `vision-image-analyzer` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| CardRecognition（卡证识别控件） | `vision-card-recognition` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| DocumentScanner（文档扫描控件） | `vision-document-scanner` | references | V232 / 2026-08-31（内容更新 2026-08-29） |
| Core Speech Kit简介（对照用） | `core-speech-introduction` | guides | V233 / 2026-08-31（内容更新 2026-05-14） |
| Core Vision Kit简介（对照用） | `core-vision-introduction` | guides | V233 / 2026-08-31（内容更新 2026-08-29） |
| textToSpeech / speechRecognizer（核对导入路径） | `hms-ai-texttospeech` / `hms-ai-speechrecognizer` | references | 2026-08-31 抓取 |
| textRecognition / faceDetector / subjectSegmentation（核对导入路径） | `core-vision-text-recognition-api` 等 | references | 2026-08-31 抓取 |

