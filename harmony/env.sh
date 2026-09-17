#!/bin/sh
# 鸿蒙工具链环境变量 —— 项目本地，**不改动 ~/.zshrc 或 ~/.zprofile**
#
# 用法（每个新终端都要执行一次）：
#   source harmony/env.sh          # 指向 HarmonyOS CLT（仓库默认一侧，本机尚未就位）
#   source harmony/env.sh ohos     # 指向免登录的 OpenHarmony 链（本机唯一能真编译的一侧）
#
# 全部内容装在 ~/.local/hmos-toolchain/ 下，自成一体，不进本仓库。
# 完全卸载：rm -rf ~/.local/hmos-toolchain
#
# 最后更新：2026-09-17

HMOS_TOOLCHAIN="$HOME/.local/hmos-toolchain"

# ---- JDK 21（已就位，实测通过）------------------------------------------------
# Temurin 21.0.12.1+1 LTS，sha256 对过 Adoptium 官方发布值。
# 官方要求：CLT ≥ 26.0.0 推荐 JDK 21，26.0.0 以下推荐 JDK 17（ide-command-line-building-app）。
# DevEco CLI 在 CLT 模式下按 JAVA_HOME/bin → JAVA_HOME → PATH 找 java，只设 JAVA_HOME 即可。
export JAVA_HOME="$HMOS_TOOLCHAIN/jdk-21.0.12.1+1/Contents/Home"

# ---- DevEco CLI（已就位，实测 --version 通过）---------------------------------
# 局部安装（非 npm -g），版本 1.3.0-stable。
export PATH="$HMOS_TOOLCHAIN/cli/node_modules/.bin:$JAVA_HOME/bin:$PATH"

# ---- Command Line Tools ------------------------------------------------------
# 变量名以包内实现为准：DEVECO_CLI_CLT_PATH。
# ❗️官方文档 ide-deveco-cli-install 写的是 DEVECO_CLI_CLI_PATH，实测**完全不生效**。
#   CLI 认的四个变量：DEVECO_CLI_STUDIO_PATH / DEVECO_CLI_CLT_PATH / DEVECO_HOME / DEVECO_PATH
# 有效性判据：该目录下必须有 version.txt（CLI 读它取版本号）。
if [ "${1:-}" = "ohos" ] || [ "${1:-}" = "openharmony" ]; then
  # 免登录的 OpenHarmony 编译链（2026-09-03 实测 BUILD SUCCESSFUL）。
  # 全部来自公开直链、每件对过官方 sha256，装法见 TOOLCHAIN.md。
  # 它能真编译，产物是 **OpenHarmony HAP**，装不进 HarmonyOS NEXT。
  export DEVECO_CLI_CLT_PATH="$HMOS_TOOLCHAIN/clt-oh"
  # ❗️硬要求，缺了报 00303208 Unable to find 'sdk.dir' in 'local.properties' or
  #   'OHOS_BASE_SDK_HOME'。用环境变量而非往工程里加 local.properties——后者是机器
  #   相关文件，已在 .gitignore。
  export OHOS_BASE_SDK_HOME="$HMOS_TOOLCHAIN/clt-oh/sdk"
  echo "已指向 OpenHarmony 链：$DEVECO_CLI_CLT_PATH"
  echo "编译前工程要切到同一侧：bash harmony/switch-runtime.sh ohos"
else
  export DEVECO_CLI_CLT_PATH="$HMOS_TOOLCHAIN/command-line-tools"
  unset OHOS_BASE_SDK_HOME
fi

# CLT 解压到位后，取消下面几行的注释即可获得 hvigorw / ohpm / codelinter / hdc。
# 路径依据：ide-commandline-get、ide-command-line-building-app。
# export PATH="$DEVECO_CLI_CLT_PATH/bin:$PATH"
# export HDC_HOME="$DEVECO_CLI_CLT_PATH/sdk/default/openharmony/toolchains"
# export PATH="$PATH:$HDC_HOME"
# ⚠️ sdk/default/openharmony/toolchains 是 DevEco CLI 的 **hdcPath（设备部署用）**，
#    不是构建期 SDK 布局。构建期 hvigor 找的是
#    $CLT/sdk/<apiVersion>/{ets,js,native,toolchains,previewer}
#    （abstract-component-loader.js 的 getLocation()）。两者不要混为一谈。
# 注：CLT 自带配套 Node.js（macOS 在 tool/node/bin），官方建议优先用它；
#     本机 Node v24.6.0 满足 DevEco CLI 的 engines.node>=22，暂不切换。

if [ ! -f "$DEVECO_CLI_CLT_PATH/version.txt" ]; then
  echo "⚠️  Command Line Tools 未就位：$DEVECO_CLI_CLT_PATH"
  echo "    HarmonyOS 侧的 CLT 下载需华为账号登录，见 TOOLCHAIN.md。"
  if [ -f "$HMOS_TOOLCHAIN/clt-oh/version.txt" ]; then
    echo "    ℹ️  免登录的 OpenHarmony 链已就位，用它编译：source harmony/env.sh ohos"
  fi
fi
