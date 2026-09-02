# 端侧推理运行时：MindSpore Lite / Neural Network Runtime / CANN Kit

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段**未编译验证**（本机无鸿蒙工具链）

## 一句话选型

- **绝大多数「应用里塞一个自己的模型」的需求 → MindSpore Lite Kit**。它是 HarmonyOS 内置的推理引擎，唯一提供 ArkTS 接口的一条路，CPU 后端不挑设备，可选择性地把 NNRt 当加速后端。
- **Neural Network Runtime Kit 不是给应用业务开发者的第一选择**。官方原文：Native 接口「主要面向 AI 推理框架的开发者，或者希望直接使用 AI 加速硬件实现模型推理加速的应用开发者」。它不提供 CPU 推理，强依赖 NPU。
- **CANN Kit 是麒麟平台的芯片侧异构计算栈**，同时也是 NNRt 在麒麟平台的后端。只有在「重载 AI 计算、要深度压性能功耗、要写自定义算子、要跑端侧 LLM」时才直接碰它，代价是 Linux 工具链 + C/C++ + NAPI 全套。
- 三者是**层级关系而非竞品**：应用 → MindSpore Lite Kit → NNRt → CANN Kit → NPU 驱动（官方「HarmonyOS AI 开放层次由上层到底层」原文表述）。

## 三者对照

| 维度 | MindSpore Lite Kit | Neural Network Runtime Kit | CANN Kit |
| --- | --- | --- | --- |
| 官方定位（原文） | 「HarmonyOS 内置的轻量化 AI 引擎，提供统一推理接口和多后端硬件加速能力」 | 「面向 AI 领域的跨芯片推理计算运行时，作为中间桥梁连通上层 AI 推理框架和底层加速芯片」 | 「海思 AI 硬件统一开放计算架构，支持 AscendC NPU 自定义编程、端云协同复用」；端云一致的异构计算架构 |
| 层级 | 应用层 SDK / 推理框架 | 系统推理运行时（框架与芯片之间的桥） | 芯片异构计算栈（NPU/CPU 协同 + 算子编程） |
| 调用方 → 被调用方 | 被应用调用；可向下调用 NNRt（共享 MindIR 图格式，**无需构图**） | 被 MindSpore Lite / 三方框架（文档点名 MNN、PaddleLite）/ 应用调用；向下调用 AI 硬件驱动 | 作为**麒麟平台的后端接入 NNRt**；也可由应用经 NNRt 的离线模型接口直接使用 |
| 开发语言与接口 | ArkTS（`@kit.MindSporeLiteKit`）+ C API（NDK）两条路；Native 路径需自行用 N-API 封装给 UI | 仅 Native C API | 仅 Native C API + NAPI 封装；模型转换/算子开发工具链在 Linux 上跑 |
| 头文件 / 库 | `<mindspore/model.h>`、`<mindspore/types.h>` 等；`libmindspore_lite_ndk.so` | `<neural_network_runtime/neural_network_core.h>`、`<neural_network_runtime/neural_network_runtime.h>`；`libneural_network_core.so`、`libneural_network_runtime.so` | `<CANNKit/hiai_options.h>` 等；`libhiai_foundation.so` + `libneural_network_core.so`（LLM 另有 `libcann_llm_engine.so`） |
| API 前缀 | `OH_AI_*` | `OH_NN_*` / `OH_NNModel_*` / `OH_NNCompilation_*` | `HMS_HiAI*`、`HMS_LLMEngine*`（基础编译/加载/推理复用 `OH_NN*`） |
| 模型格式 | 推理用 **`.ms`**；由 converter 从 MINDIR / CAFFE / TFLITE / TF / ONNX / PYTORCH / MSLITE 转换而来 | 无自有模型格式：要么由上层框架调构图接口在内存里建图，要么直接吃**硬件厂商的离线模型文件** | **`.om`** 离线模型；输入格式官方原文「当前仅支持 Caffe、TensorFlow、ONNX 和 MindSpore 模型转换」 |
| 模型转换工具 | `converter_lite`（发布件 `mindspore-lite-2.7.0-linux-x64.tar.gz`，Linux-x86_64；PyTorch 支持与部分融合关闭需源码编译） | 无（转换工作交给上层框架或硬件厂商工具） | **OMG 工具 `tools_omg`**，随 DDK 工具包（`DDK-tools-next-6.1.1.0`）下载，**需 Ubuntu 64 位**；另含轻量化工具 `tools_dopt`、算子工具 `tools_ascendc` |
| 起始版本 | C API 模块页写「起始版本 9」；ArkTS「首批接口从 API version 10 开始支持」 | `neural_network_runtime.h` 起始版本 9；`neural_network_core.h` 起始版本 11（原文注明部分接口 API 11 之前即可用） | C API 模块页「起始版本 4.1.0(11)」；`llm_engine.h` 起始版本 6.1.1(24) |
| SystemCapability | `SystemCapability.Ai.MindSpore`（C）/ `SystemCapability.AI.MindSporeLite`（ArkTS） | `SystemCapability.AI.NeuralNetworkRuntime` | `SystemCapability.AI.HiAIFoundation`；LLM 为 `SystemCapability.AI.CANN.LLMEngine` |
| 支持设备 / 芯片要求 | Phone、Tablet、PC/2in1、TV、Wearable（**Wearable 仅支持 CPU 推理**）；CPU 后端无芯片要求 | 「强依赖硬件，只适用于支持 NPU 的设备」 | 「仅适用于带有 Kirin NPU 的 Phone、Tablet、PC/2in1、TV 设备」；TV 自 5.1.1(19) 起支持 |
| 模拟器 | 支持，但**不支持 NPU 后端** | 暂不支持 | 暂不支持 |
| 上手成本 | 低（ArkTS 十几行可跑通）～中（C API） | 高：要自己构图或自备离线模型，且只能在 NPU 设备上验证 | 最高：Linux 转换环境 + C/C++ + NAPI + 真机（带 Kirin NPU） |

## 各自要点

### MindSpore Lite Kit

- 两阶段流程（原文）：**模型转换**（第三方模型 → `.ms`）+ **模型部署**（创建上下文 → 加载 `.ms` → 设置输入 → 执行推理读输出）。
- 两种开发方式（原文）：
  - 方式一：UI 代码里直接调 MindSpore Lite ArkTS API，「可快速验证效果」；
  - 方式二：Native API 封装成动态库，再用 N-API 暴露给 ArkTS。
- ArkTS 关键接口（来自 API 参考与指南）：`loadModelFromFile` / `loadModelFromBuffer` / `loadModelFromFd`、`getInputs()`、`predict()`、`MSTensor.setData()/getData()`；API 12 起有 `getAllNNRTDeviceDescriptions()` 与训练相关接口（`loadTrainModelFrom*`、`runStep`、`exportModel` 等）。
- C API 关键接口：`OH_AI_ContextCreate` / `OH_AI_ContextSetThreadNum` / `OH_AI_DeviceInfoCreate` / `OH_AI_ModelCreate` / `OH_AI_ModelBuildFromFile` / `OH_AI_ModelGetInputs` / `OH_AI_TensorGetMutableData`。CMake 里链接 `mindspore_lite_ndk`。
- 除推理外还有**端侧训练**指南（C/C++），并有算子支持列表页可查 ONNX 算子覆盖。
- **离线模型路线（可选）**：为压加载时延，可把硬件厂商的离线模型包进 `.ms`，由 NNRt 直接交给 AI 硬件，无需在线构图。约束（原文）：仅支持 NNRt 后端；离线模型转换工具**只能源码编译获取**；转换时 `--fmk` 必须指定为 `THIRDPARTY`；输入输出张量信息必须在扩展配置文件 `[third_party_model]` 节里手动写。
- ArkTS 侧限制（原文）：「ArkTS 接口不支持 NPU 后端动态 Shape 模型推理」，适配自有模型时**优先选静态 Shape**。

### Neural Network Runtime Kit

- 功能模块（原文）：在线构图、模型编译、模型推理、内存管理（借硬件驱动共享内存做「零拷贝」）、设备管理、模型缓存、离线模型推理。
- 两条使用姿势：
  1. 调构图接口把框架模型图翻成 NNRt 内部图 → 跨硬件无感知，但**首次加载慢**；
  2. 直接喂某款硬件的离线模型 → 加载快，但**只能在该硬件上跑**。
- 能力边界（原文，值得逐条记住）：
  - **不提供 CPU 等通用硬件上的推理能力**，只暴露已接入的 AI 加速硬件；
  - 只提供各家 NPU 共有的基础能力（编译、执行、内存、优先级、性能模式），厂商特有属性走「自定义扩展属性」接口，属性名和取值要查厂商文档；
  - 「目前支持常用算子 56 个」，且**算子本身没有实现**，实现在硬件驱动里；
  - 「目前仅支持同步推理」（与头文件里存在 `OH_NNExecutor_RunAsync` 冲突，见待核实）；
  - 不支持多线程并发构图。
- 编译环境（原文）：开发环境 Ubuntu 18.04 及以上；`target_link_libraries` 写 `neural_network_runtime` + `neural_network_core`。
- MindSpore Lite 对接 NNRt 的特殊待遇：两者共享 **MindIR** 图格式，因此 MindSpore Lite 不需要调 NNRt 构图接口，加载比其他框架快；MindSpore Lite 还支持 CPU/GPU 与 NNRt 硬件之间的**异构推理**。

### CANN Kit

只记定位与边界，算子开发细节不搬。

- 是什么：CANN（Compute Architecture for Neural Networks）是华为端云一致的异构计算架构；在 HarmonyOS 上「面向 Kirin 芯片平台为各种人工智能模型和算法提供统一的接入和运行环境」，协同调度 NPU/CPU。
- 面向谁：需要深度性能/功耗优化、要做模型量化压缩、要写自定义算子的开发者。达芬奇架构 NPU，**与云侧昇腾统一的 AscendC 算子编程语言与工具链**，「一次开发、多端运行」。
- 能力面（目录级别，不展开）：Model Zoo、模型轻量化/量化（含 Transformer/LLM 量化、LoRA 微调）、OMG 离线模型转换、AIPP 硬件图像预处理、端侧部署（推理/异构/内存零拷贝/深度融合）、单算子应用、AscendC 自定义算子开发与调优。
- **端侧部署实际走的是 NNRt 的接口**：官方开发步骤里创建编译实例用 `OH_NNCompilation_ConstructWithOfflineModelBuffer`（或 `...OfflineModelFile`），然后 `OH_NNDevice_GetAllDevicesID` 找 **name 为 `"HIAI_F"`** 的设备 ID，`OH_NNCompilation_SetDevice` → `OH_NNCompilation_Build` → `OH_NNExecutor_Construct` → `OH_NNTensor_Create` → `OH_NNExecutor_RunSync`。CANN 自己的头文件（`hiai_options.h` / `hiai_aipp_param.h` / `hiai_tensor.h` / `hiai_single_op.h` / `hiai_helper.h`）负责「高阶功能」——模块页原文：「CANN Kit 的模型编译、加载、推理等基础功能接口已抽取放在 `neural_network_core.h` 中」。
- 谁在用它：官方原文称它支撑 Core Vision Kit、Natural Language Kit 等的加速，也支撑 MindSpore Lite Kit、NNRt，以及三方 MNN、PaddleLite。
- **端侧 LLM**：`llm_engine.h` 提供 `HMS_LLMEngineExecutor_Generate` / `GenerateAsync`、Prompt/Context 对象等 API，库 `libcann_llm_engine.so`，起始版本 6.1.1(24)。这是目前查到的唯一「官方端侧大模型推理 C API」入口。
- 工具链获取：DDK 工具包（tools_dopt / tools_omg / tools_ascendc / platform）+ 平台插件包（`kirin9020` / `kirinx90` / `kirin9030`）。**OMG 必须在 Ubuntu 64 位上跑**，DevEco Studio 只负责应用侧。
- OMG 转换示例（未验证，仅抄原文形式）：`./omg --model resnet18.onnx --framework 5 --output ./resnet18` → 生成 `resnet18.om`；`--framework` 0=Caffe、3=TensorFlow、5=ONNX。ONNX 支持 opset 7~18（「最高支持到 V1.13.1」），TensorFlow 2.x，Caffe 1.0。

## 什么时候该自己带模型

| 情况 | 用什么 |
| --- | --- |
| 需求命中 Core Vision Kit 清单（OCR、人脸检测/比对、主体分割、多目标识别、骨骼点、图像超分、以文搜图）或 Core Speech Kit（文本转语音、语音识别） | 用开箱 Kit。ArkTS 直调、无模型文件、无转换工具链，成本最低 |
| 命中清单但被约束卡住（Core Vision 支持设备为 Phone/Tablet/PC/2in1，且「仅适用于中国境内」） | 考虑自带模型走 MindSpore Lite |
| 任务不在清单里（自有算法、自有训练数据、领域专用分类/检测/回归） | MindSpore Lite Kit + 自己的 `.ms` 模型 |
| 要控制模型版本、可离线更新、要跨设备一致的推理行为 | MindSpore Lite Kit |
| 已经卡在性能/功耗上，且目标机型确定为 Kirin NPU | CANN Kit（`.om` + AIPP + 量化 + 零拷贝） |
| 自己在做一个推理框架，或要绕过所有框架直接用 NPU | NNRt |

对「AI Agent 写鸿蒙应用」这条路，**MindSpore Lite Kit 的 ArkTS 路径是唯一现实的起点**：单一导入、Promise 风格、无需 CMake/NDK/NAPI、模拟器可跑（CPU）。NNRt 与 CANN Kit 都要求 Native 工程 + 真机 + 特定芯片，Agent 生成的代码无法在本机形成任何反馈闭环。

## AI 容易写错的点

- ArkTS 导入路径是 **`import { mindSporeLite } from '@kit.MindSporeLiteKit'`**；`@ohos.ai.mindSporeLite` 是 API 参考里的模块名，不是 import 路径。
- 工程默认能力集**可能不含 MindSporeLite**：需在 `entry/src/main/` 手建 `syscap.json`，`addedSysCaps` 加 `"SystemCapability.AI.MindSporeLite"`（官方指南明确要求）。
- 三套 C API 前缀不能混：MindSpore Lite 是 `OH_AI_*`，NNRt 是 `OH_NN*`，CANN 高阶是 `HMS_HiAI*`。
- 头文件目录名有大小写坑：`mindspore/...`、`neural_network_runtime/...`（小写下划线）、**`CANNKit/...`（大写）**。
- 链接库别写错：`mindspore_lite_ndk` / `neural_network_core` + `neural_network_runtime` / `libhiai_foundation.so` + `libneural_network_core.so`。
- **`.ms` 与 `.om` 是两回事**：`.ms` 由 `converter_lite` 产出给 MindSpore Lite；`.om` 由 `omg` 产出给 CANN/NNRt 离线路径。不存在「用 converter_lite 生成 .om」。
- MindSpore Lite 走离线模型时 `--fmk` 必须是 `THIRDPARTY`，且该转换工具**只能源码编译**得到。
- 不要假设 ArkTS 能用 NPU：示例明确写「本样例模型，不支持配置 `context.target = ["nnrt"]`」，且 ArkTS 不支持 NPU 后端动态 Shape。
- 不要假设 NNRt 能跑 CPU 兜底——官方明说它不提供 CPU 推理；CPU 兜底是 MindSpore Lite 或 CANN 异构的事。
- CANN 端侧选设备要按名字匹配 `"HIAI_F"`，不是按索引 0。
- 模拟器上只有 MindSpore Lite（CPU）可用；NNRt 与 CANN Kit 都「暂不支持模拟器」。
- PyTorch 模型不是开箱支持：下载版 converter 关闭了 PyTorch 编译选项，需 `MSLITE_ENABLE_CONVERT_PYTORCH_MODEL=on` 源码编译并配 libtorch。

## 未确认 / 待核实

- ⚠️ **NNRt 异步推理**：简介写「目前仅支持同步推理，计划在后续版本支持异步推理」，但 `neural_network_core.h` 的函数清单里存在 `OH_NNExecutor_RunAsync` 与 `OH_NNExecutor_SetOnRunDone`。文档内部不一致，实际可用性未验证。
- ⚠️ **CANN Kit 是否需要 NPU**：「约束与限制」写「仅适用于带有 Kirin NPU 的设备」，但「异构」一节写「在没有 NPU 的情况下，也能通过 CPU 提供更广泛的硬件适应能力」。两处冲突，未确认无 NPU 设备的真实行为。
- ⚠️ **起始 API Level 的口径**：MindSpore Lite C 模块页写「9」、ArkTS 写「API version 10」；CANN 模块页写「4.1.0(11)」。逐个接口的起始版本未核对，也未在本机 SDK 中验证（本机无 DevEco Studio）。
- ⚠️ NNRt「常用算子 56 个」只见于简介文字，**未找到 NNRt 的算子清单页**（MindSpore Lite 有 `mindspore-lite-supported-operators`，NNRt 目录下只有术语表）。
- 未确认：DDK 工具包、`kirin*-plugin` 的实际下载 URL 与是否需要登录/权限（文档只给了包名与 SHA256）。
- 未确认：`mindspore-lite-2.7.0-linux-x64.tar.gz` 是否为当前唯一发布版本，以及 macOS/Windows 下是否有 converter（文档只列 Linux-x86_64）。
- 未确认：GPU 后端的开放程度。简介提到「CPU/GPU 与 NNRt 之间的异构推理」，但设备类型枚举细节与实际可用性未逐项核对。
- 未确认：三方框架（MNN、PaddleLite）接入 CANN Kit 的具体路径，官方仅在简介中一句带过。
- 未读：CANN Kit 的量化/AscendC 算子开发全部子页（本次刻意跳过，仅取定位）。
- 未核对：Core Speech Kit 的设备与地域约束（本次只读了 Core Vision Kit 简介）。

## 来源

均为 `https://developer.huawei.com/consumer/cn/doc/<catalog>/<slug>`，访问日期 **2026-09-01**，`version` / `updated` 取自站点 JSON 接口返回。

| 文档标题 | catalog / slug | version ｜ updated |
| --- | --- | --- |
| MindSpore Lite Kit简介 | harmonyos-guides / `mindspore-lite-kit-introduction` | V233 ｜ 2026-08-31（内容更新 2026-08-29） |
| 使用MindSpore Lite进行模型转换 | harmonyos-guides / `mindspore-lite-converter-guidelines` | V233 ｜ 2026-08-31（内容更新 2026-08-29） |
| 使用MindSpore Lite进行模型推理 (C/C++) | harmonyos-guides / `mindspore-lite-guidelines` | V233 ｜ 2026-08-31（内容更新 2026-08-29） |
| 使用MindSpore Lite实现图像分类 (ArkTS) | harmonyos-guides / `mindspore-guidelines-based-js` | V233 ｜ 2026-08-31（内容更新 2026-08-29） |
| @ohos.ai.mindSporeLite (端侧AI框架) | harmonyos-references / `js-apis-mindsporelite` | V232 ｜ 2026-08-31（内容更新 2026-08-29） |
| MindSpore（C API 模块） | harmonyos-references / `capi-mindspore` | V188 ｜ 2026-08-31 |
| types.h（MindSpore Lite） | harmonyos-references / `capi-types-h` | V188 ｜ 2026-08-31 |
| Neural Network Runtime Kit简介 | harmonyos-guides / `neural-network-runtime-kit-introduction` | V233 ｜ 2026-08-31（内容更新 2026-03-12） |
| Neural Network Runtime对接AI推理框架开发指导 | harmonyos-guides / `neural-network-runtime-guidelines` | V233 ｜ 2026-08-31（内容更新 2026-03-09） |
| NeuralNetworkRuntime（C API 模块） | harmonyos-references / `capi-neuralnetworkruntime` | V188 ｜ 2026-08-31 |
| neural_network_core.h | harmonyos-references / `capi-neural-network-core-h` | V188 ｜ 2026-08-31（内容更新 2026-09-01） |
| neural_network_runtime.h | harmonyos-references / `capi-neural-network-runtime-h` | V188 ｜ 2026-08-31 |
| CANN Kit简介 | harmonyos-guides / `cannkit-introduction` | V214 ｜ 2026-08-31（内容更新 2026-08-29） |
| 开发准备（CANN Kit / Tools 下载） | harmonyos-guides / `cannkit-preparations` | V214 ｜ 2026-08-31（内容更新 2026-08-29） |
| 部署全流程（CANN Kit） | harmonyos-guides / `cannkit-whole-deployment-process` | V214 ｜ 2026-08-31（内容更新 2026-04-20） |
| 模型转换前准备（CANN Kit） | harmonyos-guides / `cannkit-preparing-for-model-conversion` | V214 ｜ 2026-08-31（内容更新 2026-04-20） |
| 模型转换示例（CANN Kit） | harmonyos-guides / `cannkit-model-conversion-example` | V214 ｜ 2026-08-31（内容更新 2026-08-29） |
| 模型推理（CANN Kit 端侧部署） | harmonyos-guides / `cannkit-model-inference` | V214 ｜ 2026-08-31（内容更新 2026-08-03） |
| 配置项目NAPI（CANN Kit） | harmonyos-guides / `cannkit-compiling-the-napi` | V214 ｜ 2026-08-31（内容更新 2026-04-20） |
| CANN（C API 模块） | harmonyos-references / `cannkit` | V213 ｜ 2026-08-31 |
| llm_engine.h（CANN Kit） | harmonyos-references / `cannkit-llm-engine` | V26 ｜ 2026-08-31 |
| Core Vision Kit简介 | harmonyos-guides / `core-vision-introduction` | V233 ｜ 2026-08-31（内容更新 2026-08-29） |

所有页面 `labels` 均为 `hmos-503`，即对应 HarmonyOS 5.0.3 文档分支（⚠️ 该标签与 API Level 的映射关系未核实）。
