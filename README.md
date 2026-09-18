# hm · HarmonyOS 侧的 WebView 容器

**这是三端 WebView 容器的鸿蒙那一份。** 规划在上游仓库 `pro`（`Prospect`），本仓只出代码。
应用名 `Crab`／中文「螃蟹」，标识 `net.xiaoluzhu.crab`，产物 HAP，鸿蒙走 **HarmonyOS NEXT**，
不走 OpenHarmony。

**按的是 pro 的 commit `e857625`。** pro 会动（插队 spike 的答案回来、出口 2/3 议完都要改文档），
往下一个里程碑走之前重读它的 `README.md` + `plan/` 五份 + `开工.md`，并更新这一行。

判据不在本仓。要做什么、怎么算过、有什么还没核实，只在 pro 那七份文件里；取值只在 pro 的取值表。
本仓写的是**怎么在鸿蒙上做到**，以及**鸿蒙侧特有的坑**。

## 目录

| 路径 | 是什么 |
| --- | --- |
| `harmony/Crab/` | 真实工程。`devecocli create` 从官方模板生成，**不手搓** |
| `harmony/env.sh` | 工具链环境变量，`source` 后生效 |
| `harmony/switch-runtime.sh` | 两套 SDK 家族的工程配置切换 |
| [`TASKS.md`](TASKS.md) | M1–M5 的「怎么算过」逐条翻译成鸿蒙侧任务（pro 要求的第一件产出），落本仓、pro 不收 |
| [`TOOLCHAIN.md`](TOOLCHAIN.md) | 鸿蒙侧工程事实：工具链现状、两套 SDK 互斥、错误码速查 |
| [`ARKTS-RULES.md`](ARKTS-RULES.md) | AI 写 ArkTS 容易写错的点（R1–R22），逐条带出处 |
| `scripts/probe.sh` | 探针页验收命令，三仓同名，输出形状由 pro 定。**现在只有骨架** |
| `tools/hwdoc.py` | 抓官方文档用（官方站是 Angular SPA，只能走接口） |

平台事实不在本仓——平台声明与平台层面的技术约束归 pro 对应里程碑的「平台事实」块。

## 进度

| 里程碑 | 状态 |
| --- | --- |
| [M1 装到模拟器](TASKS.md#m1--装到模拟器) | 🟡 **已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行**；「装进模拟器、屏幕上有一个原生页面」阻塞（见下） |
| M2 本地承载 | ⬜ 未开工。`scripts/probe.sh` 只有骨架 |
| M3 配置注入与 UA | ⬜ 未开工 |
| M4 导航与降级 | ⬜ 未开工 |
| M5 三端汇合 | ⬜ 未开工 |

**M1 一过要插队两条 spike**：① 模拟器上 ArkWeb 跑不跑得起来，顺带 `resource://` 的 origin 与子资源；
② `data:` iframe 加不加载得起来。答案先回 pro 改文档再往 M2 走。两条都被同一个阻塞挡着。

## 怎么编译

```sh
bash harmony/switch-runtime.sh ohos      # 切到 OpenHarmony 侧（仓库默认是 HarmonyOS 侧）
source harmony/env.sh ohos               # JAVA_HOME / DEVECO_CLI_CLT_PATH / OHOS_BASE_SDK_HOME
cd harmony/Crab && devecocli build
bash harmony/switch-runtime.sh hos       # 提交前切回来
```

两套 SDK 家族互斥，配错了报的错和代码无关。编不过先看
[`TOOLCHAIN.md`](TOOLCHAIN.md#三分钟检查清单) 的三分钟检查清单，工具链本身的状态在
[`TOOLCHAIN.md`](TOOLCHAIN.md#现在有什么)。

## 阻塞在哪

**没有 HarmonyOS SDK，也没有模拟器镜像。** 本机唯一能编译的是免登录的 OpenHarmony API 23 链，
它出的是 OpenHarmony HAP，装不进 HarmonyOS NEXT。后果有两层：

- M1 的「装进模拟器、屏幕上有一个原生页面」观察不了，**M1 不能宣布过**
- M2 到 M4 每一条判据都靠模拟器观察，一条都跑不了；`scripts/probe.sh` 因此只能是骨架

解法是人工的一步：登录华为开发者账号下载 Command Line Tools 与模拟器镜像，步骤在
[`TOOLCHAIN.md`](TOOLCHAIN.md#需要人做的一步)。动态验证码那一环 Agent 代办不了。

⚠️ 顺带一个还没解决的口径冲突：官方指南说 ArkWeb 支持模拟器，而 `arkts-apis-webview` 的模块页写
「示例效果请以真机运行为准」。**模拟器上跑不起来时不得自行改成真机验收**——那是范围级的事，回 pro 议
（pro 的三条红线之一）。

## 三条纪律，端侧不许自己动

来自 pro 的 `开工.md`，抄在这里是为了动手前能看见：

1. **取值一律取 pro 的取值表**；承载 origin 一类在端内只定义一处，别处从它派生，不另写字面量
2. **slug、输出形状与探针页那五条规约三端一字不差**，要改三端一起跟
3. **做不到时只能走第 1 个出口（改本端实现）**；放宽要求、允许本端偏离这两个出口回 pro 议，不自决

## 验证强度分三档，措辞不许混用

**未编译验证** < **已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行** < **已运行验证**

- 能编译就去编译，摘标注的前提是真的过了 `devecocli build`
- **编译通过只覆盖类型/签名层面。** 运行期语义（消息时序、`refresh()` 生效时机、运行期错误码）
  编译器管不着，一律仍算未验证
- **OpenHarmony SDK 是子集，过了它不等于过 HarmonyOS SDK**，不要把两者写成一回事
- 本机没有设备/模拟器，**任何情况下都不要宣称「已验证可运行」**

## 抓官方文档

`developer.huawei.com` 是 Angular SPA，`curl` 拿不到正文，只能走它自己的接口：

```sh
python3 tools/hwdoc.py tree harmonyos-guides       # 导目录树
python3 tools/hwdoc.py doc web-component-overview  # 取正文
python3 tools/hwdoc.py meta web-component-overview # 取 version / 更新时间
```

`objectId` 就是 URL 里那段 slug（不是 `nodeId`）。URL 拼法
`https://developer.huawei.com/consumer/cn/doc/<catalogName>/<slug>`。

鸿蒙的 API 名称、Kit 归属、起始 API Level 变动频繁，**凭印象写 = 事故**：查不到就写「未确认」，
不确定就标 `⚠️ 待核实`，写下的事实带访问日期。

## 边界

- 不提交签名证书、私钥、`.p12`/`.cer`/`.p7b`、AGC 账号信息（`.gitignore` 拦一层，以人工确认为准）
- 工具链装在 `~/.local/hmos-toolchain/`，**不进本仓库、不提交、不改 `~/.zshrc`**
- 工程结构由 `devecocli create` 生成，改动要能说清依据
- 回退点：`pre-rebuild` tag（重建前 `main` 的 HEAD，`024bcc4`）。旧的端侧 AI 调研、JSBridge 契约、
  同层渲染与离线组件笔记都在那里，本仓不留 `archive/`——留着就是第二个真相
