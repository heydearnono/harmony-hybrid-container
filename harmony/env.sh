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

# ---- 免登录的 OpenHarmony 编译链（✅ 2026-09-03 实测 BUILD SUCCESSFUL）------------
# 这一套在 $HMOS_TOOLCHAIN/clt-oh/，全部来自公开直链、每件都对过官方 sha256。
# 它能真编译，但产物是 **OpenHarmony HAP**，装不进 HarmonyOS NEXT 真机。
# 装法与依据见 harmony/README.md 的「另一条路」、research-log/2026-09-03-免登录编译打通.md。
#
# 用法：source harmony/env.sh 之后再 export 下面两行覆盖（默认不启用，保持指向真 CLT 的位置）：
#   export DEVECO_CLI_CLT_PATH="$HMOS_TOOLCHAIN/clt-oh"
#   export OHOS_BASE_SDK_HOME="$HMOS_TOOLCHAIN/clt-oh/sdk"
# 然后：cd harmony/HybridShell && devecocli build
#
# ❗️OHOS_BASE_SDK_HOME 是硬要求，缺了报
#   00303208 Unable to find 'sdk.dir' in 'local.properties' or 'OHOS_BASE_SDK_HOME'。
#   用环境变量而不是往工程里加 local.properties——后者是机器相关文件，已在 .gitignore。
# ❗️工程侧配套改动（已写进文件，注释里留了改回 HarmonyOS 的原值）：
#   build-profile.json5: runtimeOS=OpenHarmony，compile/compatible/targetSdkVersion=23（整数）
#   entry/src/main/module.json5: deviceTypes=["default"]（OpenHarmony 没有 phone）

# ---- 桩（仅 create 用，不要用于 build）----------------------------------------
# 2026-09-03：为了先把工程骨架落下来，临时把 DEVECO_CLI_CLT_PATH 指向
# $HMOS_TOOLCHAIN/clt-stub（里面只有一个 version.txt）。create 只校验版本号、
# 不碰 SDK，所以能过；build 必然失败在 ohpm。
# 本文件**不**默认启用桩——需要重新 create 时手动 export 覆盖即可。
# 真 CLT 到位后请删除桩目录：rm -rf "$HMOS_TOOLCHAIN/clt-stub"
# 细节见 harmony/README.md 的「骨架是怎么生成的」。

# CLT 解压到位后，取消下面几行的注释即可获得 hvigorw / ohpm / codelinter / hdc。
# 路径依据：ide-commandline-get、ide-command-line-building-app。
# export PATH="$DEVECO_CLI_CLT_PATH/bin:$PATH"
# export HDC_HOME="$DEVECO_CLI_CLT_PATH/sdk/default/openharmony/toolchains"
# export PATH="$PATH:$HDC_HOME"
# ⚠️ 2026-09-03 修正：上面这个 sdk/default/openharmony/toolchains 是 DevEco CLI 的
#    **hdcPath（设备部署用）**，不是构建期 SDK 布局。构建期 hvigor 找的是
#    $CLT/sdk/<apiVersion>/{ets,js,native,toolchains,previewer}（见 abstract-component-loader.js
#    的 getLocation()）。两者不要混为一谈。
# 注：CLT 自带配套 Node.js（macOS 在 tool/node/bin），官方建议优先用它；
#     本机已有 Node v24.6.0，满足 DevEco CLI 的 engines.node>=22，暂不切换。

if [ ! -f "$DEVECO_CLI_CLT_PATH/version.txt" ]; then
  echo "⚠️  HarmonyOS Command Line Tools 未就位：$DEVECO_CLI_CLT_PATH"
  echo "    下载需华为账号登录，见 harmony/README.md。"
  if [ -f "$HMOS_TOOLCHAIN/clt-oh/version.txt" ]; then
    echo "    ℹ️  免登录的 OpenHarmony 链已就位，要用它编译请再执行："
    echo "        export DEVECO_CLI_CLT_PATH=\"\$HMOS_TOOLCHAIN/clt-oh\""
    echo "        export OHOS_BASE_SDK_HOME=\"\$HMOS_TOOLCHAIN/clt-oh/sdk\""
    echo "    ⚠️  产物是 OpenHarmony HAP，不是 HarmonyOS HAP。"
  fi
fi
