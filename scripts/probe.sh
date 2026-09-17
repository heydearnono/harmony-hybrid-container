#!/usr/bin/env bash
# 探针页验收命令 —— 三仓同名，取 scripts/probe.sh（pro/plan/M2 最后一节的规约）。
#
#   bash scripts/probe.sh          # 跑一遍，输出一行一条 `<slug> PASS|FAIL|MANUAL`
#   bash scripts/probe.sh --list   # 只打印 slug 与固定顺序，不跑任何东西
#
# 规约（三端一字不差，要改三端一起跟）：
#   - 一行一条，形状 `<slug> PASS|FAIL|MANUAL`，附加信息接在行尾
#   - 顺序固定，就是文档顺序：M2 六条 → M3 两条 → M4 八条，合计十六条
#   - MANUAL 只给结果既不在页面里、也不在原生日志里的条目——十六条里只剩
#     nav-system-scheme 一条（结果落在拨号盘与邮件应用），须在运行记录里另附一行人工观察
#   - M4 那几条要人先按按钮、答对话框、触发一次后退，**人工那一遍在本命令之前跑完**，
#     命令只把页面侧与日志侧的结果收齐并判定，不代按
#
# 现状：**骨架。十六条一律输出 `FAIL not-implemented`**——不发明第四种状态，也不假 PASS。
#       缺的是运行面，不是脚本：本机没有 HarmonyOS SDK、没有模拟器镜像，`Web` 组件一行都还没写
#       （M1 明确不碰 WebView）。阻塞与解法见 README.md「阻塞在哪」，落点见 TASKS.md。
#
# 填法：每条 slug 一个 probe_<slug>() 判定函数，判定的两个来源是
#   - 页面侧：探针页把每条断言的结果写进 DOM，由脚本取回（取法待定，hdc 侧通道 or 日志）
#   - 日志侧：hdc hilog 回读 CRAB-NAV / CRAB-DLG / CRAB-PERM / CRAB-ERR 四个前缀
#             （前缀取值在 pro 的 README 取值表，不在本仓另写）
#
# 最后更新：2026-09-17

set -euo pipefail

# 固定顺序的十六条。落地时逐个里程碑填判定，不许调整顺序、不许改 slug。
SLUGS_M2=(origin storage subresource intercept escape escape-encoded)
SLUGS_M3=(inject-order inject-scope)
SLUGS_M4=(nav-same-origin nav-back nav-cross-origin nav-blank
          nav-system-scheme nav-unknown-scheme dialog permission)

SLUGS=("${SLUGS_M2[@]}" "${SLUGS_M3[@]}" "${SLUGS_M4[@]}")

if [ "${1:-}" = "--list" ]; then
  printf '%s\n' "${SLUGS[@]}"
  exit 0
fi

# 判定桩。落地时把每条替换成真的判定，返回 `PASS` / `FAIL <原因>` / `MANUAL <说明>`。
probe_stub() {
  echo 'FAIL not-implemented'
}

failed=0
for slug in "${SLUGS[@]}"; do
  result="$(probe_stub "$slug")"
  echo "$slug $result"
  case "$result" in
    PASS*|MANUAL*) ;;
    *) failed=$((failed + 1)) ;;
  esac
done

if [ "$failed" -gt 0 ]; then
  echo "" >&2
  echo "$failed/${#SLUGS[@]} 条未通过。骨架阶段这就是预期：断言从 M2 起逐个里程碑填。" >&2
  exit 1
fi
