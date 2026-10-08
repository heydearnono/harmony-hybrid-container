# CLAUDE.md — 本仓约定（给 Agent 与人共同遵守）

## 这个项目是什么

**三端 WebView 容器的鸿蒙那一份，整个用 AI 开发。** 交付物是**能编译、能装、能跑的 HAP**，不是文档集。

规划在上游 `pro`（`~/Desktop/github/Prospect`）。**判据、要做什么、怎么算过、取值，一律只在 pro 的
`README.md` + `plan/` 五份 + `开工.md` 里，本仓一句也不复述**——复述出来就是第二处真相。本仓写的是
「怎么在鸿蒙上做到」。

开工先读三样：pro 那七份文件、本文件、`README.md` 里记的**按的是 pro 的哪个 commit**。往下一个里程碑
走之前重读 pro（它会动）。

## 三条纪律，不许自己动

| 纪律 | 出处 |
| --- | --- |
| 取值一律取 pro 的取值表；承载 origin 一类在端内只定义一处，别处从它派生，不另写字面量 | pro README · M2 |
| slug、输出形状与探针页那五条规约三端一字不差，要改三端一起跟 | pro M2 最后一节 |
| 做不到时只能走第 1 个出口（改本端实现）；放宽要求、允许本端偏离这两个出口回 pro 议 | pro README |

**红线**：鸿蒙模拟器跑不起 ArkWeb 时**不得自行改成真机验收**，那是范围级的事，回 pro 议。

## 目录约定

| 路径 | 用途 |
| --- | --- |
| `harmony/Crab/` | 真实工程。`devecocli create` 从官方模板生成，**不手搓**；生成后的改动要能说清依据 |
| `harmony/env.sh` | 工具链环境变量。`source harmony/env.sh ohos` 指向免登录的 OpenHarmony 链 |
| `harmony/switch-runtime.sh` | 两套 SDK 家族的工程配置切换，只重写 `PLATFORM BLOCK` 之间的内容 |
| `TASKS.md` | M1–M5 的「怎么算过」逐条翻译成鸿蒙侧任务：落在哪个 API、动哪个文件、哪条单测。**落本仓，pro 不收** |
| `TOOLCHAIN.md` | 鸿蒙侧工程事实：工具链现状、两套 SDK 互斥、错误码速查与逐条详解 |
| `ARKTS-RULES.md` | AI 写 ArkTS 容易写错的点（R1–R22）。本仓最有复用价值的产出，逐条带出处 |
| `docs/运行记录/` | 在模拟器上跑出来的原样输出与截图，一个里程碑或一次插队一份 |
| `scripts/probe.sh` | 探针页验收命令，**三仓同名**，输出形状由 pro 定 |
| `tools/hwdoc.py` | 抓官方文档（官方站是 Angular SPA，只能走接口） |

不建 `archive/`、不留旧结论的第二份。重建前的东西在 `pre-rebuild` tag 里。

**平台事实不落本仓。** 挖出来的平台声明与平台层面的技术约束归 pro 对应里程碑的「平台事实」块——直接
改 pro 那份文件并在提交信息里点名，或在 pro 上开 issue。本仓不留副本，也不留「待搬入」清单：那种清单
本身就是第二处真相。

## 事实纪律（最重要的一条）

鸿蒙的 API 名称、Kit 归属、起始 API Level 变动频繁，大模型对这块的记忆噪声很大。所以：

1. **每个事实都要有来源**：优先 `developer.huawei.com` 官方文档，其次官方大会公告/仓库，社区文章只作线索
2. **不确定就标 `⚠️ 待核实`**，不要用通顺的措辞掩盖不确定。宁可留空
3. **凭印象写 API 名、包名、版本号 = 事故**。查不到就写「未确认」
4. 事实带时效，写明**访问日期**；跨版本的信息标注适用 API Level
5. **验证强度分三档，措辞不许混用**：
   **未编译验证** < **已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行** < **已运行验证**
   - **能编译就去编译**，摘标注的前提是真的过了 `devecocli build`
   - **编译通过只覆盖类型/签名层面。** 运行期语义（消息时序、`refresh()` 生效时机、运行期错误码等）
     编译器管不着，一律仍算未验证
   - **OpenHarmony SDK 是子集，过了它不等于过 HarmonyOS SDK。** 不要把两者写成一回事
   - 本机没有设备/模拟器，**任何情况下都不要宣称「已验证可运行」**

## 一次任务的标准动作

1. 读 pro 对应里程碑，确认判据没变（pro 动过就先更新 `README.md` 里那个 commit）
2. 动手改 `harmony/Crab/`，**能编译就去编译**：
   ```sh
   bash harmony/switch-runtime.sh ohos
   source harmony/env.sh ohos && cd harmony/Crab && devecocli build
   ```
   报错原文比任何推测都有价值，进 `TOOLCHAIN.md` 的错误速查表
3. 提交前 `bash harmony/switch-runtime.sh hos` 切回仓库默认那一侧（HarmonyOS）
4. 发现「AI 写这段容易写错」的点 → 追加到 `ARKTS-RULES.md`
5. 挖出新的**平台事实** → 直接写进 pro 对应里程碑的「平台事实」块（见上面「平台事实不落本仓」）
6. 里程碑收尾，把「怎么算过」那几格的结果贴到 pro 上该里程碑的 issue（不等谁、不阻塞谁）

## 写作风格

- 中文，条目化，结论先行。不写「众所周知」「随着…的发展」这类填充句
- 表格优先于长段落，尤其是能力对照、版本对照
- 代码片段最小可读，注明适用 API Level 与导入路径来源
- 文档开头写一行「最后更新：YYYY-MM-DD」

## 边界

- 不提交签名证书、私钥、`.p12`/`.cer`/`.p7b`、AGC 账号信息（`.gitignore` 拦一层，以人工确认为准）
- 工具链装在 `~/.local/hmos-toolchain/`，**不进本仓库、不提交、不改 `~/.zshrc`**
- **不伪造 `$SDK/licenses/<id>.sha256`**（等于代人接受许可协议），不用无官方 sha256 的三方转载 SDK 包
- `local.properties` 走环境变量，不入库
