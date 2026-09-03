# Core Vision Kit（基础视觉服务）

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段**未编译验证**（未落进 `harmony/HybridShell/`；编译链已于 2026-09-03 就位，但没校验过这些片段）

## 一句话

Core Vision Kit 提供 **8 个**图像类基础视觉能力（OCR / 人脸检测 / 人脸比对 / 主体分割 / 多目标识别 / 骨骼点检测 / 图像超分 / 文本搜图），全部走 `@kit.CoreVisionKit`、仅 Stage 模型、仅中国境内、不支持模拟器；API 分**两套风格**——老能力用「模块级 `init()/release()` + `VisionInfo`」，新能力用「`XxxAnalyzer.create()/destroy()` + `visionBase.Request`」，混用是最常见的写错点。

## 子能力清单

官方目录（`core-vision-kit-guide`）下共 10 个节点，其中 1 个是简介、1 个是个人数据说明，**子能力恰好 8 个**。二维码、卡证识别、文档扫描、AI 识图、人脸活体检测**不在本 Kit**（后四者属 `vision-kit-guide` / Vision Kit 场景化视觉服务，已核实目录）。

| 子能力 | 在线/离线 | 输入 | 输出 | 起始版本(API Level) | 导入路径 | 来源 slug |
| --- | --- | --- | --- | --- | --- | --- |
| 通用文字识别 OCR | ⚠️ 未确认 | `VisionInfo{pixelMap}`，仅 RGBA_8888 PixelMap | `TextRecognitionResult{value, blocks[]}` → `TextBlock.lines[]` → `TextLine.words[]`，各级带 `cornerPoints` | 4.0.0(10)；`init/release` 为 5.0.0(12) | `import { textRecognition } from '@kit.CoreVisionKit'` | `core-vision-text-recognition-api` |
| 人脸检测 | ⚠️ 未确认 | `VisionInfo{pixelMap}` | `Array<Face>`：`probability` / `rect` / `pose(yaw,pitch,roll)` / `points`（5 点） / `block?` | 5.0.0(12)；遮挡检测 `FaceRecognitionConfiguration`/`FaceBlock` 为 5.0.2(14) | `import { faceDetector } from '@kit.CoreVisionKit'` | `core-vision-face-detector-api` |
| 人脸比对 | ⚠️ 未确认 | 两个 `VisionInfo{pixelMap}`，必须 RGBA_8888 | `FaceCompareResult{isSamePerson, similarity(0~1)}` | 5.0.0(12) | `import { faceComparator } from '@kit.CoreVisionKit'` | `core-vision-facecomparator-api` |
| 主体分割 | ⚠️ 未确认 | `VisionInfo{pixelMap}` + `SegmentationConfig` | `SegmentationResult{subjectCount, fullSubject, subjectDetails?}`；`SubjectResult{foregroundImage, mattingList(Int32Array,0-255), subjectRectangle}` | 5.0.0(12) | `import { subjectSegmentation } from '@kit.CoreVisionKit'` | `core-vision-subjectsegmentation-api` |
| 多目标识别 | ⚠️ 未确认 | `visionBase.Request{inputData:{pixelMap}}` | `ObjectDetectionResponse{objects[]}`；`VisionObject{boundingBox, score(0,1), labels:Array<number>, id}` | 5.0.0(12) | `import { objectDetection, visionBase } from '@kit.CoreVisionKit'` | `core-vision-object-detection-api` |
| 骨骼点检测 | ⚠️ 未确认 | `visionBase.Request{inputData:{pixelMap}}` | `SkeletonDetectionResponse{skeletons[]}`；`Skeleton{boundingBox, score, points[]}`，17 个 `SkeletonPointType` | 5.0.0(12) | `import { skeletonDetection, visionBase } from '@kit.CoreVisionKit'` | `core-vision-skeleton-detection-api` |
| 图像超分 | ⚠️ 未确认 | `visionBase.Request`，**仅支持单张图片** | `ISPResponse{pixelMap}`，官方措辞「像素同步放大四倍」 | 26.0.0（对应 API Level 文档未给出，⚠️ 待核实） | `import { imageSuperResolution, visionBase } from '@kit.CoreVisionKit'` | `core-vision-image-super-resolution-api` |
| 通过文本搜索图片 | ⚠️ 未确认 | **图片沙箱路径 string** + `scope` string；检索传 `query` string | `Array<ImageObject>{imagePath, scope, similarity(-1~1)}` | 26.0.0（对应 API Level 文档未给出，⚠️ 待核实） | `import { textSearchImage } from '@kit.CoreVisionKit'` | `core-vision-text-search-image-api` |

「在线/离线」一栏全部标未确认：**官方 8 篇指南与 8 篇 API 参考正文中，没有任何一处写明「端侧」「离线」「需联网」**。相关旁证只有两条，都不足以定论：`corevisionkit-personal-data` 说图片「不留存」「云端不存储用户数据」；`visionBase` 里存在模型下载事件（`on('downloadStart')` 等）与 `NO_NETWORK_STATUS` 状态码，但文档明确标注「该字段为预留接口，当前版本暂不支持」。

## 各能力要点

**通用文字识别（OCR）** — 支持简体中文 / 英文 / 日文 / 韩文 / 繁体中文五种（`getSupportedLanguages()` 返回 `zh-CN` / `en` / `ja` / `ko` / `zh-TW`）。SysCap `SystemCapability.AI.OCR.TextRecognition`。三个 `recognizeText` 重载：`(visionInfo, callback)`、`(visionInfo, configuration?)` → Promise、`(visionInfo, configuration, callback)`。`TextRecognitionConfiguration.isDirectionDetectionSupported` **默认 true**，确定图片正向时设 false 可提性能。结果三层嵌套：段落 → 行 → 单词，`cornerPoints` 顺时针、首元素为左上角。定位为印刷体，手写体能力欠缺。

**人脸检测** — 输出高精度矩形框、五官位置、人脸朝向、置信度。SysCap `SystemCapability.AI.Face.Detector`。`points` 只有 **5 个点**，顺序固定：左眼中心、右眼中心、鼻子、左嘴角、右嘴角。`pose` 三个角均为 [-180,180]。5.0.2(14) 起支持遮挡检测：`init(faceRecognitionConfiguration)` 传 `faceBlock: true`，结果里 `block` 才会是 `UNBLOCKED(0)` / `BLOCKED(1)`，否则为 `UNINITIALIZED(-1)`。官方明确写「接口调用耗时较久，不适合实时检测场景」。

**人脸比对** — SysCap `SystemCapability.AI.Face.Comparator`。**只支持 1v1**，不支持 1:N 检索。`compareFaces(visionInfo1, visionInfo2)` 返回 `isSamePerson` 与 `similarity`（0~1 浮点，1 为完全一致）。两张输入图都必须是 RGBA_8888。定位为身份验证、人脸解锁等场景。

**主体分割** — SysCap `SystemCapability.AI.Vision.SubjectSegmentation`。`SegmentationConfig.maxCount` 取值 **[1,20]，默认 6，超范围报错**，按主体面积占比降序。`enableSubjectDetails`、`enableSubjectForegroundImage` 默认均为 false。`subjectDetails` 只在 `enableSubjectDetails=true` 时返回，**用前必须判空**。`fullSubject` 是合并后的显著主体；主体面积占比需 ≥ 原图千分之五才被认定为主体；不建议用于文字密集图片。

**多目标识别** — SysCap `SystemCapability.AI.Vision.ObjectDetection`。`ObjectDetector` 继承 `visionBase.Analyzer`，**私有构造函数**，必须 `await ObjectDetector.create()`。`labels` 是 `Array<number>` 且编号不连续：0 风景、1 动物、2 植物、3 建筑、5 人脸、6 表格、7 文本、8 人头、9 猫头、10 狗头、11 食物、12 汽车、13 人体、21 文档、22 卡证（4、14~20 未定义）。物体占比需 > 0.1%。

**骨骼点检测** — SysCap `SystemCapability.AI.Vision.SkeletonDetection`。固定 **17 个关键点**，`SkeletonPointType` 枚举 0~16：鼻子、左右眼、左右耳、左右肩、左右肘、左右腕、左右髋、左右膝、左右踝。同样是 `SkeletonDetector.create()` / `process()` / `destroy()` 三段式。返回 `skeletons` 数组，支持图片内多人；点级和骨骼级各有 0~1 的 `score`。

**图像超分** — 26.0.0 新增。SysCap 是 `SystemCapability.AI.Vision.VisionBase`（**不是**独立的 ImageSR SysCap）。生命周期为 `ImageSRAnalyzer.create()` / `process()` / `destroy()`，官方示例在 `aboutToAppear` 建实例、`aboutToDisappear` 销毁。输入尺寸严格：16px < 高/宽 < 2048px；建议 ≤ 1024×1024，更高分辨率可能超时。仅支持单张输入。唯一错误码 1018700001。

**通过文本搜索图片** — 26.0.0 新增，SysCap `SystemCapability.AI.Vision.VisionBase`。跨模态检索，**必须先建库**：`insertImage(imagePath, scope)` 逐张插入特征，再 `search(query, scope, topKey?)`。参数长度限制：`imagePath` [1,128]、`scope` [1,32]（仅字母数字）、`query` [1,100] 且**不支持纯数字和纯字母**。`topKey` 默认 100，范围 [0,100]。另有 `deleteImage` 与 `clearData`。错误码 1013100003 表示「能力已更新」，需先 `clearData` 再重建库。

## 约束与限制

**Kit 级（`core-vision-introduction`）**

- 支持设备：Phone、Tablet、PC/2in1。
- 支持国家/地区：**仅中国境内**（香港特别行政区、澳门特别行政区、中国台湾除外）。
- **不支持模拟器**。
- 所有接口**仅可在 Stage 模型下使用**（每个 API 条目都标注了「模型约束」）。
- 并发：支持多用户同时接入；**不支持同一用户并发调用同一特性**。同一进程同一时间多次调用同一特性 → 返回系统繁忙错误；不同进程调用同一特性 → 同一时间只有一个进程在处理，其余排队。

**各能力输入图像限制（原文摘录）**

| 能力 | 尺寸 / 比例 | 其他 |
| --- | --- | --- |
| 文字识别 | 100px<高<15210px，100px<宽<10000px，高宽比建议 <10:1 | 格式 JPEG/JPG/PNG；文本 ≤10000 字符；拍摄角度与文本平面垂直方向夹角 <30°；印刷体为主 |
| 人脸检测 | 224px<高<15210px，100px<宽<10000px，高宽比建议 <10:1 | 耗时较久，不适合实时 |
| 人脸比对 | 两张图均 224px<高<15210px，100px<宽<10000px，比例 <10:1 | 仅 1v1 |
| 主体分割 | 20px<高<9000px，20px<宽<9000px，高宽比建议 <3:1 | 主体面积 ≥ 原图 5‰；不适合文字多的图 |
| 多目标识别 | 100px<高<10000px，100px<宽<10000px，高宽比建议 <5:1 | 物体占比 >0.1% |
| 骨骼点检测 | 100px<高<10000px，100px<宽<10000px，高宽比建议 <5:1 | — |
| 图像超分 | 16px<高<2048px，16px<宽<2048px，比例无要求 | 建议 ≤1024×1024，否则可能超时 |
| 文本搜图 | 100px<高<10000px，100px<宽<10000px，高宽比建议 <10:1 | — |

各能力均建议输入 720p 以上、接近手机屏幕高宽比。

**错误码**（`errorcode-core-vision`，Kit 特有部分）

| 码 | 归属 | 含义 |
| --- | --- | --- |
| 200 | 通用 | 运行超时，请重试 |
| 401 | 通用 | 参数检查失败（图片类型或参数值不合要求） |
| 1001400001 / 1001400002 | OCR | 运行失败 / 服务异常 |
| 1008400001 / 1008400002 | 人脸比对 | 运行失败 / 服务异常 |
| 1008800001 / 1008800002 | 人脸检测 | 运行失败 / 服务异常 |
| 1011000001~1011000004 | 主体分割、多目标、骨骼点共用 | 运行失败 / 服务异常 / 模型运行失败 / 模型运行超时 |
| 1018700001 | 图像超分 | 业务异常 |
| 1013100001~1013100003 | 文本搜图 | 图像不可用 / 服务异常 / 能力已更新（需 clearData） |

## 权限

**Core Vision Kit 自身未要求任何权限** —— 逐篇 grep 8 篇指南 + 8 篇 API 参考 + 错误码文档，正文中没有出现 `ohos.permission.*` 或权限申请章节（2026-09-01 核实）。

- 官方示例取图统一走 `photoAccessHelper.PhotoViewPicker`（Picker 由系统托管，示例中未申请相册读权限）。
- 唯一与权限相关的字样出现在 `visionBase` 的 `downloadStatusCode.COPY_FILE_FAILED` 描述里（「建议检查存储权限和可用空间」），而该整套下载接口标注为「预留接口，当前版本暂不支持」。
- ⚠️ 待核实：`textSearchImage` 读取应用沙箱路径图片，是否在跨沙箱场景下另需权限，文档未说明。

## 最小用法骨架

选 OCR（最常用，且是唯一有 Callback + Promise 全套重载的能力）。改写自 `core-vision-text-recognition` 官方示例。

```ts
// 适用 API Level：textRecognition 起始 4.0.0(10)；init/release 起始 5.0.0(12)
// 导入路径来源：core-vision-text-recognition-api「导入模块」章节
// ⚠️ 未编译验证：本片段未落进 harmony/HybridShell/
import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State chooseImage: PixelMap | undefined = undefined; // 需为 RGBA_8888
  @State dataValues: string = '';

  // 生命周期：init 加载模型，release 释放；不要每次识别都 init
  async aboutToAppear(): Promise<void> {
    const initResult: boolean = await textRecognition.init();
    hilog.info(0x0000, 'OCRDemo', `OCR init: ${initResult}`);
  }

  async aboutToDisappear(): Promise<void> {
    await textRecognition.release();
  }

  build() {
    Column() {
      Text(this.dataValues)
      Button('开始识别').onClick(() => this.recognize())
    }
  }

  private recognize(): void {
    if (!this.chooseImage) {
      return;
    }
    const visionInfo: textRecognition.VisionInfo = { pixelMap: this.chooseImage };
    const config: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false // 默认 true；确定图片正向时关掉更快
    };
    textRecognition.recognizeText(visionInfo, config)
      .then((data: textRecognition.TextRecognitionResult) => {
        this.dataValues = data.value; // 整段文本；细粒度看 data.blocks[].lines[].words[]
      })
      .catch((error: BusinessError) => {
        hilog.error(0x0000, 'OCRDemo', `code: ${error.code}, msg: ${error.message}`);
      });
  }
}
```

新式能力（多目标 / 骨骼点 / 图像超分）的骨架完全不同，形状是：

```ts
// ⚠️ 未编译验证。来源：core-vision-object-detection 官方示例
const request: visionBase.Request = { inputData: { pixelMap } };
const detector = await objectDetection.ObjectDetector.create();
const data: objectDetection.ObjectDetectionResponse = await detector.process(request);
await detector.destroy();
```

## AI 容易写错的点

1. **两套生命周期风格不能混**。模块级 `init()` / `release()`：`textRecognition`、`faceDetector`、`faceComparator`、`subjectSegmentation`、`textSearchImage`。类级 `create()` / `process()` / `destroy()`：`objectDetection.ObjectDetector`、`skeletonDetection.SkeletonDetector`、`imageSuperResolution.ImageSRAnalyzer`。给 `objectDetection` 写 `init()`、或给 `textRecognition` 写 `create()`，都是编不过的臆造。
2. **两套入参结构也不能混**。老能力：各自模块导出的 `VisionInfo{pixelMap}`（`textRecognition.VisionInfo`、`faceDetector.VisionInfo`、`faceComparator.VisionInfo`、`subjectSegmentation.VisionInfo` 是**四个各自独立的同名类型**，不是共享类型）。新能力：`visionBase.Request{inputData: ImageData | ImageData[]}`。
3. **`textSearchImage` 不吃 PixelMap**，吃沙箱路径字符串 + scope，而且必须先 `insertImage` 建库才能 `search`；`query` 不支持纯数字或纯字母。
4. **Analyzer 类不能 `new`**。`ObjectDetector` / `SkeletonDetector` 构造函数是私有的，只能 `await Xxx.create()`。
5. **人脸五官只有 5 点**（左眼中心、右眼中心、鼻子、左嘴角、右嘴角），不是 68/106 点；骨骼点固定 17 个。写成其他数量即为编造。
6. **`objectDetection` 的 `labels` 是 `Array<number>` 且编号跳号**（无 4、14~20），不要当成连续枚举或字符串标签。
7. **`SegmentationConfig.maxCount` 默认 6、范围 [1,20]，超范围报错**；`subjectDetails` 需 `enableSubjectDetails=true` 才返回，取用前判空。
8. **错误码按能力分段**，不要把 OCR 的 1001400001 写到人脸上；主体分割、多目标、骨骼点共用 1011000001~1011000004 这一段。
9. **别把 Vision Kit 的能力算进 Core Vision Kit**：人脸活体检测、卡证识别、文档扫描、AI 识图在 `vision-kit-guide` 下（已核实目录），是另一个 Kit、另一套导入路径。
10. **`recognizeText` 的 `isDirectionDetectionSupported` 默认是 true**，不是 false。
11. **图像超分与文本搜图的 SysCap 是 `SystemCapability.AI.Vision.VisionBase`**，没有自己的 SysCap 名；不要臆造 `SystemCapability.AI.Vision.ImageSuperResolution`。
12. **并发限制**：同一进程对同一特性并发调用会返回系统繁忙，需要自己串行化，不要写并行 `Promise.all` 批量识别。
13. **不要声称支持模拟器或海外可用**，也不要写成 FA 模型可用（全部标注「仅 Stage 模型」）。

## 未确认 / 待核实

- ⚠️ **端侧 / 云侧**：8 个子能力**没有任何一个**在官方正文中被标注为端侧离线或需联网。不要写「全部端侧离线」——那是推断，不是事实。
- ⚠️ **26.0.0 对应的 API Level 数字**：`imageSuperResolution` 与 `textSearchImage` 的「起始版本」写作 `26.0.0`，括号里没有 API Level（对比 `5.0.0(12)`、`5.0.2(14)`、`4.0.0(10)`）。映射关系未确认。
- ⚠️ **视频帧输入**：文档只提供 `image.PixelMap` 入口，未见任何视频流 / 相机帧接口。是否可行未确认。
- ⚠️ **具体支持机型与最低 ROM 版本**：只写到 Phone / Tablet / PC/2in1 三类形态。
- ⚠️ **二维码 / 条码能力归属**：不在 Core Vision Kit 目录内，一般认为属 Scan Kit，但本次**未核实** Scan Kit 目录，不作断言。
- ⚠️ **元服务（Atomic Service）支持范围**：只在 `faceDetector` 的 `Face` 字段上看到「元服务 API：从 5.0.2(14) 开始」标注，其他能力未逐条核实。
- ⚠️ **图像超分「像素同步放大四倍」**：未说明是边长 ×2（面积 ×4）还是边长 ×4，原文仅此一句。
- ⚠️ **OCR「文本长度不超过 10000 字符」**：仅见于 `core-vision-introduction` 的能力限制表，API 参考未复述，是否为硬性截断未确认。
- ⚠️ **模型下载机制**：`visionBase` 的 `on('downloadStart'/'downloadComplete'/'downloadCancel'/'downloadStatus'/'downloadProgress')`、`DownloadXxxData`、`downloadStatusCode` 全部标注「预留接口，当前版本暂不支持」。`Request.scene`（`SceneMode.FOREGROUND/BACKGROUND`）与 `Request.requestId` 同样是「预留字段，暂未实现」。
- ⚠️ **精度指标**：官方未给出任何量化精度（准确率 / mAP 等），只有置信度字段与输入质量建议。
- ⚠️ **`corevisionkit-personal-data` 的内容时效**：正文标「最后修改时间：2025/6/13」，早于文档系统的 2026 更新时间。

## 来源

全部通过站点 JSON 接口（`getCatalogTree` / `getDocumentById`）读取正文，访问日期均为 **2026-09-01**。`version` 与 `updated` 取自接口返回的元信息，`displayUpdateTime` 为页面展示的更新时间。所有文档 `labels` 均为 `["hmos-503"]`。

| 文档标题 | slug | URL | version / updated / displayUpdateTime |
| --- | --- | --- | --- |
| Core Vision Kit简介 | `core-vision-introduction` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-introduction | V233 / 2026-08-31 17:49:42 / 2026-08-29 |
| 通用文字识别（指南） | `core-vision-text-recognition` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-text-recognition | V233 / 2026-08-31 17:49:44 / 2026-05-12 |
| 人脸检测（指南） | `core-vision-face-detector` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-face-detector | V233 / 2026-08-31 17:49:49 / 2026-08-29 |
| 人脸比对（指南） | `core-vision-face-comparator` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-face-comparator | V233 / 2026-08-31 17:49:50 / 2026-08-29 |
| 主体分割（指南） | `core-vision-subject-segmentation` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-subject-segmentation | V233 / 2026-08-31 17:49:51 / 2026-07-28 |
| 多目标识别（指南） | `core-vision-object-detection` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-object-detection | V233 / 2026-08-31 17:49:53 / 2026-08-29 |
| 骨骼点检测（指南） | `core-vision-skeleton-detection` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-skeleton-detection | V233 / 2026-08-31 17:49:54 / 2026-08-29 |
| 图像超分（指南） | `core-vision-image-super-resolution` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-image-super-resolution | V21 / 2026-08-31 17:49:54 / 2026-07-28 |
| 通过文本搜索图片（指南） | `core-vision-text-search-image` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-text-search-image | V21 / 2026-08-31 17:49:55 / 2026-07-28 |
| 个人数据处理说明 | `corevisionkit-personal-data` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/corevisionkit-personal-data | V213 / 2026-08-31 17:49:55 / 2026-08-29（正文标「最后修改时间：2025/6/13」） |
| visionBase（Core Vision Kit基类） | `core-vision-vision-base-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-vision-base-api | V232 / 2026-08-31 18:00:06 / 2026-08-29 |
| textRecognition（文字识别） | `core-vision-text-recognition-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-text-recognition-api | V232 / 2026-08-31 18:00:04 / 2026-08-29 |
| faceDetector（人脸检测） | `core-vision-face-detector-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-face-detector-api | V232 / 2026-08-31 18:00:05 / 2026-08-29 |
| faceComparator（人脸比对） | `core-vision-facecomparator-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-facecomparator-api | V232 / 2026-08-31 18:00:05 / 2026-08-29 |
| subjectSegmentation（主体分割） | `core-vision-subjectsegmentation-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-subjectsegmentation-api | V232 / 2026-08-31 18:00:06 / 2026-08-29 |
| objectDetection（多目标识别） | `core-vision-object-detection-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-object-detection-api | V232 / 2026-08-31 18:00:06 / 2026-08-29 |
| skeletonDetection（骨骼点检测） | `core-vision-skeleton-detection-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-skeleton-detection-api | V232 / 2026-08-31 18:00:06 / 2026-08-29 |
| imageSuperResolution（图像超分） | `core-vision-image-super-resolution-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-image-super-resolution-api | V21 / 2026-08-31 18:00:06 / 2026-08-29 |
| textSearchImage（通过文本搜索图片） | `core-vision-text-search-image-api` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/core-vision-text-search-image-api | V21 / 2026-08-31 18:00:06 / 2026-08-29 |
| ArkTS API错误码 | `errorcode-core-vision` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/errorcode-core-vision | V21 / 2026-08-31 18:00:03 / 2026-07-28 |
| Vision Kit（场景化视觉服务）目录 | `vision-kit-guide` | https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/vision-kit-guide | 仅用于核实能力归属边界，未读正文 |
