# experiments — 动手验证区

一个实验一个目录：`NNN-短描述/`，例如 `001-ocr-离线识别可用性/`。

进入这里的前提是**有明确假设**。只是想看看某个 API 长什么样，属于调研，写进 `research-log/` 即可。

## 约定

- 每个实验目录必须有 `README.md`，从 `TEMPLATE.md` 复制。
- 实验结论无论正负都要写。「不通」和「通了」同等有价值，尤其要记录**为什么不通**。
- 结论稳定后，把可复用的部分提炼进 `docs/`，实验目录本身保留不动作为证据。
- 工具链已就绪 2/3（DevEco CLI + JDK 21，见 `harmony/README.md`）。Command Line Tools 未到位前，
  需要 `create`/`build`/模拟器的实验只能停在「设计 + 待执行」，如实标注即可。

## 索引

| 编号 | 主题 | 状态 | 结论 |
| --- | --- | --- | --- |
| 001 | [DevEco CLI 能否脱离 DevEco Studio](001-deveco-cli-无IDE可行性/README.md) | 步 0–3 已执行，步 4/5 阻塞 | **部分成立**：CLI 在无 Studio 的 macOS 上可运行，CLT-only 是官方设计内路径（`DEVECO_CLI_CLT_PATH`）；`create`/`build` 出 HAP 未验，卡 CLT 下载需人工登录 |
| 002 | [混合容器最小基座能否在模拟器上跑通](002-混合容器最小基座/README.md) | 设计中，阻塞等 CLT | —— 前提是 ArkWeb **明确支持模拟器**，故 W1–W16 可实测（不同于只能真机验的 K1–K12）；W17–W27 另立实验 |
