# 官方 AI 编码工具：DevEco Code 与 DevEco CLI

最后更新：2026-09-01 ｜ 事实来源：华为官方文档（见文末来源表）｜ 本机未安装、未实测

## 结论摘要

- 华为已经有两个**独立于 DevEco Studio IDE 的、面向 AI 编码的命令行产品**，都在开发指南的 `AI Coding` 一级目录下：
  - **DevEco Code**：终端里的 AI Agent（不是 IDE、不是 IDE 插件），**基于华为 BitFun 技术与开源 OpenCode 构建**，`npm install -g @deveco/deveco-code`，入口命令 `deveco`。
  - **DevEco CLI**：**明确定位为「给各类 AI Agent 用的」HarmonyOS 工具集封装**，`npm install -g @deveco/deveco-cli`，入口命令 `devecocli`。官方原话点名了 Cursor、OpenCode 等通用工具。
- **DevEco CLI 是本项目最重要的发现**：它把工程创建、编译打包、签名、推包运行、日志、Code Linter 检查、SDK 兼容性扫描、模拟器管理、UI 自动化操作全部做成了子命令，并且提供 `devecocli serve mcp`（MCP server）与 `devecocli serve lsp`（LSP）两个协议入口，可被第三方 Agent 直接调用。`devecocli init --mcp` / `--skill` 能自动把自己注册进智能体配置。
- **平台**：DevEco CLI 支持 Windows / macOS / Linux（Linux 从 1.3.0 起）。DevEco Code 只支持 **Windows 11 22H2+ 与 macOS 15 Sequoia+**，官方未列 Linux。
- **两者都不能完全脱离 DevEco Studio**：DevEco CLI 的环境搭建要求「下载和安装 DevEco Studio 6.0.0 及以上版本」；只有 Linux 一节给出了替代方案——用 `DEVECO_CLI_CLI_PATH` 指向 `command-line-tools`。**macOS 上能否同样只装 Command Line Tools 而不装 IDE，官方文档没写 ⚠️ 待核实**。
- 都需要**华为账号登录**。DevEco Code 启动即要求登录；DevEco CLI 是「部分功能需要授权」。**文档中没有出现白名单 / 邀测 / 申请资格的字样**。
- 原来的 IDE 内 AI 插件 **DevEco CodeGenie** 已被官方目录整节标注为「使用AI智能辅助编程（**不推荐**）」，取代者就是 DevEco Code。
- 版本很新，都还是 0.x / 1.x：DevEco Code 0.1.1（2026-07 首发）→ 0.2.0（2026-08）；DevEco CLI 1.2.0（2026-07 首发）→ 1.3.0（2026-08）。**功能与命令面仍在快速变动，本页事实只对 2026-09-01 当天线上文档负责。**

## DevEco Code

| 维度 | 情况 | 来源 slug |
| --- | --- | --- |
| 形态 | 「面向 HarmonyOS 应用开发的 AI Agent 工具」。终端交互，**不是 IDE，也不是 DevEco Studio 插件** | `ide-deveco-code-overview` |
| 技术底座 | 「基于华为 BitFun 技术与开源 OpenCode 构建」，保留 OpenCode 的终端交互与 Model/Provider/MCP/Skill 配置能力；配置文件 `deveco.jsonc` 的 `$schema` 直接指向 `https://opencode.ai/config.json` | `ide-deveco-code-overview`、`ide-deveco-code-model` |
| 集成内容 | HarmonyOS 精品 Skills + DevEco Studio 开发工具链 + HarmonyOS 知识库 | `ide-deveco-code-overview` |
| 能力 | 代码编写、编译构建、运行调试、ArkTS 问题修复、文档查阅 | `ide-deveco-code-overview` |
| Agent 模式 | 三种：**Build**（直接执行：需求理解→代码生成→修复→构建出包→推送模拟器）、**Plan + Build**（先交互规划任务列表再执行）、**Goal**（需求分析/架构设计/任务拆分→结构化文档→全自动迭代到验收）。对话框输入 `/agents` 查看，Tab 切换 | `ide-deveco-code-agent` |
| 约束 | 三种模式都写明「推包验证需配置模拟器」 | `ide-deveco-code-agent` |
| 获取方式 | npm 全局安装：`npm install -g @deveco/deveco-code@stable`（稳定版）/ `npm install -g @deveco/deveco-code`（尝鲜版）。可加 `--registry`，官方推荐 npm 官方源或淘宝源 | `ide-deveco-code-install` |
| 运行平台 | Windows 11 22H2 及以上（终端 Shell 需 PowerShell 5.1+，推荐 7+）；**macOS 15 Sequoia 及以上，Intel 或 M 系列芯片，推荐 M 系列，终端 Shell 为 Zsh**。未提及 Linux | `ide-deveco-code-install` |
| 依赖 | Node.js 推荐 22+；**（可选）DevEco Studio 6.1.0 及以上**——「不安装会影响 HarmonyOS 工程的编译构建、推包等」；（可选）`DEVECO_HOME` 指向 IDE 安装目录（macOS 默认 `/Applications/DevEco-Studio.app`） | `ide-deveco-code-install` |
| 磁盘 | 8GB+；需编译构建与模拟器/真机调试时 20GB+。RAM 8GB+/16GB+ 分场景 | `ide-deveco-code-install` |
| 账号 | 启动 `deveco`，「若未登录按照指引先登录华为账号」；`deveco auth logout` 退出。**未见白名单/邀测要求** | `ide-deveco-code-install` |
| 模型 | 内置 **GLM-5.1**，单账号默认**每分钟 50 次请求**，登录即用。`/models` 切换、`/connect` 接第三方 Provider（如 ZhipuAI、Alibaba）。UI 检查用多模态模型：已登录默认内置 **Qwen3-VL**，未登录跳过 UI 检查；第三方多模态**仅支持 Qwen 系列** | `ide-deveco-code-model` |
| 配置 | `deveco.jsonc`，项目级 `.deveco/deveco.jsonc` > 用户级 `~/.config/deveco/deveco.jsonc`（macOS）。支持绿灯模式 `"permission": "allow"`（默认关闭）、MCP、Skill 权限、按 Agent 覆盖权限 | `ide-deveco-code-common-configure` |
| 内置 Skill | `deveco-create-project`（创建标准化 HarmonyOS 模板工程）、`arkts-grammar-standards`、`arkts-error-fixes`、`arkts-runtime-fix` | `ide-deveco-code-common-configure` |
| 自定义 Skill | 固定文件名 `SKILL.md` + YAML frontmatter（`name` 必填 ≤64 字符、`description` 必填 ≤1024 字符，`license`/`compatibility`/`metadata` 可选）；正文 ≤32768 字符；目录 ≤100MB。扫描路径含 `.deveco/skills/<name>/SKILL.md` 与**兼容路径 `.agents/skills/<name>/SKILL.md`** | `ide-deveco-code-common-configure` |
| 命令（斜杠） | 文档「命令」页目前只收录了 `/collect`（0.2.0 起，异常时上传日志），另提到 `/privacy`、`/agents`、`/models`、`/connect`、`/skills` | `ide-deveco-code-options`、`ide-deveco-code-agent`、`ide-deveco-code-model` |
| 版本 | 0.1.1（2026 年 7 月）首次发布；0.2.0（2026 年 8 月）新增「集成 DevEco CLI 工具原子化能力」、日志回传，优化 Goal 模式 | `ide-deveco-code-releasenote` |

要点：**DevEco Code 0.2.0 的新增特性明确写着「集成 DevEco CLI 工具原子化能力」**——即 DevEco Code ≈ OpenCode 内核 + HarmonyOS Skills/知识库 + DevEco CLI 原子能力。这说明 DevEco CLI 是底座，DevEco Code 是华为自带模型与 Skill 的一个上层壳。对本项目而言，**通用 Agent 走 DevEco CLI 能拿到同一批底层能力**。

## DevEco CLI

### 定位（官方原话要点）

- 「业界 AI Agent 在处理 HarmonyOS 应用开发任务时，往往面临**领域知识不足、缺少可被 AI 调用开发工具**等挑战。为解决这一问题，DevEco CLI 应运而生。」
- 「DevEco CLI 是一款**面向各类 AI Agent 使用的 AI 产品**，将 HarmonyOS 工具集、HarmonyOS 知识库和精品 Skills 封装为**适配 AI 调用的命令行接口**，全面开放给各类通用 AI 开发工具（**如 Cursor、OpenCode 等**），使这些工具具备 HarmonyOS 应用开发能力。」

来源 `ide-deveco-cli-overview`。这一段是本项目路线的官方背书：华为承认通用 Agent 是它要服务的对象。

### 环境与获取

| 维度 | 情况 | 来源 slug |
| --- | --- | --- |
| 运行平台 | **Windows、macOS 和 Linux**；「从 1.3.0 版本开始支持在 Linux 上运行」 | `ide-deveco-cli-install` |
| 环境搭建 | ①「下载和安装 **DevEco Studio 6.0.0 及以上版本**」；② Node.js 推荐 22+ | `ide-deveco-cli-install` |
| Linux 特例 | 「在 Linux 环境运行时，需要手动配置环境变量来指定工具链路径」：`export DEVECO_CLI_CLI_PATH=/opt/command-line-tools` | `ide-deveco-cli-install` |
| 安装 | `npm install -g @deveco/deveco-cli@stable`（稳定版）/ `npm install -g @deveco/deveco-cli`（尝鲜版） | `ide-deveco-cli-install` |
| 版本/更新 | `devecocli --version`、`devecocli update` | `ide-deveco-cli-install` |
| 账号 | 「部分功能需要授权后才可正常使用」，`devecocli auth login`（1.3.0 起）。**具体哪些命令强制登录，文档未逐条列出 ⚠️ 待核实**；`signature generate` 默认取「主账号用户 ID（userID）」，实际需要登录态 | `ide-deveco-cli-options` |
| serve mcp 额外要求 | **DevEco Studio 26.0.0 Release 及以上 + DevEco CLI 1.3.0 及以上** | `ide-deveco-cli-options` |
| 版本 | 1.2.0（2026 年 7 月）首次发布；1.3.0（2026 年 8 月）新增签名自动配置、增量推包与热重载、Code Linter 检查、目标 SDK 兼容性检查、模拟器场景模拟、界面布局/窗口列表查看、UI 测试、MCP 协议调用语法检查工具、LSP 协议、Linux 支持 | `ide-deveco-cli-releasenote` |

### 能力表

| 能力 | 能不能做 | 关键命令 | 备注 |
| --- | --- | --- | --- |
| 创建工程 | 能，但**仅 Empty Ability 模板** | `devecocli create` | 「仅支持创建工程模板中的 Empty Ability 模板」。`--api-level` 最小 17，最大值**从已安装的 DevEco Studio 的 HarmonyOS SDK 中自动获取** |
| 编译打包 | 能 | `devecocli build` / `devecocli build clean` | 指定 `--product` 产物为 `.app`；指定 `--modules` 产物为 `.hap`/`.hsp`/`.har`。依赖自动解析构建 |
| 调试签名 | 能（1.3.0 起） | `devecocli signature generate` | 自动生成签名材料并写入工程级 `build-profile.json5` |
| 安装并运行 | 能（真机或模拟器） | `devecocli run` | 支持 `--skip-build`、`--uninstall`、`--apply`（增量 `.hqf`，需 DevEco Studio 6.1.1 以上）、`--hotreload`、`--hotreload-apply` |
| 日志 | 能 | `devecocli log` | hilog 普通日志与 `--crash` 崩溃日志，支持 `--follow`、`--tail`、`--from/--to` 时间偏移 |
| 代码检查 | 能（1.3.0 起） | `devecocli check lint` | 按 Code Linter 规则检查，`--fix` 自动修复，`--incremental` 只查 Git 增量文件，`--format json` |
| SDK 兼容性 | 能（1.3.0 起） | `devecocli check compat` / `check compat versions` | 仅支持 `.ets`、`.c`、`.cpp`；`--source-version`/`--target-version` 必选，形如 `HarmonyOS_26.0.0(26)_Beta2` |
| 查官方文档 | 能 | `devecocli docs search` / `docs read` / `docs catalog` | catalog 取值 `harmonyos-releases`、`harmonyos-guides`、`harmonyos-references`、`best-practices`、`harmonyos-faqs`、`harmonyos-roadmap`、`all` |
| 模拟器全生命周期 | 能 | `emulator` 系列 | 创建/启动/停止/删除、镜像下载删除、许可协议查看与接受；`emulator start` 与 `emulator image download` **仅支持 release 版本** |
| 设备查询 | 能 | `devecocli device list` / `device view` | 含真机与运行中的模拟器 |
| UI 自动化 | 能（1.3.0 起） | `ui` 系列 | 布局字符树、窗口列表、截图、点击/双击/长按、swipe/fling/dircfling/drag、文本输入 |
| Skill 管理 | 能 | `skills list/find/add/remove` | 把 HarmonyOS 精品 Skill 装进第三方智能体 |
| 对外协议 | 能 | `devecocli serve mcp` / `devecocli serve lsp` | 见下节 |
| **跑单元测试** | **文档中未见对应命令** | — | `ide-deveco-cli-options` 的命令清单里没有 `test` 类命令。测试相关另有独立产品 DevEco Testing（`command-testing`），**是否可用于本地单测未核实 ⚠️** |
| 依赖安装（ohpm） | **文档中未见对应命令** | — | 未在 DevEco CLI 命令清单中出现；依赖管理仍走 `ohpm`（Command Line Tools 内） |

### 命令清单（逐字抄自官方「命令」页锚点，2026-09-01）

```
devecocli help
devecocli init --agent <agents> --project <path> --path <path> --skill --mcp --force
devecocli auth login | auth status | auth team list --json | auth logout
devecocli docs search <keywords...> --catalog <name> --format <fmt> --limit <n>
devecocli docs read <documentId>
devecocli docs catalog --format <fmt>
devecocli create --app-name <name> --project-path <path> --bundle-name <bundle> --api-level <level>
devecocli build --product <product> --modules <modules> --build-mode <mode>
devecocli build clean
devecocli signature generate --product <product> --team-id <team-id> --force --help
devecocli run --module <module> --device <device> --product <product> --build-mode <mode> --ability <ability> --uninstall --skip-build --apply <fileName> --hotreload --hotreload-apply
devecocli log --device <device> --crash --level <level> --bundle-name <bundle-name> --keyword <keyword> --tail <num> --from <start> --to <end> --follow
devecocli check lint [path] --fix --incremental --config-path <path> --product <product> --format <format> --output-path <path> --limit <number>
devecocli check compat [files] --source-version <version> --target-version <version> --modules <modules...> --format <format> --output-path <path> --limit <number>
devecocli check compat versions --format <format>
devecocli emulator list | start [names...] | stop [names...] | create <name> | delete <name>
devecocli emulator image list | image download | image remove
devecocli emulator license view | license accept
devecocli emulator shake | power | rotate <direction> | volume <direction> | fold <state> | battery | geolocation | scene <type> | sensor
devecocli device list
devecocli device view --target <serialOrName>
devecocli skills list --long | skills find <keyword> | skills add | skills remove
devecocli ui layout | ui window list | ui screenshot | ui click | ui doubleclick | ui longclick
devecocli ui swipe | ui fling | ui dircfling <direction> | ui drag | ui text [text]
devecocli serve mcp
devecocli serve lsp --arkts --cpp --project-path <path> --auto-detect
```

上面为压缩排版；每条命令的完整参数表见 `ide-deveco-cli-options`。**以上命令名与参数名逐字抄自官方文档，本机未执行验证。**

## 与第三方 Agent 的关系

**有官方 MCP server，有官方 LSP，有官方 Skill 分发机制。这是本页最关键的结论。**

### 1）MCP：`devecocli serve mcp`

「启动本地 MCP 服务。智能体配置 MCP 服务后，可通过 MCP 协议调用 ArkTS/C++ 语法检查工具。」推荐用 `devecocli init --mcp` 自动配置。官方给的配置片段（来源 `ide-deveco-cli-options`）：

```jsonc
{
  "mcp": {
    "deveco-mcp": {
      "type": "local",
      "command": ["devecocli", "serve", "mcp"],
      "environment": {
        "PROJECT_PATH": "D:\\code\\sample_in_harmonyos",   // 工程路径
        "NODE_MAX_OLD_SPACE_SIZE": "8192",                  // 可选，默认 8192
        "DEVECO_PATH": "D:\\Applications\\DevEco Studio"    // 可选，DevEco Studio 安装路径
      },
      "enabled": true
    }
  }
}
```

暴露的 MCP 工具（均支持 ArkTS 与 C/C++）：

| 工具名 | 用途 |
| --- | --- |
| `check` | 静态语法分析，返回结构化诊断信息 |
| `hover` | 指定位置的悬浮信息（类型、文档） |
| `definition` | 查找符号定义位置 |
| `declaration` | 查找符号声明位置（ArkTS 中可能与定义不同） |
| `references` | 查找符号在全工程中的所有引用 |
| `implementation` | 查找符号的实现 |
| `workspaceSymbol` | 按名称在全工程搜索符号 |
| `documentSymbol` | 单文件符号树 |
| `callHierarchy` | 函数调用关系（C/C++ 仅支持调用方） |

支持扩展名：ArkTS `.ets`；C/C++ `.c .cc .cpp .cxx .c++ .h .hh .hpp .hxx .h++ .ipp .ixx .inl .inc .tpp`。
环境要求：DevEco Studio 26.0.0 Release 及以上 + DevEco CLI 1.3.0 及以上。文档提示可能出现 `please retry in N seconds` 限流。

**注意范围**：这个 MCP server 目前**只暴露语言智能类工具**（语法检查、跳转、引用），**不包含 create / build / run**。构建与运行仍要 Agent 自己去执行 `devecocli` 子命令（即当普通 shell 命令用）。

### 2）LSP：`devecocli serve lsp --arkts` / `--cpp`

「智能体配置 LSP 服务后，可通过 LSP 协议实现代码检查、代码引用查找、代码跳转、代码补全等代码编辑相关的能力。」1.3.0 起支持，当前支持 ArkTS 与 clangd 两个 server，`--arkts` 与 `--cpp` 互斥。

### 3）Skill / 注册机制：`devecocli init`

- `devecocli init --skill`：把 **deveco-cli Skill** 装到智能体里；`--agent <agents>` 指定智能体名（逗号分隔），**缺省时「配置到所有已检测到的智能体中」**。
- `devecocli init --mcp`：配置 MCP 服务，与 `--project` 一起用为工程级、单独用为用户级。
- `devecocli skills list/find/add/remove`：查询并把 HarmonyOS 精品 Skill 装进智能体。
- DevEco Code 侧的 Skill 扫描路径包含 `.agents/skills/<name>/SKILL.md`（官方称「项目 Agent 兼容」/「用户 Agent 兼容」），说明华为在向通用 Agent 的 Skill 目录约定靠拢。

⚠️ **官方文档没有列出 `--agent` 支持哪些智能体的具体名单**（正文只举例 `agentname` 占位符，概述里点名 Cursor、OpenCode）。Claude Code / Ducc 是否在自动检测列表内 —— **未确认**。

### 通用 Agent 能借到的官方能力（汇总）

| 借什么 | 通道 | 是否需要 DevEco Studio |
| --- | --- | --- |
| ArkTS/C++ 语法诊断、符号跳转、引用、调用链 | `serve mcp` 或 `serve lsp` | 需要（serve mcp 明确要 26.0.0 Release+） |
| 官方文档全文检索与读取 | `docs search` / `docs read` | 未明确要求，⚠️ 待核实 |
| 工程创建、编译、签名、推包、日志、Lint、兼容性扫描 | 直接执行 `devecocli` 子命令 | 需要（`--api-level` 上限取自 IDE 内 SDK；Linux 可用 `DEVECO_CLI_CLI_PATH` 指向 command-line-tools 替代） |
| HarmonyOS 精品 Skills（提示词层面的领域知识） | `devecocli init --skill` / `skills add` | ⚠️ 待核实 |

## 「使用AI智能辅助编程（不推荐）」是怎么回事

先说事实边界：**「（不推荐）」这四个字出现在开发指南的目录节点标题上，而不是某篇正文里**。该节点自身没有对应文档页（`getCatalogTree` 返回的 `relateDocument` 为空），所以官方没有给出一份「弃用公告」正文。

已确认的事实：

| 项 | 内容 | 来源 |
| --- | --- | --- |
| 目录节点名 | `使用AI智能辅助编程（不推荐）`，与 `AI Coding` 节点**平级并列**，排在其后 | `harmonyos-guides` 目录树（`getCatalogTree`，2026-09-01 取） |
| 指的是什么产品 | **DevEco CodeGenie**——「DevEco Studio 的 AI 辅助编程工具」，即 IDE 右侧边栏插件 | `ide-codegenie` |
| CodeGenie 的能力 | 智能问答、代码生成、页面生成、万能卡片生成、单元测试用例生成、代码智能解读、编译报错智能分析、智慧调优、应用 UI 生成、意图装饰器生成、小艺智能体创建、自定义 Agent | `ide-codegenie` |
| 被什么取代 | **DevEco Code**。官方原话：「在 DevEco Studio 右侧边栏点击 CodeGenie，26.0.0 Beta1 之前版本，可直接进入 CodeGenie 问答界面；**从 26.0.0 Beta1 版本开始**，进入 CodeGenie 后……点击 **View Installation Guide 可查看 DevEco Code 的具体操作指导**，点击 Continue with CodeGenie 可进入 CodeGenie 问答界面。」 | `ide-codegenie` |
| 是否已下线 | **没有**。文档仍在维护（版本说明最新条目 26.0.0.621），插件仍可从下载中心获取并手动安装，快捷键 Alt/Option+U 仍可用 | `ide-codegenie`、`ide-codegenie-releasenote` |

合理推断（**推断，非官方表述**）：华为在 2026 年 7 月同时发布 DevEco Code 0.1.1 与 DevEco CLI 1.2.0，把 AI 编码从「IDE 插件」重构为「终端 Agent + 可被任意 Agent 调用的 CLI」，因此把旧的 IDE 插件整节降级为「不推荐」，并在 DevEco Studio 26.0.0 Beta1 起于 CodeGenie 入口处引导用户迁移到 DevEco Code。

对本项目的影响：**CodeGenie 的文档不要再作为学习/参考的主线**。但它下面有几篇内容对理解华为的 Agent 设计仍有参考价值，尤其 `ide-agent-mcp`（CodeGenie 的 MCP 配置，支持 Stdio / SSE / Streamable HTTP 三种通信方式，并有 MCP Market）、`ide-skills`、`ide-agent-rules`、`ide-memory`、`ide-commands`、`ide-insight-intent2`（意图装饰器生成与小艺智能体创建，与本项目端侧 AI 主题相关）。

## 对本项目的意义

### 结论

1. **「无工具链」的限制有官方解法，而且不止一条。**
   - 路线 A（官方推荐给 Agent 的路）：装 **Command Line Tools**（内嵌 HarmonyOS SDK，含 `hvigorw`、`ohpm`、`codelinter`，**明确支持 macOS/Linux/Windows**）+ **DevEco CLI**。DevEco CLI 提供工程创建（`create`）与编译（`build`）等原子命令。
   - 路线 B（纯传统 CI 路）：只用 Command Line Tools + `hvigorw assembleHap`。官方「搭建流水线」页写明「通过命令行方式构建应用或元服务，可在 Windows、Linux 和 macOS 下调用相应命令来执行」，且「HarmonyOS SDK 已嵌入命令行工具中，无需额外下载配置」。**代价是没有工程脚手架**——`hvigorw` 只构建不创建工程。
   - 结论：**创建工程 → 只有 `devecocli create`（Empty Ability 模板）或 DevEco Studio；编译 → `devecocli build` 或 `hvigorw`。**
2. **但「完全不装 DevEco Studio」在 macOS 上尚未被文档确认。** DevEco CLI 的环境搭建一节要求装 DevEco Studio 6.0.0+；只有 Linux 一节提供了 `DEVECO_CLI_CLI_PATH=/opt/command-line-tools` 这个替代路径。这是**当前最值得优先核实的一个点**。
3. **DevEco CLI 的定位与本仓库的假设高度吻合**：华为自己认定「通用 AI Agent 缺 HarmonyOS 领域知识和可被 AI 调用的工具」，并把工具面开放出来。本项目「用通用 Agent 构建鸿蒙应用」不是逆势操作，而是官方明确支持的场景。
4. **DevEco Code 与 Ducc/Claude Code 是同层竞品，不是上下层。** 两者都是终端 Agent；差别在 DevEco Code 自带 GLM-5.1、HarmonyOS 精品 Skills 与知识库。**可借用的是它的 Skill 内容与 DevEco CLI 底座，不必替换现有 Agent。**
5. **官方 Skill 是可直接抄的知识资产**：`arkts-grammar-standards`、`arkts-error-fixes`、`arkts-runtime-fix` 三个内置 Skill 与本仓库 `docs/03-arkts-codegen-rules.md` 的目标完全重叠。若能取到其 `SKILL.md` 正文，就是一份华为官方版的「AI 容易写错的点」清单。

### 下一步验证路径（**以下全部未实测，本机未安装任何工具**）

按成本从低到高：

| # | 验证目标 | 做法 | 预期判据 |
| --- | --- | --- | --- |
| 1 | DevEco CLI 包是否公开可取、真实版本号 | 只查 npm registry 元数据（`https://registry.npmjs.org/@deveco/deveco-cli`），**不安装** | 能拿到 `dist-tags.latest` / `stable` 与 `os`/`cpu` 字段，可反推平台支持 |
| 2 | 同上，DevEco Code | 查 `@deveco/deveco-code` 元数据 | 同上；`bin` 字段应为 `deveco` |
| 3 | macOS 上不装 DevEco Studio 能否工作 | 装 Command Line Tools + DevEco CLI，尝试 `DEVECO_CLI_CLI_PATH` 指向解压目录，跑 `devecocli create` → `devecocli build` | `build` 成功产出 `.hap` 即证明可绕过 IDE。**这是决定本仓库能否进入「可编译」阶段的关键实验** |
| 4 | 哪些命令必须登录 | `devecocli docs search` / `create` / `build` 在未登录态下逐个试 | 报未授权即为需要登录 |
| 5 | 官方 Skill 正文内容 | 装 CLI 后 `devecocli skills list --long`、`devecocli init --skill --path <目录>`，读取落盘的 `SKILL.md` | 拿到 `arkts-*` 三个 Skill 正文，用于校对 `docs/03-arkts-codegen-rules.md` |
| 6 | MCP server 能否被本 Agent 用 | `devecocli serve mcp` + 在 Agent 侧配置 MCP | `check` 工具能返回结构化诊断。注意它要 DevEco Studio 26.0.0 Release+，可能与 #3 的「不装 IDE」目标冲突 |

**#3 与 #6 存在张力**：不装 IDE 也许能编译，但 `serve mcp` 的环境要求点名 DevEco Studio 26.0.0 Release+。需要实测才能判断这是硬依赖还是文档笼统写法。

建议在 `experiments/` 下新建目录承载 #1/#2（纯查询，无安装），把 #3 作为独立实验并在动手前先写假设——按 CLAUDE.md 的流程，安装动作应经人工确认。

## 未确认 / 待核实

- ⚠️ **macOS 上能否只装 Command Line Tools（不装 DevEco Studio）驱动 DevEco CLI**。官方只在 Linux 一节给了 `DEVECO_CLI_CLI_PATH`，macOS/Windows 一节要求装 DevEco Studio 6.0.0+。
- ⚠️ **`DEVECO_CLI_CLI_PATH` 这个变量名在 macOS/Windows 是否同样生效**，文档只在 Linux 语境出现（注意变量名中 `CLI` 重复，已逐字照抄）。
- ⚠️ **DevEco CLI 哪些命令强制华为账号登录**。只说「部分功能需要授权」，无清单。
- ⚠️ **`devecocli init --agent` 能自动检测哪些智能体**，是否包含 Claude Code / Ducc。文档只给 `agentname` 占位符。
- ⚠️ **DevEco CLI 是否有单元测试相关命令**。命令清单中未见；DevEco Testing（`command-testing`）是另一个产品，能否本地跑单测未核实。
- ⚠️ **DevEco CLI 是否能安装工程依赖**（`ohpm install` 的等价物）。命令清单中未见。
- ⚠️ **DevEco Code 是否支持 Linux**。文档只列 Windows/macOS，未见「不支持 Linux」的明示。
- ⚠️ **DevEco Code / DevEco CLI 是否需要白名单或申请资格**。文档中未出现相关字样，但也未明示「所有开发者可用」。
- ⚠️ **内置模型 GLM-5.1 的「每分钟 50 次」之外是否有总量限制、是否收费**，文档未说。
- ⚠️ **DevEco Studio 版本号体系**：文档中同时出现 `6.0.0`/`6.1.0`/`6.1.1` 与 `26.0.0`，两套编号的先后关系与对应的 HarmonyOS 版本未核实（`26.0.0` 疑为年份制新编号）。
- ⚠️ **CodeGenie 是否有正式的停止维护时间点**。目录标「不推荐」，但版本说明仍在更新，无 EOL 公告。
- ⚠️ **DevEco Code 的斜杠命令全集**。「命令」页只收录 `/collect`，其余（`/agents`、`/models`、`/connect`、`/skills`、`/privacy`）散见于其他页，可能不完整。
- ⚠️ 多处官方页面的关键步骤以**截图**呈现（DevEco CLI「首次使用」、DevEco Code Agent 模式的「实现流程」与「示例」），JSON 接口只能取到文字，**图内信息本页缺失**。

## 来源

全部通过 `tools/hwdoc.py` 取自 `developer.huawei.com` 文档中心 `harmonyos-guides` 目录，访问日期均为 **2026-09-01**。URL 规则：`https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/<slug>`。

| 文档标题 | slug | version | updatedDate / displayUpdateTime |
| --- | --- | --- | --- |
| DevEco Code（目录页） | `ide-deveco-code` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco Code 版本说明 | `ide-deveco-code-releasenote` | V1 | 2026-08-28 / 2026-08-29 |
| DevEco Code 工具概述 | `ide-deveco-code-overview` | V6 | 2026-08-28 / 2026-07-21 |
| DevEco Code 下载与安装 | `ide-deveco-code-install` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco Code Agent模式 | `ide-deveco-code-agent` | V6 | 2026-08-28 / 2026-07-28 |
| DevEco Code 模型配置 | `ide-deveco-code-model` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco Code 常用配置 | `ide-deveco-code-common-configure` | V6 | 2026-08-28 / 2026-07-21 |
| DevEco Code 命令 | `ide-deveco-code-options` | V1 | 2026-08-28 / 2026-08-29 |
| DevEco CLI 版本说明 | `ide-deveco-cli-releasenote` | V1 | 2026-08-28 / 2026-08-29 |
| DevEco CLI 工具概述 | `ide-deveco-cli-overview` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco CLI 快速入门 | `ide-deveco-cli-install` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco CLI 常用开发任务 | `ide-deveco-cli-developtask` | V1 | 2026-08-28 / 2026-08-29 |
| DevEco CLI 命令 | `ide-deveco-cli-options` | V6 | 2026-08-28 / 2026-08-29 |
| DevEco CodeGenie 工具概述 | `ide-codegenie` | V110 | 2026-08-28 / 2026-08-29 |
| DevEco CodeGenie 版本说明 | `ide-codegenie-releasenote` | V93 | 2026-08-28 / 2026-08-29 |
| 模型上下文协议（MCP）配置（CodeGenie） | `ide-agent-mcp` | V55 | 2026-08-28 / 2026-08-29 |
| 获取 Command Line Tools | `ide-commandline-get` | V110 | 2026-08-28 / 2026-07-28 |
| 命令行构建工具（hvigorw） | `ide-hvigor-commandline` | V113 | 2026-08-28 / 2026-08-29 |
| 搭建流水线 | `ide-command-line-building-app` | V114 | 2026-08-28 / 2026-08-29 |
| 开发指南目录树（`AI Coding` 与「使用AI智能辅助编程（不推荐）」节点名的唯一来源） | `getCatalogTree` / `harmonyos-guides` | — | 2026-09-01 线上快照 |



