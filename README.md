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
2. 代码片段默认标注**未编译验证**；只有真的过了 `devecocli build` 才能摘掉这个标注。

细则见 [CLAUDE.md](CLAUDE.md)。

## 工具链现状（2026-09-02 实测）

全部装在 `~/.local/hmos-toolchain/`，自成一体，不改 `~/.zshrc`，`rm -rf` 即卸载。
用法：`source harmony/env.sh`。

| 组件 | 状态 |
| --- | --- |
| DevEco CLI 1.3.0-stable | ✅ `--version` 通过，16 个命令齐全 |
| JDK 21（Temurin 21.0.12.1+1 LTS） | ✅ `java -version` 通过，sha256 已对官方值 |
| Command Line Tools ≥ 26.0.0 | ❌ **唯一卡点**，下载需华为账号 + 动态验证码，Agent 无法代办 |
| Node.js v24.6.0 / Python 3 / curl / jq | ✅ |

**不装 DevEco Studio 也能创建并编译工程**已验证是官方设计内路径，靠 `DEVECO_CLI_CLT_PATH` 指向 CLT。
⚠️ 官方文档写的 `DEVECO_CLI_CLI_PATH` 实测**完全无效** —— 对照实验见
[experiments/001](experiments/001-deveco-cli-无IDE可行性/README.md)。

人要做的一步见 [harmony/README.md](harmony/README.md)。

