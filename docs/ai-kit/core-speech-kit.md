# Core Speech Kit（基础语音服务）

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段**未编译验证**（本机无鸿蒙工具链）

## 一句话

Core Speech Kit 提供两项**纯端侧（离线）**语音基础能力——文本转语音（`textToSpeech`）与语音识别（`speechRecognizer`），统一从 `@kit.CoreSpeechKit` 导入，起始版本 4.1.0(11)，**仅适用于中国境内**，识别只支持中文普通话。

## 能力清单

| 能力 | 在线/离线 | 输入 | 输出 | 硬上限 |
| --- | --- | --- | --- | --- |
| 文本转语音 TextToSpeech | 官方原文：「0 为在线，目前不支持；1 为离线，当前仅支持离线模式」→ **仅离线** | `string` 文本（支持简体中文、繁体中文、数字、中文语境下的英文） | 直接播报，或返回 PCM 音频流（`playType: 0` 时经 `onData` 回调返回 `ArrayBuffer`） | 文本 ≤ **10000 字符数**（不含首尾空格），超出报 `1002300001` |
| 语音识别 SpeechRecognizer | 官方原文：「支持的模型类型：离线」，`online` **仅支持 1（离线）** | PCM 音频流（`writeAudio` 写入 `Uint8Array`）或实时麦克风录音 | `SpeechRecognitionResult`（`result` 最优文本 + `isFinal` 子句终态 + `isLast` 末句标志） | 短语音模式 ≤ **60s**；长语音模式 ≤ **8h**；`writeAudio` 单次仅接受 **640 或 1280 字节** |

音色（TTS，来自 `CreateEngineParams.person` / `VoiceInfo.person` 官方原文）：

| 音色 | person 取值 | 是否需下载 |
| --- | --- | --- |
| 聆小珊 女声（中文） | **13**（「推荐使用 13，同时支持 0」） | 否 |
| 凌飞哲 男声（中文） | **21** | **需下载** |
| 英语（美国）劳拉 女声 | **8** | **需下载** |

音色状态由 `VoiceInfo.status` 表示：`'GA'` 可下载 / `'INSTALLED'` 已下载 / `'EOM'` 不可用（该字段起始版本 5.1.1(19)）。

## 关键 API

导入路径（两个模块同属一个 Kit）：

```ts
import { textToSpeech } from '@kit.CoreSpeechKit';
import { speechRecognizer } from '@kit.CoreSpeechKit';
```

| 用途 | 类/方法 | 导入路径 | 起始 API Level | 来源 slug |
| --- | --- | --- | --- | --- |
| TTS 建引擎（callback） | `textToSpeech.createEngine(params, callback)` | `@kit.CoreSpeechKit` | 4.1.0(11) | hms-ai-texttospeech |
| TTS 建引擎（Promise） | `textToSpeech.createEngine(params): Promise<TextToSpeechEngine>` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 查音色（模块级，Promise） | `textToSpeech.listVoices(queryParams): Promise<VoiceInfo[]>` | 同上 | **5.1.1(19)** | hms-ai-texttospeech |
| TTS 下载音色 | `textToSpeech.downloadVoice(downloadParams, callback)` | 同上 | **5.1.1(19)** | hms-ai-texttospeech |
| TTS 引擎类 | `textToSpeech.TextToSpeechEngine` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 查音色（引擎方法，callback / Promise） | `TextToSpeechEngine.listVoices(params[, callback])` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 设回调 | `TextToSpeechEngine.setListener(listener: SpeakListener)` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 合成播报 | `TextToSpeechEngine.speak(text: string, speakParams: SpeakParams)` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 停止 | `TextToSpeechEngine.stop()` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 忙碌查询 | `TextToSpeechEngine.isBusy(): boolean` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 释放 | `TextToSpeechEngine.shutdown()` | 同上 | 4.1.0(11) | hms-ai-texttospeech |
| TTS 音频流回调类型 | `textToSpeech.OnDataCallback` | 同上 | **5.1.1(19)** | hms-ai-texttospeech |
| TTS 下载事件订阅 | `on('start' \| 'progress' \| 'complete' \| 'cancel' \| 'error')` / 对应 `off(...)` | 同上 | **5.1.1(19)** | hms-ai-texttospeech |
| ASR 建引擎（callback / Promise） | `speechRecognizer.createEngine(params[, callback])` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 引擎类 | `speechRecognizer.SpeechRecognitionEngine` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 查语种 | `SpeechRecognitionEngine.listLanguages(query[, callback])` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 设回调 | `SpeechRecognitionEngine.setListener(listener: RecognitionListener)` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 开始识别 | `SpeechRecognitionEngine.startListening(params: StartParams)` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 写音频流 | `SpeechRecognitionEngine.writeAudio(sessionId: string, audio: Uint8Array)` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 结束/取消 | `SpeechRecognitionEngine.finish(sessionId)` / `cancel(sessionId)` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 忙碌查询 | `SpeechRecognitionEngine.isBusy(): boolean` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |
| ASR 释放 | `SpeechRecognitionEngine.shutdown()` | 同上 | 4.1.0(11) | hms-ai-speechrecognizer |

关键数据结构（名称一律照抄官方）：

- TTS：`CreateEngineParams`、`SpeakParams`、`VoiceQuery`、`VoiceInfo`、`VoiceDownload`、`DownloadResponse`、`SpeakListener`、`StartResponse`、`StopResponse`、`CompleteResponse`、`SynthesisResponse`
- ASR：`CreateEngineParams`、`LanguageQuery`、`StartParams`、`AudioInfo`、`SpeechRecognitionResult`、`RecognitionListener`
- 注意 `CreateEngineParams` 在 `textToSpeech` 与 `speechRecognizer` 两个命名空间下**同名但字段不同**（TTS 有 `person`，ASR 没有）。

系统能力（SysCap）：TTS 为 `SystemCapability.AI.TextToSpeech`，ASR 为 `SystemCapability.AI.SpeechRecognizer`。

元服务（原子化服务）：TTS 侧几乎全部接口标注「从版本 **6.1.1(24)** 开始，该接口支持在元服务中使用」；ASR 侧文档**未见**元服务标注。

## 约束与限制

| 维度 | 约束 | 来源 |
| --- | --- | --- |
| 支持设备 | Phone、Tablet、PC/2in1 | core-speech-introduction |
| 国家/地区 | 仅适用于中国境内（香港特别行政区、澳门特别行政区、中国台湾除外） | core-speech-introduction |
| 模拟器 | 从 **6.0.0(20)** 版本开始支持模拟器；模拟器与真机存在通用差异 | core-speech-introduction |
| 应用模型 | 所有接口「仅可在 **Stage 模型**下使用」 | hms-ai-texttospeech / hms-ai-speechrecognizer |
| TTS 实例数 | 「当前支持多应用、多实例，同一个设备上所有应用**一共最多支持 3 个实例**」（`extraParams.name`） | hms-ai-texttospeech · CreateEngineParams |
| TTS 调用顺序 | `speak` / `stop` / `isBusy` 均要求**先调用 `setListener`**，否则收不到对应回调 | hms-ai-texttospeech |
| TTS requestId | `SpeakParams.requestId`「全局不允许重复」；指南注释：「requestId 在同一实例内仅能用一次，请勿重复设置」 | hms-ai-texttospeech / texttospeech-guide |
| TTS 释放 | `shutdown()` 关闭引擎释放资源；未初始化引擎时调用 `speak` 会失败 | hms-ai-texttospeech / texttospeech-guide |
| TTS 引擎复用 | 错误码 `1002200001` 处理建议：「将创建成功的引擎实例进行存储，创建引擎参数相同的场景复用引擎实例，避免使用完立即销毁引擎」 | errorcode-corespeech |
| TTS 后台播报 | 默认不支持；需在 `CreateEngineParams.extraParams` 设 `'isBackStage': true` | hms-ai-texttospeech |
| TTS 音频通道坑 | `soundChannel` 默认 3（语音助手通道）；「如果使用了通道 1 或 12，设备息屏场景下，会出现播报截断的问题，原因是进入了音频的低功耗模式」 | hms-ai-texttospeech · SpeakParams |
| TTS 音频流排序 | `onData` 返回的音频流「需要按照 `sequence` 对音频流进行排序」，`sequence` 从 0 递增，取值范围 [0, 100000] | hms-ai-texttospeech |
| TTS 下载设备差异 | `downloadVoice` 「在 Phone、Tablet、2in1 设备中可正常调用，在其他设备中调起下载弹窗后点击下载返回 `1002300008` 错误码」 | hms-ai-texttospeech |
| ASR 调用顺序 | `writeAudio` 必须在 `createEngine` → `setListener` → `startListening` **之后**调用，否则写入失败或收不到回调；`finish` / `cancel` 也要求优先 `setListener` | hms-ai-speechrecognizer |
| ASR 音频格式 | 仅 `audioType: 'pcm'`、`sampleRate: 16000`、`sampleBit: 16`、`soundChannel: 1` | hms-ai-speechrecognizer · AudioInfo |
| ASR 写流节奏 | 单次 640 或 1280 字节；「每次发送音频调用间隔必须为 20ms（640 字节）或 40ms（1280 字节）」 | hms-ai-speechrecognizer |
| ASR 模式 | `extraParams.recognizerMode`：`'short'`（默认）/ `'long'`；`StartParams.extraParams.recognitionMode`：0 实时录音、1 写音频流（默认 1） | hms-ai-speechrecognizer |
| ASR VAD | `vadBegin` 范围 [500,10000]，默认 10000ms，长语音模式不支持配置；`vadEnd` 范围 [500,10000]，短语音默认 800ms 可配，长语音默认 500ms **不可配** | hms-ai-speechrecognizer · StartParams |
| ASR 时长 | `maxAudioDuration` 默认 20000ms；短语音 [20000,60000]，长语音 [20000, 8×60×60×1000] | hms-ai-speechrecognizer · StartParams |
| ASR 热词 | 系统热词 `sysGeneralLexicon`（建引擎时，整个识别过程生效）与会话热词 `sessionGeneralLexicon`（`startListening` 时，优先级更高，会话结束释放）；**总数 ≤ 200，每词长度 [2,20]** | hms-ai-speechrecognizer |
| ASR 单任务 | 重复 `startListening` 报 `1002200002`；引擎忙碌报 `1002200006`（「一般多个应用同时调用语音识别引擎时触发」） | errorcode-corespeech |
| ASR 音频文件位置 | 指南要求 pcm 文件放在 `main\resources\resfile` 路径下（运行时用 `context.resourceDir` 读取） | speechrecognizer-guide |

错误码要点（`errorcode-corespeech`，仅列本模块特有）：

| 错误码 | 含义 | 关键处理 |
| --- | --- | --- |
| 1002200001 | 创建引擎失败（语种/模式不支持、资源不存在、初始化超时、频繁创建销毁引起资源竞争） | 复用引擎实例，勿即用即销 |
| 1002200002 | 开始识别失败（重复启动） | 先查是否已启动 |
| 1002200003 | 超过最大音频长度 | 「建议音频长度不要超过 60000ms」 |
| 1002200004 / 1002200005 | 结束 / 取消识别失败（当前无识别任务） | 先 `startListening` |
| 1002200006 | 识别服务忙碌 | `isBusy` 查询后重试 |
| 1002200007 | 引擎未初始化 | 先 `speechRecognizer.createEngine` |
| 1002200008 | 引擎已被销毁 | 重新 `createEngine` |
| 1002200009 | 内部服务错误 | `writeAudio` 场景下标注「适用版本：5.1.0(18)+」 |
| 1002200010 | 未启动识别就写音频 | 先 `startListening` |
| 1002200011 | 识别中异常 | `startListening` 重试 |
| 1002200012 | 没有麦克风权限（`AudioCapturer create failed, please check the permission of MICROPHONE.`） | 检查 `ohos.permission.MICROPHONE` |
| 1002300001 | 文本长度非法（0 或超出，建议 ≤10000 字） | 改文本 |
| 1002300002 / 1002300003 | 语言 / 音色不支持 | 用 `listVoices` 查询后重试 |
| 1002300005 | 创建引擎失败（引擎服务异常、资源加载异常） | 稍后重试 |
| 1002300008 / 1002300009 / 1002300010 | 下载音色错误 / 下载参数错误 / 音色已下载过 | — |

## 权限

- **文本转语音：官方文档中未见任何权限声明要求。** 两份 TTS 文档（`texttospeech-guide`、`hms-ai-texttospeech`）没有「需要权限」字段，也没有出现 `ohos.permission.*`。
- **语音识别：只有「实时录音识别」场景需要麦克风权限。** 官方原文（`StartParams.extraParams.recognitionMode`）：「0：实时录音识别（需应用开启录音权限：`ohos.permission.MICROPHONE`）」。写音频流模式（`recognitionMode: 1`）文档未要求该权限。
- 声明方式（`speechrecognizer-guide` 原文）：在 `module.json5` 的 `requestPermissions` 中加入 —

```json5
// module.json5，来源 slug: speechrecognizer-guide（未编译验证）
'requestPermissions': [
  {
    'name': 'ohos.permission.MICROPHONE',
    'reason': '$string:reason',
    'usedScene': {
      'abilities': ['EntryAbility'],
      'when': 'inuse'
    }
  }
]
```

- 运行时申请（官方示例放在 `EntryAbility.onWindowStageCreate`）：`abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.context, ['ohos.permission.MICROPHONE'])`，来自 `@kit.AbilityKit`。官方文档在权限授权类型上写的是「需应用开启录音权限」并给出了 `requestPermissionsFromUser` 示例；`ohos.permission.MICROPHONE` 的正式授权类型（user_grant）**在本次所读的 4 篇 Core Speech Kit 文档里没有明写**，见「未确认」。

合规要点（`corespeechkit-personal-data`）：华为处理的个人数据仅音频（ASR 输入）与文本（TTS 输入）两类，存留期均为「**不留存**」，云端不存储用户数据；直接处理麦克风采集的语音时「需要开发者首先向用户申请麦克风权限并获得用户授权后方可使用」，且接入前须在**隐私政策中告知用户华为如何处理其个人数据并取得同意或其他合法性基础**。

## 最小用法骨架

```ts
// 未编译验证（本机无 DevEco Studio / ohpm）。
// 适用 API Level：4.1.0(11) 起（listVoices/downloadVoice 的模块级形式需 5.1.1(19)）
// 导入路径与 API 名称来源 slug：texttospeech-guide / hms-ai-texttospeech
//                                speechrecognizer-guide / hms-ai-speechrecognizer
// 以下基于官方示例裁剪，未新增任何官方文档之外的 API。
import { textToSpeech, speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';

// ---------- 1. 文本转语音 ----------
let ttsEngine: textToSpeech.TextToSpeechEngine;

function ttsDemo(): void {
  let extraParam: Record<string, Object> =
    { 'style': 'interaction-broadcast', 'locate': 'CN', 'name': 'EngineName' };
  let initParamsInfo: textToSpeech.CreateEngineParams = {
    language: 'zh-CN',
    person: 0,          // 官方 API 文档推荐 13（聆小珊），同时支持 0；指南示例用的是 0
    online: 1,          // 1 = 离线，当前仅支持离线
    extraParams: extraParam
  };

  textToSpeech.createEngine(initParamsInfo,
    (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
      if (err) {
        console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
        return;
      }
      ttsEngine = engine;

      // speak / stop / isBusy 之前必须先 setListener，否则收不到回调
      let speakListener: textToSpeech.SpeakListener = {
        onStart(requestId: string, response: textToSpeech.StartResponse) {},
        onComplete(requestId: string, response: textToSpeech.CompleteResponse) {},
        onStop(requestId: string, response: textToSpeech.StopResponse) {},
        onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
          // playType: 0 时才走这里；播放前需按 response.sequence 排序
        },
        onError(requestId: string, errorCode: number, errorMessage: string) {}
      };
      ttsEngine.setListener(speakListener);

      let speakExtra: Record<string, Object> = {
        'queueMode': 0, 'speed': 1, 'volume': 2, 'pitch': 1,
        'languageContext': 'zh-CN', 'audioType': 'pcm',
        'soundChannel': 3,  // 默认 3（语音助手通道）；1/12 在息屏时会被低功耗截断
        'playType': 1       // 1 = 合成并播报且不返回音频流；0 = 仅合成走 onData
      };
      let speakParams: textToSpeech.SpeakParams = {
        requestId: '123456' + Date.now(), // 全局不可重复
        extraParams: speakExtra
      };
      ttsEngine.speak('Hello HarmonyOS', speakParams);   // 文本 ≤ 10000 字符数
    });
}

function ttsRelease(): void {
  if (ttsEngine.isBusy()) {
    ttsEngine.stop();
  }
  ttsEngine.shutdown();
}

// ---------- 2. 语音识别（写音频流模式） ----------
let asrEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined;
const sessionId: string = '123456';

function asrDemo(): void {
  let extraParam: Record<string, Object> = { 'locate': 'CN', 'recognizerMode': 'short' };
  let initParamsInfo: speechRecognizer.CreateEngineParams = {
    language: 'zh-CN',   // 仅支持 zh-CN
    online: 1,           // 仅支持离线
    extraParams: extraParam
  };

  speechRecognizer.createEngine(initParamsInfo,
    (err: BusinessError, engine: speechRecognizer.SpeechRecognitionEngine) => {
      if (err) {
        // 1002200001 语种/模式/资源问题；1002200006 忙碌；1002200008 已销毁
        console.error(`Failed to create engine. Message: ${err.message}.`);
        return;
      }
      asrEngine = engine;

      let listener: speechRecognizer.RecognitionListener = {
        onStart(sessionId: string, eventMessage: string) {},
        onEvent(sessionId: string, eventCode: number, eventMessage: string) {
          // eventCode 1 = 音频开始，3 = 音频结束
        },
        onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
          // result.result 最优文本；result.isFinal 子句终态；result.isLast 末句
        },
        onComplete(sessionId: string, eventMessage: string) {},
        onError(sessionId: string, errorCode: number, errorMessage: string) {}
      };
      asrEngine?.setListener(listener);   // 必须在 startListening / writeAudio 之前

      let audioParam: speechRecognizer.AudioInfo =
        { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 };
      let startExtra: Record<string, Object> = {
        'recognitionMode': 0,      // 0 = 实时录音（需 MICROPHONE）；1 = 写音频流
        'vadBegin': 2000,
        'vadEnd': 3000,
        'maxAudioDuration': 20000
      };
      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: sessionId,
        audioInfo: audioParam,
        extraParams: startExtra
      };
      asrEngine?.startListening(recognizerParams);
    });
}

function asrWrite(chunk: Uint8Array): void {
  // 单次仅支持 640 或 1280 字节，且调用间隔须为 20ms / 40ms
  asrEngine?.writeAudio(sessionId, chunk);
}

function asrRelease(): void {
  asrEngine?.finish(sessionId);   // 或 cancel(sessionId)
  asrEngine?.shutdown();
}
```

## AI 容易写错的点

1. **导入路径是 `@kit.CoreSpeechKit`，不是 `@kit.SpeechKit`。** 后者对应的是另一个 Kit「Speech Kit（场景化语音服务）」（`TextReader` 朗读控件 / `AICaptionComponent` AI 字幕），二者是**不同 Kit、不同文档树**。凭记忆很容易混。
2. **命名空间是小驼峰、引擎类是大驼峰**：`textToSpeech.TextToSpeechEngine`、`speechRecognizer.SpeechRecognitionEngine`。注意 ASR 命名空间叫 `speechRecognizer`（-er），但引擎类叫 `SpeechRecognition**Engine**`（Recognition，不是 Recognizer）——两个词形在同一行代码里不一致。
3. **`online: 1` 表示离线**，`0` 表示在线且「目前不支持」。这个字段语义与命名直觉相反。
4. **参数几乎都塞在 `extraParams: Record<string, Object>` 里**，不是强类型字段。`speed` / `volume` / `pitch` / `soundChannel` / `playType` / `queueMode` / `vadBegin` / `recognitionMode` 全部是字符串 key，写错 key 不会有编译报错。
5. **`person: 13` 才是官方 API 文档推荐的中文音色**（聆小珊，`0` 兼容）；`21`（凌飞哲）和 `8`（英语劳拉）**需要先 `downloadVoice` 下载**。开发指南示例里用的是 `person: 0`，与 API 参考的推荐值不一致，容易被当成唯一写法。
6. **`writeAudio` 的第二参是 `Uint8Array`，不是 `ArrayBuffer`**，且长度只能是 640 或 1280 字节、调用间隔固定 20/40ms。直接把整个文件 buffer 丢进去必然失败。
7. **`CreateEngineParams` 在两个命名空间下同名不同构**：TTS 版有 `person`，ASR 版没有；ASR 版有 `recognizerMode`/`sysGeneralLexicon`，TTS 版有 `style`/`isBackStage`。
8. **TTS 的 `requestId` 与 ASR 的 `sessionId` 是两个不同概念的字段名**，不可互换；TTS 的 `requestId` 官方写「全局不允许重复」。
9. **调用顺序是硬约束**：TTS 必须 `createEngine` → `setListener` → `speak`；ASR 必须 `createEngine` → `setListener` → `startListening` → `writeAudio`。跳过 `setListener` 不会报错，只是永远收不到结果——很容易被误判为「能力不可用」。
10. **同一设备上所有应用的 TTS 实例总数上限是 3**，是系统级配额而非单应用配额。
11. **语音识别只支持中文普通话、只支持离线**，不要写出「设置 `language: 'en-US'` 做英文识别」这类代码。TTS 才支持英文。
12. **地区限制是硬性的**：仅中国境内（不含港澳台）。
13. TTS 的 `soundChannel` 默认 3；写 1 或 12 会在息屏时被音频低功耗模式截断——官方明确标注的坑。
14. ASR 的 pcm 素材路径官方写的是 `main\resources\resfile`（对应运行时 `context.resourceDir`），不是 `rawfile`。

## 未确认 / 待核实

- ⚠️ **待核实**：`ohos.permission.MICROPHONE` 的授权类型（user_grant / system_grant）与所需 APL 等级。本次所读的 4 篇 Core Speech Kit 指南 + 2 篇 API 参考 + 1 篇错误码文档中**均未写明**，只写「需应用开启录音权限」。需查权限总览文档确认，本文不臆测。
- ⚠️ **待核实**：错误码 `1002300007`（TTS 引擎未初始化）。`texttospeech-guide` 的示例代码中出现了 `if (errorCode === 1002300007) { engineCreated = false; }` 并注释「未初始化引擎时调用 speak 方法，返回错误码 1002300007」，但 `errorcode-corespeech` 的错误码清单与 `speak` 的错误码表中**都没有这一条**（清单只有 1002300001/002/003/005/008/009/010）。官方文档自身不一致。
- ⚠️ **待核实**：`StartParams` 的官方示例里出现了 `'srcType': 1`，但参数说明表中**没有** `srcType` 这一项。用途未知。
- **未确认**：TTS 是否存在与 ASR 类似的「引擎忙碌」并发语义、以及 TTS 引擎是否有单应用实例数限制（只查到设备级 3 实例上限）。
- **未确认**：具体支持的 PC/2in1 型号范围、`downloadVoice` 音色包体积与是否需要网络（`1002300008` 的可能原因写的是「没有网络或因内部服务错误导致的下载异常」，可推断需要网络，但未见正面表述）。
- **未确认**：语种/音色的「英文语境」边界——`introduction` 写 TTS 支持「中文语境下的英文」，`speechrecognizer-guide` 正文开头也写 ASR 输入可含「中文语境下的英文」，但同页约束表只写「中文普通话」。二者口径存在张力。
- **未确认**：本文所有代码片段均未编译、未运行（本机无 DevEco Studio / hvigorw / ohpm）。
- 版本口径说明：文档中的「起始版本」用 `x.y.z(N)` 表示，括号内 `N` 即 API Level（如 4.1.0(11) → API 11）。本文表格直接沿用官方写法。

## 来源

| 文档标题 | slug | URL | 文档 version 与更新时间 | 访问日期 |
| --- | --- | --- | --- | --- |
| Core Speech Kit（基础语音服务）（指南节点） | core-speech-kit-guide | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-speech-kit-guide | V233 / updated 2026-08-31 17:49:42（页面显示更新 2026-04-20） | 2026-09-01 |
| Core Speech Kit简介 | core-speech-introduction | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-speech-introduction | V233 / updated 2026-08-31 17:49:42（页面显示更新 2026-05-14） | 2026-09-01 |
| 文本转语音 | texttospeech-guide | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/texttospeech-guide | V233 / updated 2026-08-31 17:49:44（页面显示更新 2026-05-26） | 2026-09-01 |
| 语音识别 | speechrecognizer-guide | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/speechrecognizer-guide | V233 / updated 2026-08-31 17:49:49（页面显示更新 2026-06-16） | 2026-09-01 |
| 个人数据处理说明 | corespeechkit-personal-data | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/corespeechkit-personal-data | V213 / updated 2026-08-31 17:49:50（页面显示更新 2026-04-20；正文标「最后修改时间 2025/6/13」） | 2026-09-01 |
| Core Speech Kit（基础语音服务）（API 参考节点） | core-speech-api | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-speech-api | V232 / updated 2026-08-31 18:00:03 | 2026-09-01 |
| ArkTS API（节点） | core-speech-arkts | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-speech-arkts | V232 / updated 2026-08-31 18:00:03 | 2026-09-01 |
| textToSpeech（文本转语音） | hms-ai-texttospeech | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/hms-ai-texttospeech | V232 / updated 2026-08-31 18:00:04（页面显示更新 2026-08-29） | 2026-09-01 |
| speechRecognizer（语音识别） | hms-ai-speechrecognizer | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/hms-ai-speechrecognizer | V232 / updated 2026-08-31 18:00:05（页面显示更新 2026-08-29） | 2026-09-01 |
| ArkTS API错误码 | errorcode-corespeech | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/errorcode-corespeech | V232 / updated 2026-08-31 18:00:03（页面显示更新 2026-08-29） | 2026-09-01 |

所有页面 `labels` 均为 `["hmos-503"]`，`showBeta=0`。
