# experiments — 动手验证区

一个实验一个目录：`NNN-短描述/`，例如 `001-ocr-离线识别可用性/`。

进入这里的前提是**有明确假设**。只是想看看某个 API 长什么样，属于调研，写进 `research-log/` 即可。

## 约定

- 每个实验目录必须有 `README.md`，从 `TEMPLATE.md` 复制。
- 实验结论无论正负都要写。「不通」和「通了」同等有价值，尤其要记录**为什么不通**。
- 结论稳定后，把可复用的部分提炼进 `docs/`，实验目录本身保留不动作为证据。
- 工具链现状（2026-09-03）：**编译已经能做了**。免登录的 OpenHarmony 链
  （hvigor + ohpm + Node 22 + SDK 23）装在 `~/.local/hmos-toolchain/clt-oh/`，`devecocli build` 实测通过。
  **`create` 不需要 SDK，`build` 需要**；HarmonyOS SDK 本体仍需人登录下载。
  现在的卡点变成了**没有设备/模拟器** —— 「装到设备上跑」类实验仍停在「设计 + 待执行」，如实标注即可。
- 区分三档验证强度，不要混用措辞：**未编译验证** < **已过 OpenHarmony API 23 编译** < **已运行验证**。
  编译通过只覆盖类型/签名层面的规则，运行期语义一律不算。

## 索引

| 编号 | 主题 | 状态 | 结论 |
| --- | --- | --- | --- |
| 001 | [DevEco CLI 能否脱离 DevEco Studio](001-deveco-cli-无IDE可行性/README.md) | 步 0–3 已执行，步 4/5 阻塞 | **部分成立**：CLI 在无 Studio 的 macOS 上可运行，CLT-only 是官方设计内路径（`DEVECO_CLI_CLT_PATH`）；2026-09-03 补充实测 —— **`create` 已跑通**（只需 `version.txt`，不碰 SDK），**`build` 也已跑通**（走免登录 OpenHarmony 链） |
| 002 | [混合容器最小基座能否在模拟器上跑通](002-混合容器最小基座/README.md) | 进行中：步 0–2 达成，步 3 起阻塞 | **假设成立到「能编译」，卡在「能跑」**：`BUILD SUCCESSFUL`，110,930 B HAP（OpenHarmony API 23）；W1 由编译器反向实验确认。步 3–8 缺设备/模拟器 |
