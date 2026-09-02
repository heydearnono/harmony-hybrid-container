# 实验：DevEco CLI 能否脱离 DevEco Studio 完成工程创建与编译

- 日期：2026-09-01
- 状态：设计中（未执行；涉及安装动作，需人工确认后再做）
- 相关文档：`docs/04-official-ai-coding-tools.md`、`docs/01-platform-landscape.md`

## 假设

**在 macOS 上只安装 Command Line Tools + JDK + `@deveco/deveco-cli`（不安装 DevEco Studio），可以创建一个 Empty Ability 工程并编译出 HAP。**

可证伪点很明确：只要 `devecocli create` 或 `devecocli build` 在缺少 DevEco Studio 时报错退出，假设即不成立。

## 为什么关心

这是本仓库当前最大的结构性限制。若假设成立：

- 本项目从「纯调研」升级为「可验证」——ArkTS 代码片段能真正编译，`docs/03-arkts-codegen-rules.md` 的每条规则可以从「官方文档依据」升级为「编译器验证」。
- 通用 Agent（含 Ducc）具备了在 macOS 上做鸿蒙开发的完整闭环基础，`harmony/` 工程位可以落地。

若不成立，则需要退回到「装 DevEco Studio」或「Linux 环境」两条路，成本量级完全不同。

## 已知事实（来自官方文档，2026-09-01）

支持假设的：

- DevEco CLI 官方定位就是给各类 AI Agent 用，明确支持 Windows / macOS / Linux，`npm install -g @deveco/deveco-cli`，命令 `devecocli`。
- 官方明确 Hvigor「可独立于 DevEco Studio 运行」，且命令行构建在 macOS 与 Linux 上无差异。
- Command Line Tools 已内嵌 SDK，官方提供 macOS 下载。
- Linux 一节给出了不依赖 IDE 的替代路径：`export DEVECO_CLI_CLI_PATH=/opt/command-line-tools`。

不支持假设的：

- DevEco CLI 的环境搭建章节要求安装 DevEco Studio 6.0.0+。
- `DEVECO_CLI_CLI_PATH` 只在 Linux 一节出现，macOS 是否生效**官方未写**（变量名中 `CLI` 重复，已逐字核对）。
- `devecocli serve mcp` 要求 DevEco Studio 26.0.0 Release+，与「不装 IDE」目标直接冲突（但 MCP 不是本实验的验证目标）。

## 方法

分步做，每步都能独立给出结论，前一步失败就不用做后一步。

| 步 | 动作 | 是否需要安装 | 怎么算成功 |
| --- | --- | --- | --- |
| 0 | 查 npm registry 元信息：`npm view @deveco/deveco-cli` 看版本、`engines`、`os` 字段与包大小 | 否 | 拿到 macOS 是否在 `os` 白名单内的证据 |
| 1 | 全局安装 `@deveco/deveco-cli@stable`，跑 `devecocli --version` / `--help` | 是 | 命令可执行，帮助里能看到 `create` / `build` |
| 2 | 不装任何 SDK，直接 `devecocli create`，记录报错原文 | 否 | 报错文本明确指出缺什么（IDE？SDK？JDK？）——这一步的价值就是拿到准确的依赖诊断 |
| 3 | 装 JDK 21 与 Command Line Tools（官方下载页），设置 `DEVECO_CLI_CLI_PATH` 指向其目录，重试步 2 | 是 | `create` 成功生成 Empty Ability 工程 |
| 4 | 在生成的工程里 `devecocli build`（或直接 `hvigorw assembleHap`） | 否 | 产物里出现 `.hap` 文件 |
| 5 | 若步 3/4 失败，改测纯 `hvigorw` 路线：手写最小工程结构后 `hvigorw assembleHap` | 否 | 区分「CLI 依赖 IDE」与「整条命令行构建链依赖 IDE」两种失败原因 |

安装动作（步 1、3）会改动本机全局环境，执行前需用户确认。所有下载只用官方来源：
`https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos`。

## 过程

### 步 0 已执行（2026-09-01，仅读 npm registry 元信息，无安装）

```
npm view @deveco/deveco-cli
npm view @deveco/deveco-cli os engines cpu repository homepage bugs author
```

| 项 | 值 | 对假设的意义 |
| --- | --- | --- |
| latest / stable | `1.3.1`（2026-08-29 发布）／`dist-tags.stable = 1.3.0-stable` | `@stable` 落在 1.3.0-stable，比 latest 旧 |
| `os` 字段 | **不存在** | npm 层面**不排除 macOS**，装不上不会是平台白名单造成的 |
| `engines` | `{ node: '>=22' }` | 本机 Node v24.6.0 ✅ 满足 |
| `cpu` | 不存在 | 不限架构 |
| 包体积 | unpackedSize 56.6 MB，25 个依赖 | 内含 `@modelcontextprotocol/sdk`（对应 `serve mcp`）、`jieba-wasm`、`sqlite-wasm`、`regedit` |
| 版本历史 | 8 个版本，首发 `1.0.0` 于 **2026-06-12** | 与 HarmonyOS 7 Developer Beta 时间点吻合，是个很新的包 |
| license | MIT | — |

**步 0 结论：假设未被否掉。** macOS 未被排除，Node 版本满足，可以进入步 1。

⚠️ 顺带发现的一个问题，与假设无关但影响执行决策：该包**没有 `repository`、`homepage`、`bugs`、`author` 任一字段**，
npm maintainers 是三个个人邮箱账号（qq.com / hotmail.com / gmail.com），无华为组织标识。
官方文档确实点名 `npm install -g @deveco/deveco-cli`，所以包名来源是可信的（A 类），
但「npm 上这个包由华为发布」这一点**无法从 npm 元信息本身验证**。全局安装前建议先解包只读检查，
或改用非全局安装（见下）。

### 对方法的一处修订：步 1 改用非全局安装

原设计的 `npm install -g` 会改动本机全局环境。等效但可回滚的做法：

```bash
mkdir -p ~/tmp/deveco-probe && cd ~/tmp/deveco-probe
npm install @deveco/deveco-cli@stable        # 只落在这个目录
./node_modules/.bin/devecocli --version
```

失败后 `rm -rf ~/tmp/deveco-probe` 即完全复原。若 CLI 自身要求全局安装才能工作，
那本身就是一条值得记录的结论。

### 步 0.5 已执行（2026-09-02，只下载 tarball 解包读文件，**未安装、未执行**）

`postinstall` 存在意味着安装即执行代码，所以先不装，改用 `npm pack` 拿到包体离线审读：

```bash
npm pack @deveco/deveco-cli@stable    # 47 MB tgz，不安装不执行
tar -xzf deveco-deveco-cli-1.3.0-stable.tgz
```

**发现一：provenance 有了包内证据。** `scripts/postinstall.mjs` 头部为
`Copyright (c) 2026 Huawei Device Co., Ltd. / SPDX-License-Identifier: MIT`。
其行为是 detached 后台起 `dist/internal/doc-init-background.js`（配合包内 `docs.zip`/`index.zip` 与
`jieba-wasm`/`sqlite-wasm` 依赖，判断为构建本地文档检索索引），不写全局路径、不联网下载可执行文件。
步 0 提出的 npm 元信息缺失问题，至此有了包内的华为版权声明作为补充证据，但仍不构成签名级验证。

**发现二（推翻原设计的「不支持假设」第 2 条）：环境变量名官方文档写错了。**

| 出处 | 变量名 | 适用范围 |
| --- | --- | --- |
| 官方文档 Linux 一节 | `DEVECO_CLI_CLI_PATH` | 只在 Linux 一节出现 |
| 包内 `SKILL.md`（实际实现） | **`DEVECO_CLI_CLT_PATH`** | 通用表述，无平台限定 |

`SKILL.md` 原文：`Set DEVECO_CLI_CLT_PATH to the Command Line Tools root when DevEco Studio is not installed; CLT is not discovered automatically from PATH or default installation directories.`

`CLT` = Command Line Tools，语义也比 `CLI` 通顺。官方文档那个 `CLI_PATH` 大概率是笔误。
**「不装 DevEco Studio」是一等公民支持路径**，基线为 CLT ≥ 26.0.0。附带信息：CLT 不会被自动发现，必须显式设这个变量。

**发现三：Studio 硬依赖只压在部分命令上，`create` / `build` 不在其中。**

| 命令 | DevEco Studio 要求 |
| --- | --- |
| `create` | **无** |
| `build` | **未标注 Studio 要求**（标 `[Outside sandbox]`） |
| `check lint` | ≥ 6.0.0（`--format`/`--output-path` 需 ≥ 6.1.0）；CLT 模式走 CLT ≥ 26.0.0 基线 |
| `ui` | ≥ 6.1.0 |
| `run --apply` | ≥ 6.1.1 |
| `check compat` | 依赖 Studio 的 `arkanalyzer-apiscan` 插件 |

即：**创建与编译这条最小闭环没有 Studio 硬依赖**，Studio 只卡在 lint / UI 检视 / 热重载 / 兼容性扫描上。
原设计里「环境搭建章节要求 DevEco Studio 6.0.0+」应理解为推荐配置，而非 `create`/`build` 的强制前置。

**发现四：包内自带完整 Empty Ability 模板（25 个文件），离线可用。**

```
templates/application/
  AppScope/{app.json5, resources/base/{element/string.json, media/layered_image.json}}
  build-profile.json5  code-linter.json5  hvigorfile.ts  oh-package.json5  gitignore.txt
  hvigor/hvigor-config.json5          # modelVersion 6.0.2
  entry/{build-profile.json5, hvigorfile.ts, oh-package.json5, obfuscation-rules.txt, gitignore.txt}
  entry/src/main/module.json5
  entry/src/main/ets/{entryability/EntryAbility.ets, entrybackupability/EntryBackupAbility.ets, pages/Index.ets}
  entry/src/main/resources/base/{element/{color,float,string}.json, media/layered_image.json,
                                profile/{backup_config,main_pages}.json}
  entry/src/main/resources/dark/element/color.json
```

这套模板可作为「官方口径的工程结构」直接引用，也印证了 `docs/01-platform-landscape.md` 的标准结构与 R18/R20 的必填字段。
`create` 的参数（来自 `SKILL.md`）：`--app-name`（必填，`^[a-zA-Z][a-zA-Z0-9_]*$`）、`--project-path`（默认 `./<app-name>`，已存在则必须为空）、`--bundle-name`（默认 `com.example.<小写名>`，7–128 字符，≥3 段）、`--api-level`（整数 ≥17，默认 auto 或 23）。

**发现五：包内有 `SKILL.md`**，front-matter 是 `name` / `description` 的 skill 格式，即华为把 DevEco CLI 直接做成了可被 Agent 装载的 skill。与 `docs/04-official-ai-coding-tools.md` 的判断一致，且比文档更具体。

### 步 0.9 本机环境实测（2026-09-02，只读）

| 项 | 结果 | 影响 |
| --- | --- | --- |
| `java` / `javac` | `/usr/bin/java` 存在但是 **stub**：`Unable to locate a Java Runtime` | ❗**JDK 是真实缺口**，必须装 |
| `/usr/libexec/java_home -V` | 无任何 JVM | 同上 |
| Node / npm | v24.6.0 / 11.5.1 | ✅ 满足 `engines.node >=22` |
| `hvigorw`/`ohpm`/`hdc`/`codelinter`/`devecocli`/`deveco` | 全部 not found | 预期 |
| DevEco Studio、`~/Library/Huawei`、`~/.ohpm`、`/opt/command-line-tools` | 全部不存在 | 环境干净，无残留 |
| 架构 | `arm64` | ✅ CLT 与模拟器都要 macOS ARM |

### 步 1 已执行（2026-09-02）：DevEco CLI 在无 IDE 的 macOS 上可运行 ✅

局部安装到 `~/.local/hmos-toolchain/cli`（非 `npm -g`，`rm -rf` 即可完全回滚）：

```bash
npm install @deveco/deveco-cli@stable   # added 250 packages in 28s
~/.local/hmos-toolchain/cli/node_modules/.bin/devecocli --version
# → 1.3.0-stable
```

`--help` 列出 16 个命令：`build` `run` `update` `device` `emulator` `auth` `skills` `log`
`create` `init` `serve` `docs` `ui` `check` `signature` `help`。

**结论：CLI 本体不依赖 DevEco Studio，装完就能跑。** `postinstall` 未产生异常。

### 步 2 已执行（2026-09-02）：拿到准确的依赖诊断 ✅（这一步价值最高）

无任何 SDK 时直接 create：

```bash
devecocli create --app-name ProbeApp --project-path /tmp/hmos-create-probe
# → Error: DevEco Studio installation not found in default locations.
```

于是做**对照实验**，验证两个变量名到底哪个生效：

| 设置的变量 | 结果 | 判读 |
| --- | --- | --- |
| `DEVECO_CLI_CLI_PATH=/tmp/fake-clt`（**官方文档写的**） | `Error: DevEco Studio installation not found in default locations.` | 变量**被完全忽略**，等同于没设 |
| `DEVECO_CLI_CLT_PATH=/tmp/fake-clt`（**包内 SKILL.md 写的**） | `Error: Invalid DEVECO_CLI_CLT_PATH: /tmp/fake-clt` | 变量**被读取并校验** ✅ |

**这就把步 0.5 的发现二从「文档笔误推测」升级为「执行验证」：照官方文档 `ide-deveco-cli-install` 抄
`export DEVECO_CLI_CLI_PATH=/opt/command-line-tools` 是无效的，必须写 `DEVECO_CLI_CLT_PATH`。**
同时也证明**该变量在 macOS 上生效**（官方只在 Linux 一节提过它），原设计「不支持假设」第 2 条据此作废。

反编译 `dist/cli.js` 进一步取到实现细节（`resolveInstallSourceUncached`）：

- CLI 只认四个变量，按优先级：`DEVECO_CLI_STUDIO_PATH` → **`DEVECO_CLI_CLT_PATH`** → `DEVECO_HOME` → `DEVECO_PATH`。**没有 `DEVECO_CLI_CLI_PATH`。**
- CLT 目录有效性判据：根目录下存在 **`version.txt`**（`readCltVersion` 读它）。
- CLT 模式的 Java 解析（`resolveCltJava`）：`JAVA_HOME/bin` → `JAVA_HOME` → `PATH`，都找不到则硬报错
  `No Java runtime found in CLT mode.`。→ **CLT 不自带 JDK**，步 0.5 的遗留问题至此确认。
- `--api-level` 自动探测读 `${sdk}/default/sdk-pkg.json` 的 `platformVersion`，读不到回落 **23**。
- Linux 上会直接抛 `DevEco Studio is not available on Linux. Set DEVECO_CLI_CLT_PATH to a Command Line Tools installation.`——反证 CLT-only 是设计内的一等路径。

### 步 3 部分完成：JDK 21 ✅ / Command Line Tools ❌ 受阻

**JDK 21 已就位并实测通过。** 选 Eclipse Temurin 而非 Homebrew，理由是自成一体、零全局改动、`rm -rf` 即卸载：

```bash
curl -fL -o temurin21.tar.gz \
  "https://api.adoptium.net/v3/binary/latest/21/ga/mac/aarch64/jdk/hotspot/normal/eclipse"
shasum -a 256 temurin21.tar.gz
# 3623232f33a9c3baadf304480b2535f9a3cba8a58d42ecbb438ba267315d9998
```

校验：该 sha256 与 Adoptium API 公布的 `OpenJDK21U-jdk_aarch64_mac_hotspot_21.0.12.1_1.tar.gz`
发布值**逐字一致**，size 200073404 亦一致。解压后：

```
openjdk version "21.0.12.1" 2026-08-18 LTS
OpenJDK Runtime Environment Temurin-21.0.12.1+1 (build 21.0.12.1+1-LTS)
javac 21.0.12.1
```

（过程中踩了一个自己的坑：首次下载放在后台，只看文件大小就以为完成，实际被截断，
解压报 `truncated gzip input`。重下并加校验后通过。教训：大文件必须校验 sha256，不能只看 size。）

**Command Line Tools 受阻——这是当前唯一的硬卡点。**

| 项 | 情况 |
| --- | --- |
| 需要什么 | Command Line Tools ≥ 26.0.0，macOS ARM 版，解压后根目录含 `version.txt` |
| 下载页 | `https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos` |
| 为什么拿不到 | 该页与文档中心同为 Angular SPA，`WebFetch` 只得空壳；**且下载需华为开发者账号登录**。第三方工具 `chawyehsu/hdx` 的 `dget` 能解析下载直链，但其 `auth login` 明确要求「Huawei ID + 密码 + **动态验证码**」，手机号/邮箱+密码不支持 |
| 结论 | 动态验证码环节**必须由人完成**，Agent 无法代办 |

### 步 4 / 5

（阻塞，等 CLT 就位）

## 结论

**部分结论已可下：假设的前两个环节成立，第三个环节未验。**

| 环节 | 状态 |
| --- | --- |
| DevEco CLI 能在无 DevEco Studio 的 macOS 上安装并运行 | ✅ 已验证 |
| 「不装 Studio」是官方设计内的支持路径，靠 `DEVECO_CLI_CLT_PATH` 指向 CLT | ✅ 已验证（含官方文档变量名笔误的实测反证） |
| `create` / `build` 能在 CLT-only 模式下真正产出 HAP | ⏸ 未验，卡在 CLT 下载需人工登录 |

副产物：`harmony/env.sh`（项目本地环境变量脚本，不改动 `~/.zshrc`）。

## 遗留

- 真机调试与模拟器不在本实验范围：真机需实名认证 + AGC 签名，模拟器仅支持 Windows X86 与 macOS ARM，需另立实验。
- `devecocli` 哪些命令强制华为账号登录，官方未列明；步 1、2 可顺带观察。
- 若假设成立，下一步是让 `docs/03-arkts-codegen-rules.md` 里的示例逐条过编译，把「未编译验证」的标注逐步摘掉。
