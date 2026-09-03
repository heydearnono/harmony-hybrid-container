# 资料索引

最后更新：2026-09-03

写入 `docs/` 的每个事实都应能在这里找到出处。新增条目时补上访问日期——鸿蒙官方文档会随版本改写，URL 不变但内容会变。

可信度标注：
- **A** 华为官方文档 / 官方仓库 / 官方大会公告
- **B** 官方渠道的二手转述（媒体报道官方发布会等）
- **C** 社区文章、论坛帖、第三方博客 —— 只作线索，结论需回到 A 类核实

## 索引怎么用

本轮共引用官方文档 **150+ 页**，逐页平铺会让这张表无法维护。因此分两级：

- **这里**登记每个主题的一手入口、可信度、访问日期。
- **每篇 `docs/` 文档文末**都有自己的完整来源表（slug、URL、文档 version、`updatedDate`、访问日期），那是逐条事实的出处。

URL 拼法：`https://developer.huawei.com/consumer/cn/doc/<catalog>/<slug>`，`catalog` 见下。
正文抓取方式见 [00-doc-retrieval.md](00-doc-retrieval.md)，工具是 `tools/hwdoc.py`。

已确认可用的 catalog：

| catalog | 内容 | 备注 |
| --- | --- | --- |
| `harmonyos-guides` | 开发指南 | 目录树约 1.2 MB JSON |
| `harmonyos-references` | API 参考 | 起始版本、权限、错误码看这里 |
| `harmonyos-releases` | 版本说明与兼容性 | 版本号、现网设备分布 |
| `AppGallery-Connect` | AGC 文档 | ⚠️ `getCatalogTree` 返回空树，未打通 |

## 一手入口（全部访问日期 2026-09-01，可信度 A）

### 版本与工具链 → `docs/01-platform-landscape.md`

| 主题 | slug | catalog | 文档 version / updated |
| --- | --- | --- | --- |
| 26.0.0 版本说明 | `overview-2600` | releases | V6 / 2026-08-29 |
| 版本号规则变更（取消整数 API Level） | `version-number-26` | releases | V5 / 2026-08-29 |
| 全版本列表 | `overview-allversion` | releases | V51 / 2026-08-29 |
| 现网 SDK 版本分布（数据截至 08-20） | `sdk-version-percentage` | releases | V43 / 2026-08-29 |
| 支持设备 | `support-device` | releases | V62 / 2026-08-29 |
| 开发工具总览 | `ide-tools-overview` | guides | V112 / 2026-08-28 |
| Hvigor 与命令行构建 | `ide-hvigor` · `ide-hvigor-commandline` · `ide-command-line-building-app` | guides | V107 / V113 / V114 |
| Command Line Tools | `command-line-tools-overview` · `ide-commandline-get` | guides | V178 / V110 |
| 工程结构与配置文件 | `ide-project-structure` · `application-package-structure-stage` · `app-configuration-file` · `module-configuration-file` | guides | V108 / V235 / V235 / V235 |
| 真机与模拟器 | `ide-run-device` · `ide-emulator-requirements` | guides | V107 / V109 |

### 官方 AI 编码工具 → `docs/04-official-ai-coding-tools.md`

| 主题 | slug | catalog | 文档 version / updated |
| --- | --- | --- | --- |
| DevEco CLI 总览 / 安装 / 命令 | `ide-deveco-cli-overview` · `ide-deveco-cli-install` · `ide-deveco-cli-options` · `ide-deveco-cli-developtask` | guides | V6 · V6 · V6 · V1 / 2026-08-28 |
| DevEco Code 总览 / 安装 / Agent / 模型 | `ide-deveco-code-overview` · `ide-deveco-code-install` · `ide-deveco-code-agent` · `ide-deveco-code-model` | guides | V6 / 2026-08-28 |
| MCP 与智能体接入 | `ide-agent-mcp` | guides | V55 / 2026-08-28 |
| CodeGenie（被标「不推荐」者） | `ide-codegenie` · `ide-codegenie-releasenote` | guides | V110 / V93 |

### 端侧 AI 能力 → `docs/02-ondevice-ai-map.md` 与 `docs/ai-kit/`

| Kit | 入口 slug（指南） | 细节笔记（含完整来源表） |
| --- | --- | --- |
| Core Speech Kit | `core-speech-introduction` · `texttospeech-guide` · `speechrecognizer-guide` | [core-speech-kit.md](ai-kit/core-speech-kit.md) |
| Core Vision Kit | `core-vision-introduction` + 8 个能力页 | [core-vision-kit.md](ai-kit/core-vision-kit.md) |
| Natural Language / Speech / Vision（场景化） | `natural-language-introduction` · `speech-production` · `vision-introduction` | [scenario-kits.md](ai-kit/scenario-kits.md) |
| MindSpore Lite / NNRt / CANN | `mindspore-lite-kit-introduction` · `neural-network-runtime-kit-introduction` · `cannkit-introduction` | [inference-runtimes.md](ai-kit/inference-runtimes.md) |
| Intents Kit / Agent Framework Kit | `intents-introduction` · `hmaf-introduction` | [intents-and-agent-framework.md](ai-kit/intents-and-agent-framework.md) |

各 Kit 的 API 参考（起始版本、权限、错误码）在 `harmonyos-references`，slug 见对应笔记文末。

### ArkTS 与术语 → `docs/03-arkts-codegen-rules.md`、`docs/glossary.md`

| 主题 | slug | catalog |
| --- | --- | --- |
| 官方术语表 | `glossary` · `arkts-glossary` · `ability-terminology` · `application-package-glossary` · `hmaf-glossary` | guides |
| ArkTS 入门与 UI 范式 | `arkts-get-started` · `introduction-to-arkts` · `arkts-ui-development-overview` | guides |
| Stage 模型 | `stage-model-development-overview` · `application-package-overview` | guides |
| API 参考总入口 | `development-intro-api` | references |

规则清单里每条规则的具体依据 slug 见 `docs/03-arkts-codegen-rules.md` 的规则表与文末来源表。

### ArkWeb 与混合容器 → `docs/05-arkweb-hybrid-container.md`（访问日期 2026-09-02 / 2026-09-03，可信度 A）

**本项目当前主线方向。** 目录树根节点 `[arkweb]`，全部在 `harmonyos-guides` 下。

| 主题 | slug | 官方更新时间 |
| --- | --- | --- |
| ArkWeb 简介（Chromium 内核版本表、权限、模拟器支持） | `web-component-overview` | 2026-06-12 |
| 应用侧调前端函数 | `web-in-app-frontend-page-function-invoking` | 2026-08-29 |
| 前端调应用侧函数 | `web-in-page-app-function-invoking` | 2026-08-29 |
| 应用侧与前端数据通道 | `web-app-page-data-channel` | 2026-03-09 |
| 本地资源跨域 | `web-cross-origin` | 2026-08-29 |
| 拦截网络请求（SchemeHandler） | `web-scheme-handler` | 2026-08-29 |
| 自定义页面请求响应（`onInterceptRequest`） | `web-resource-interception-request-mgmt` | 2026-08-29 |
| Web 组件渲染模式（异步/同步、高度上限） | `web-render-mode` | 2026-08-29 |
| 同层渲染（规格约束、同层标签、四个回调） | `web-same-layer` | 2026-08-29 |
| 同层渲染原生组件（Trace 性能对比 5ms→1ms） | `same-layer-rendering-native-component` | 2026-08-18 |
| 使用离线 Web 组件（离屏预创建、预渲染、复用释放） | `web-offline-mode` | 2026-08-29 |
| ArkWeb 进程模型（五种进程、渲染进程共享策略） | `web_component_process` | 2026-08-29 |

API 参考（catalog `harmonyos-references`，访问日期 2026-09-02）：

| 主题 | slug |
| --- | --- |
| 模块描述（首批接口 API 9、上角标标版本的口径） | `arkts-apis-webview` |
| `WebviewController` 全部方法与起始版本（14000+ 行） | `arkts-apis-webview-webviewcontroller` |
| `WebMessagePort`（基础协议 / Ext 协议、错误码） | `arkts-apis-webview-webmessageport` |
| 入口页（下挂约 40 个类/接口页，多数未读） | `js-apis-webview` |

完整文档地图（约 60 个 slug）见 `docs/05-arkweb-hybrid-container.md` 的「官方文档地图」一节。
✅ `@ohos.web.webview` 模块方法的起始版本已补齐（2026-09-02）。
⚠️ 仍缺 `Web` **组件**属性/事件（`renderMode`、`enableNativeEmbedMode`、`registerNativeEmbedRule`、
`onNativeEmbed*`、`onInterceptRequest`、`javaScriptProxy`、`fileAccess`、`sharedRenderProcessToken`）
的起始版本——这些在**组件描述**页，不在 webview 模块页，未查。

## 工具链下载源（免登录直链，访问日期 2026-09-03，可信度 A）

这三处是「不登录华为账号也能拿到一套真编译器」的全部依据。装法与代价见
`harmony/README.md` 的「另一条路」、`research-log/2026-09-03-免登录编译打通.md`。

| 件 | URL | 校验方式 | 实测 |
| --- | --- | --- | --- |
| CLT 外壳（hvigor 6.26.1 + ohpm 26.0.0.410，`sdk/` 与 `tool/node/` 是空占位） | `https://repo.huaweicloud.com/openharmony/compiler/hvigor/6.26.1/command-line-tools.zip` | 同目录 `.sha256` | 77,819,058 B，✅ 对上 `6db6883a…c756079` |
| `tool/node`（Node 22.14.0 darwin-arm64） | `https://repo.huaweicloud.com/nodejs/v22.14.0/node-v22.14.0-darwin-arm64.tar.gz` | **nodejs.org 的 `SHASUMS256.txt`**（刻意不用镜像自报值） | 47,035,396 B，✅ 对上 |
| OpenHarmony SDK API 23 五组件（6.1.0.32） | `POST https://repo.harmonyos.com/sdkmanager/v5/ohos/getSdkList`，体 `{"osType":"darwin","osArch":"arm64","supportVersion":"26.0-ohos-single-1"}` | 响应里每项自带 `url` + `size` + `checksum` | 55 个组件**无鉴权**；下载 1,255 MB，解开 4.0 GB，✅ 逐件对过 |
| ohpm 仓库 | `https://ohpm.openharmony.cn/` | — | ✅ `@ohos/hamock`、`@ohos/hypium` 一次拉通 |

- ⚠️ `osType` 在 OpenHarmony 分支必须填 **`darwin`**（原值直传）；填 `mac` → `139403 参数校验未通过`。
- ⚠️ **登录门禁只挡 HarmonyOS SDK 本体。** HarmonyOS 侧的 `getSdkList` 虽也免鉴权，但只返回
  模拟器系统镜像，没有 ets / toolchains；`developer.huawei.com` 的 Command Line Tools 下载页
  要 Huawei ID + 动态验证码。
- ❌ **未采用**三方转载的 HarmonyOS SDK 包：无官方 sha256 可校验，且含可执行二进制、
  会直接进入编译产物链路。

## 非官方来源（B / C 类）

| 主题 | 来源 | 可信度 | 访问日期 | 用途 |
| --- | --- | --- | --- | --- |
| HarmonyOS 7 Developer Beta / API 26 时间点 | huaweicentral.com、dataconomy.com（2026-06-12）、nokiapoweruser.com | B | 2026-09-01 | 仅交叉印证时间点；版本口径以 `overview-2600`、`version-number-26` 为准 |
| Core Speech Kit 用法 | dev.to、hashnode 等个人博客 | C | 2026-09-01 | 仅作检索线索，未采信任何结论 |

## 注意

- 官方文档中有大量步骤是**截图**，`tools/hwdoc.py` 取不到图内信息，这是本通道的固有盲区。遇到关键步骤缺失时需人工打开页面确认。
- `docs/` 的结论绝大多数来自文档研读。**2026-09-03 起有了一个机器裁判**：
  `harmony/HybridShell/` 的 281 行 ArkTS 已过 `devecocli build`（OpenHarmony API 23），
  W1 由反向实验正面确认。但**编译通过不等于运行验证**，运行期语义的结论仍只有文档依据；
  `code-linter` 至今没有实体，静态检查这条线是空的。
