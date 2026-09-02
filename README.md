# hmos — HarmonyOS × AI 构建实验场

用 AI Agent 构建鸿蒙原生应用，这条路到底能走到哪一步？本仓库是回答这个问题的调研与知识沉淀区。

- **不是**一个待交付的 App 工程
- **是**事实清单 + 方法论 + 踩坑记录，服务于「让 Agent 可靠地产出鸿蒙代码」
- 当前阶段：**纯调研**；重点方向：**端侧原生 AI 能力**

## 从哪里开始读

| 想知道 | 看这里 |
| --- | --- |
| 怎么机器可读地拿到官方文档（**先读这个**） | [docs/00-doc-retrieval.md](docs/00-doc-retrieval.md) |
| 鸿蒙现在什么版本、工具链怎么装、工程长什么样 | [docs/01-platform-landscape.md](docs/01-platform-landscape.md) |
| 端侧有哪些 AI 能力可用、怎么选 | [docs/02-ondevice-ai-map.md](docs/02-ondevice-ai-map.md) |
| 各 AI 能力的细节 | [docs/ai-kit/](docs/ai-kit/) |
| AI 写 ArkTS 时最容易写错什么 | [docs/03-arkts-codegen-rules.md](docs/03-arkts-codegen-rules.md) |
| 华为官方自己的 AI 编码工具（DevEco Code / CLI） | [docs/04-official-ai-coding-tools.md](docs/04-official-ai-coding-tools.md) |
| 术语对不上 | [docs/glossary.md](docs/glossary.md) |
| 这些结论是怎么来的 | [research-log/](research-log/) · [docs/sources.md](docs/sources.md) |

## 目录

```
docs/            结论型知识（现在相信什么）
  ai-kit/        逐个端侧 AI 能力的细节
  sources.md     资料索引：URL + 访问日期 + 可信度
research-log/    过程记录，只追加
experiments/     动手验证，一实验一目录
tools/           调研工具。hwdoc.py：抓官方文档目录与正文
harmony/         预留的 DevEco Studio 工程位
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
2. 本机暂无 DevEco Studio / hvigorw / ohpm，仓库内代码片段**一律未编译验证**，不得宣称已跑通。

细则见 [CLAUDE.md](CLAUDE.md)。

## 环境现状（2026-09-01 核实）

| 项 | 状态 |
| --- | --- |
| DevEco Studio | 未安装 |
| hvigorw / ohpm / hdc | 不可用 |
| Command Line Tools / JDK | 未安装 —— **这才是真正的卡点** |
| Node.js | v24.6.0 |
| Python 3 / curl / jq | 可用（`tools/hwdoc.py` 依赖） |

官方明确 Hvigor 可独立于 DevEco Studio 运行，所以「不装 IDE 也能编译」有可能成立，但未验证。
见 [experiments/001](experiments/001-deveco-cli-无IDE可行性/README.md) 与 [harmony/README.md](harmony/README.md)。

