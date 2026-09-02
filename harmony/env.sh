#!/bin/sh
# 鸿蒙工具链环境变量 —— 项目本地，**不改动 ~/.zshrc 或 ~/.zprofile**
#
# 用法（每个新终端都要执行一次）：
#   source harmony/env.sh
#
# 全部内容都装在 ~/.local/hmos-toolchain/ 下，自成一体。
# 完全卸载：rm -rf ~/.local/hmos-toolchain && rm harmony/env.sh
#
# 最后更新：2026-09-02

HMOS_TOOLCHAIN="$HOME/.local/hmos-toolchain"

# ---- JDK 21（已就位，实测通过）------------------------------------------------
# Temurin 21.0.12.1+1 LTS，sha256 已对过 Adoptium 官方发布值。
# 官方要求：CLT ≥ 26.0.0 推荐 JDK 21，26.0.0 以下推荐 JDK 17（ide-command-line-building-app）。
# DevEco CLI 在 CLT 模式下按 JAVA_HOME/bin → JAVA_HOME → PATH 的顺序找 java，
# 所以只设 JAVA_HOME 就够，不必污染全局 PATH。
export JAVA_HOME="$HMOS_TOOLCHAIN/jdk-21.0.12.1+1/Contents/Home"

# ---- DevEco CLI（已就位，实测 --version 通过）---------------------------------
# 局部安装（非 npm -g），版本 1.3.0-stable。
export PATH="$HMOS_TOOLCHAIN/cli/node_modules/.bin:$JAVA_HOME/bin:$PATH"

# ---- Command Line Tools（⚠️ 尚未就位，需华为账号登录后手动下载）--------------
# 变量名以包内实现为准：DEVECO_CLI_CLT_PATH。
# ❗️官方文档 ide-deveco-cli-install 写的是 DEVECO_CLI_CLI_PATH，实测**完全不生效**，
#   见 experiments/001 步 2。CLI 认的四个变量是：
#     DEVECO_CLI_STUDIO_PATH / DEVECO_CLI_CLT_PATH / DEVECO_HOME / DEVECO_PATH
# 有效性判据：该目录下必须有 version.txt（CLI 读它取版本号）。
export DEVECO_CLI_CLT_PATH="$HMOS_TOOLCHAIN/command-line-tools"

# CLT 解压到位后，取消下面几行的注释即可获得 hvigorw / ohpm / codelinter / hdc。
# 路径依据：ide-commandline-get、ide-command-line-building-app。
# export PATH="$DEVECO_CLI_CLT_PATH/bin:$PATH"
# export HDC_HOME="$DEVECO_CLI_CLT_PATH/sdk/default/openharmony/toolchains"
# export PATH="$PATH:$HDC_HOME"
# 注：CLT 自带配套 Node.js（macOS 在 tool/node/bin），官方建议优先用它；
#     本机已有 Node v24.6.0，满足 DevEco CLI 的 engines.node>=22，暂不切换。

if [ ! -f "$DEVECO_CLI_CLT_PATH/version.txt" ]; then
  echo "⚠️  Command Line Tools 未就位：$DEVECO_CLI_CLT_PATH"
  echo "    devecocli create / build 会失败。下载需华为账号登录，见 harmony/README.md。"
fi
