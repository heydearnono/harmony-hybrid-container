#!/usr/bin/env bash
# 在 HarmonyOS / OpenHarmony 两套平台配置之间切换 HybridShell 工程。
#
#   bash harmony/switch-runtime.sh hos     # HarmonyOS（仓库默认，DevEco Studio 能直接打开）
#   bash harmony/switch-runtime.sh ohos    # OpenHarmony（本机免登录编译链用这个）
#   bash harmony/switch-runtime.sh         # 只看当前状态，不改文件
#
# 为什么要这个脚本：两套 SDK 家族的工程配置不兼容，靠人手改两个文件四处值容易漏。
#   - runtimeOS: "OpenHarmony" 时，HarmonyOS SDK 侧会报
#     `The ArkTS SDK of version 23 in OpenHarmony is not found.[entry]`
#   - deviceTypes: "phone" 在 OpenHarmony SDK 侧会报 00303060「系统能力集交集为空」
# 依据见 harmony/README.md 的「另一条路」。
#
# 只重写两个文件里 `>>> PLATFORM BLOCK >>>` 与 `<<< PLATFORM BLOCK <<<` 之间的内容，
# 注释和其余配置原样保留。

set -euo pipefail

PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/HybridShell"
BUILD_PROFILE="$PROJ/build-profile.json5"
MODULE_JSON="$PROJ/entry/src/main/module.json5"

for f in "$BUILD_PROFILE" "$MODULE_JSON"; do
  [ -f "$f" ] || { echo "找不到 $f" >&2; exit 1; }
done

current() {
  if grep -q '"runtimeOS": "OpenHarmony"' "$BUILD_PROFILE"; then echo ohos; else echo hos; fi
}

# replace_block <文件> <缩进> <块内容>
replace_block() {
  BLOCK_FILE="$1" BLOCK_INDENT="$2" BLOCK_BODY="$3" python3 - <<'PY'
import os, re
path = os.environ['BLOCK_FILE']
indent = os.environ['BLOCK_INDENT']
body = os.environ['BLOCK_BODY'].strip('\n')
lines = [indent + l if l else '' for l in body.split('\n')]
new = '\n'.join(lines)
src = open(path, encoding='utf-8').read()
pat = re.compile(r'(>>> PLATFORM BLOCK >>>\n).*?(\n[ \t]*// <<< PLATFORM BLOCK <<<)', re.S)
if not pat.search(src):
    raise SystemExit(f'{path}: 找不到 PLATFORM BLOCK 标记，文件被手改过？')
open(path, 'w', encoding='utf-8').write(pat.sub(lambda m: m.group(1) + new + m.group(2), src, count=1))
PY
}

target="${1:-}"

if [ -z "$target" ]; then
  echo "当前：$(current)"
  exit 0
fi

case "$target" in
  hos|harmonyos|HarmonyOS)
    replace_block "$BUILD_PROFILE" '        ' '
"targetSdkVersion": "6.1.0(23)",
"compatibleSdkVersion": "6.1.0(23)",
"runtimeOS": "HarmonyOS",'
    replace_block "$MODULE_JSON" '    ' '
"deviceTypes": [
  "phone"
],'
    echo '已切到 HarmonyOS（"6.1.0(23)" × 2、无 compileSdkVersion、deviceTypes=["phone"]）。'
    echo '需要 HarmonyOS Command Line Tools 或 DevEco Studio 才能编译；本机没有，切到这一侧就编不过。'
    ;;
  ohos|openharmony|OpenHarmony)
    replace_block "$BUILD_PROFILE" '        ' '
"compileSdkVersion": 23,
"compatibleSdkVersion": 23,
"targetSdkVersion": 23,
"runtimeOS": "OpenHarmony",'
    replace_block "$MODULE_JSON" '    ' '
"deviceTypes": [
  "default"
],'
    echo '已切到 OpenHarmony（整数 23 × 3 + compileSdkVersion、deviceTypes=["default"]）。'
    echo '编译：source harmony/env.sh && cd harmony/HybridShell && devecocli build'
    ;;
  *)
    echo "用法：bash harmony/switch-runtime.sh [hos|ohos]" >&2
    exit 2
    ;;
esac
