# harmony/ — 工程位

最后更新：2026-09-02 ｜ **工程尚未落地，卡在 Command Line Tools 下载（需华为账号登录）**

## 现在缺什么

工具链已就绪 2/3，全部装在 `~/.local/hmos-toolchain/`（自成一体，`rm -rf` 即卸载）：

| 组件 | 状态 | 位置 |
| --- | --- | --- |
| DevEco CLI 1.3.0-stable | ✅ 实测 `--version` 通过 | `~/.local/hmos-toolchain/cli/` |
| JDK 21（Temurin 21.0.12.1+1 LTS） | ✅ 实测 `java -version` 通过，sha256 已对官方值 | `~/.local/hmos-toolchain/jdk-21.0.12.1+1/` |
| Command Line Tools ≥ 26.0.0 | ❌ **未就位，这是唯一卡点** | 应放到 `~/.local/hmos-toolchain/command-line-tools/` |

环境变量走 `source harmony/env.sh`，**不改动 `~/.zshrc`**。

## 需要人做的一步

CLT 的下载页需要**华为开发者账号登录**（第三方 CLI `hdx` 也要求 Huawei ID + 动态验证码），
动态验证码这一环 Agent 无法代办。所以：

1. 打开 <https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos>，登录并下载 **macOS ARM** 版（≥ 26.0.0）。
2. 按下载页的「工具完整性指导」校验一次。
3. 解压，让 `~/.local/hmos-toolchain/command-line-tools/` 下**直接**是 `version.txt`、`bin/`、`sdk/`、`tool/`。
   注意 zip 内通常已含一层 `command-line-tools/` 目录，别套两层。

判据：`ls ~/.local/hmos-toolchain/command-line-tools/version.txt` 能看到文件即算就位——
DevEco CLI 正是读这个文件来认 CLT（见 `experiments/001` 步 2 对 `dist/cli.js` 的核对）。

之后 `source harmony/env.sh && devecocli create ...` 即可，剩下的自动化。

## 一个必须知道的坑

官方文档 `ide-deveco-cli-install` 写的环境变量名是 `DEVECO_CLI_CLI_PATH`，**实测完全无效**。
真正生效的是 **`DEVECO_CLI_CLT_PATH`**（对照实验见 `experiments/001` 步 2）。`env.sh` 已按实测值写好。

## 工程落地后应该长什么样

`devecocli create` 用的是包内自带的官方模板（25 个文件，已离线读过），结构与
`docs/01-platform-landscape.md` 的「标准工程结构」一致：

```
AppScope/{app.json5, resources/...}
build-profile.json5  oh-package.json5  hvigorfile.ts  code-linter.json5
hvigor/hvigor-config.json5              # modelVersion 6.0.2
entry/{build-profile.json5, oh-package.json5, hvigorfile.ts, obfuscation-rules.txt}
entry/src/main/module.json5
entry/src/main/ets/{entryability/EntryAbility.ets, entrybackupability/EntryBackupAbility.ets, pages/Index.ets}
entry/src/main/resources/base/{element/..., media/..., profile/{backup_config,main_pages}.json}
entry/src/main/resources/dark/element/color.json
```

`create` 参数：`--app-name`（必填，`^[a-zA-Z][a-zA-Z0-9_]*$`）、`--project-path`（默认 `./<app-name>`，
已存在则必须为空）、`--bundle-name`（默认 `com.example.<小写名>`）、`--api-level`（整数 ≥17，
不传则从 SDK 的 `sdk-pkg.json` 探测，探不到回落 23）。

## 落地时的注意事项

- 签名证书、私钥、`.p12`/`.cer`/`.p7b`、AGC 账号信息一律不入库。`.gitignore` 拦了一层，但以人工确认为准。
- 真机调试需实名认证 + AGC 签名；模拟器仅支持 Windows X86 与 macOS ARM（本机 arm64，满足）。
- 目标 API 版本建议看现网分布而非最新版：截至 2026-08-20，6.1.1(24) 占 84.93%，26.0.0 对应的 7.0.0 Beta2 仅 4.65%。
- 工具链不要装进本仓库，也不要提交。装在 `~/.local/hmos-toolchain/` 就是为了这个。
