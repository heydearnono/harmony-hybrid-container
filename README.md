# hmos — 鸿蒙混合容器，全程 AI 开发

一个**真实的鸿蒙基座**，整个项目由 AI Agent 开发。主题是**混合容器**：原生外壳 + H5 内容。

- **交付物是能编译、能装、能跑的工程**（`harmony/`），不是文档集
- `docs/` 是为这件事服务的知识底座 —— 事实清单 + 踩坑记录，服务于「让 Agent 可靠地产出鸿蒙代码」
- 当前主线：**混合容器 / ArkWeb**；端侧 AI 能力已有一轮沉淀，转为参考资料

## 从哪里开始读

| 想知道 | 看这里 |
| --- | --- |
| 怎么机器可读地拿到官方文档（**先读这个**） | [docs/00-doc-retrieval.md](docs/00-doc-retrieval.md) |
| 鸿蒙现在什么版本、工具链怎么装、工程长什么样 | [docs/01-platform-landscape.md](docs/01-platform-landscape.md) |
| **混合容器：ArkWeb、原生↔H5 通信、本地资源加载** | [docs/05-arkweb-hybrid-container.md](docs/05-arkweb-hybrid-container.md) |
| AI 写 ArkTS 时最容易写错什么 | [docs/03-arkts-codegen-rules.md](docs/03-arkts-codegen-rules.md) |
| 华为官方自己的 AI 编码工具（DevEco Code / CLI） | [docs/04-official-ai-coding-tools.md](docs/04-official-ai-coding-tools.md) |
| 工程在哪、还缺什么、人要做哪一步 | [harmony/README.md](harmony/README.md) |
| 端侧有哪些 AI 能力可用（参考资料） | [docs/02-ondevice-ai-map.md](docs/02-ondevice-ai-map.md) · [docs/ai-kit/](docs/ai-kit/) |
| 术语对不上 | [docs/glossary.md](docs/glossary.md) |
| 这些结论是怎么来的 | [research-log/](research-log/) · [docs/sources.md](docs/sources.md) |

## 目录

```
docs/            结论型知识（现在相信什么）
  ai-kit/        逐个端侧 AI 能力的细节（第一轮产出，参考资料）
  sources.md     资料索引：URL + 访问日期 + 可信度
research-log/    过程记录，只追加
experiments/     动手验证，一实验一目录
tools/           调研工具。hwdoc.py：抓官方文档目录与正文
harmony/         真实工程所在地。env.sh 是项目本地工具链环境变量
CLAUDE.md        项目约定与事实纪律，Agent 与人共同遵守
```

## 查官方文档就用这个

```bash
python3 tools/hwdoc.py tree harmonyos-guides AI     # 目录树，方括号里是文档 slug
python3 tools/hwdoc.py doc core-speech-introduction # 正文
```

文档中心是 SPA，`curl`/WebFetch 只能拿到空壳，搜索引擎也读不到正文。原理与坑见 [docs/00-doc-retrieval.md](docs/00-doc-retrieval.md)。

## 两条硬规矩

1. **每个事实都要有来源和日期**，查不到就标 `⚠️ 待核实`，不要用通顺的句子掩盖不确定。
2. 代码片段默认标注**未编译验证**。`harmony/HybridShell/` 里的代码已过 `devecocli build`
   （OpenHarmony API 23），标注改写为「已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行」——
   **编译通过不等于运行验证**，运行期语义的规则仍只有文档依据。

细则见 [CLAUDE.md](CLAUDE.md)。

## 工程现状（2026-09-04）

`harmony/HybridShell/` —— **已真编译通过，产出 HAP。**

### 拿到代码后第一件事：对齐平台配置

工程有两套互斥配置。**仓库提交的是 HarmonyOS 侧**（`devecocli create` 的原值），
DevEco Studio 打开即可用；只有 OpenHarmony SDK 的环境要先切过去：

```sh
bash harmony/switch-runtime.sh ohos     # 切 OpenHarmony（免登录编译链走这个）
bash harmony/switch-runtime.sh hos      # 切回 HarmonyOS（仓库默认）
```

配错了报的是 `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]`（HarmonyOS 侧）
或 `00303168 SDK component missing`（OpenHarmony 侧），两者互为镜像，**都不是代码问题**。

📌 **别人用这个基座踩过的坑（编译、装机、版本对不上）全部整理在
[harmony/HybridShell/README.md](harmony/HybridShell/README.md)** —— 15 条错误速查表 + 逐条详解，
拿到代码先读它。工具链细节见 [harmony/README.md](harmony/README.md)，
过程见 [2026-09-04 日志](research-log/2026-09-04-协作者环境两条错误.md)。

| 环节 | 状态 |
| --- | --- |
| `devecocli create` 生成官方模板工程（30 文件） | ✅ 已跑通 |
| 混合容器代码（三条通信路径 + 本地 H5，`Index.ets` 281 行） | ✅ 已写入 |
| `devecocli build` 出 HAP | ✅ **已通过**，`BUILD SUCCESSFUL in 3 s 399 ms`，110,930 B 未签名 HAP |
| ArkTS 类型检查 | ✅ 已过，并用反向实验确认编译器真在查类型 |
| 在 HarmonyOS SDK 上编译 | ❌ 未做，需人登录下载 CLT |
| 装设备、跑通 W1–W16 | ❌ 未开始，本机无 OpenHarmony 设备 |

⚠️ **关键限定：跑通编译的是免登录的 OpenHarmony API 23 链（`switch-runtime.sh ohos` 那一侧），
产物是 OpenHarmony HAP，不是 HarmonyOS HAP；入库的 HarmonyOS 侧配置本身未被编译器验过。**
所以准确说法是「已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行」。

两条关键发现：**`create` 不需要 SDK，`build` 需要**；**登录门禁只挡 HarmonyOS SDK 本体，
hvigor / ohpm / OpenHarmony SDK 全是公开直链**。详见 [harmony/README.md](harmony/README.md)、
[experiments/002](experiments/002-混合容器最小基座/README.md)。

**W1 已由编译器实测确认**：把 `postMessageEvent` 故意写成 `postMessage`，编译器报
`10505001 Property 'postMessage' does not exist on type 'WebMessagePort'`。

## 工具链现状（2026-09-03 实测）

全部装在 `~/.local/hmos-toolchain/`，自成一体，不改 `~/.zshrc`，`rm -rf` 即卸载。
用法：`source harmony/env.sh`。

| 组件 | 状态 |
| --- | --- |
| DevEco CLI 1.3.0-stable | ✅ `--version` / `create` / `build` 均实测通过 |
| JDK 21（Temurin 21.0.12.1+1 LTS） | ✅ 通过，sha256 已对官方值 |
| 官方工程模板 25 个文件 | ✅ 就在 CLI 包内 `templates/application/`，无需另下 |
| **OpenHarmony 编译链**（hvigor 6.26.1 + ohpm + Node 22 + SDK 23 五组件） | ✅ **已就位、编译成功**；全部免登录直链，逐件对过官方 sha256 |
| HarmonyOS Command Line Tools ≥ 26.0.0 | ❌ 仍缺，下载需华为账号 + 动态验证码，Agent 无法代办 |
| `code-linter` | ❌ OpenHarmony CLT 包内无实体，静态检查这条线仍是空的 |
| Node.js v24.6.0 / Python 3 / curl / jq | ✅ |

⚠️ 官方文档写的 `DEVECO_CLI_CLI_PATH` 实测**完全无效**，真正生效的是 `DEVECO_CLI_CLT_PATH` ——
对照实验见 [experiments/001](experiments/001-deveco-cli-无IDE可行性/README.md)。

要 HarmonyOS HAP 时人要做的一步见 [harmony/README.md](harmony/README.md)。


