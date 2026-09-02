# 如何机器可读地拿到华为官方文档

最后更新：2026-09-01 ｜ 本页结论均在本机实测通过（2026-09-01）

## 结论摘要

- `developer.huawei.com/consumer/cn/doc/**` 是 Angular SPA，`curl` 拿到的 HTML 只有约 1.8 KB 外壳，正文为 0。WebFetch、搜索引擎快照同样读不到正文——**这是本项目最先要解决的障碍**。
- 正文由站点自己的 JSON 接口提供，可直接 POST 调用，无需登录、无需 Cookie。
- 已封装为 `tools/hwdoc.py`，支持取目录树与取正文。**这是本仓库所有鸿蒙事实的一手来源通道**，写 `docs/` 时优先用它，而不是搜索引擎。
- 接口是站点内部实现，非公开契约，华为随时可能改。失效时按下文「怎么重新反查」重做一遍即可。

## 接口

基址（中国站）：

```
https://svc-drcn.developer.huawei.com/community/servlet/consumer/cn/documentPortal
```

| 端点 | 入参 | 作用 |
| --- | --- | --- |
| `POST /getCatalogTree` | `{"catalogName":"harmonyos-guides","language":"cn","objectId":"root","showHide":"1"}` | 整棵目录树（开发指南全量约 1.2 MB JSON） |
| `POST /getDocumentById` | `{"objectId":"<文档 slug>","language":"cn"}` | 单篇文档，正文在 `value.content.content`（HTML 字符串） |
| `POST /getNavigationAddress` | `{"lang":"cn","catalogName":"harmonyos-guides"}` | 目录所属导航区，用于确认 catalogName 是否存在 |

要点：

- **`objectId` 传的就是 URL 末段的 slug**，不是树里的 `nodeId`。传 `nodeId` 会得到 `92531031 document not found`；这一点最容易踩。
- 目录树里每个节点的 `relateDocument` 字段就是该页的 slug，`nodeName` 是标题。
- `getCatalogTree` 的 `objectId` 只要非空即可（做长度校验但不做实际匹配），实测传 `"root"` 返回全树。`showHide` 必须是长度 1–2 的字符串枚举，传 `"1"`。
- 页面 URL 还原：`https://developer.huawei.com/consumer/cn/doc/<catalogName>/<slug>`。
- 已确认可用的 `catalogName`：`harmonyos-guides`（开发指南）、`harmonyos-references`（API 参考）、`harmonyos-releases`（版本说明/兼容性，2026-09-01 新探到）。用 `getNavigationAddress` 可以低成本试探某个 catalogName 是否存在。
- ⚠️ 未打通：`AppGallery-Connect` 目录的 `getCatalogTree` 返回空树，AGC 自有文档区不在此通道内。
- `getDocumentById` 返回的元信息里有 `version`（文档内部版本，如 `V233`）、`updatedDate`、`displayUpdateTime`、`versionLabels`（如 `["hmos-503"]`）、`anchorList`。**记录事实时应连带记下 `updatedDate`**，这是判断结论是否过期的依据。
- ❗️`versionLabels` **不是** HarmonyOS 版本标签。2026-09-01 交叉验证：对内容版本各异的 `overview-2600` / `overview-611` / `overview-500` / `development-intro-api` 等页面，返回值恒为 `hmos-503`，判定为站点常量。判断某页对应哪个版本，只能看正文与 `updatedDate`。
- `getCenterCatalogTree` / `getCenterDocument` 需要 `centerPrefix`，本机所有猜测值都返回「主仓不存在」，未打通，用不上。

## 用法

```bash
python3 tools/hwdoc.py tree harmonyos-guides            # 全量目录树
python3 tools/hwdoc.py tree harmonyos-guides AI         # 只看匹配节点及其子树
python3 tools/hwdoc.py tree harmonyos-references speech
python3 tools/hwdoc.py doc core-speech-introduction     # 正文（HTML→文本）
python3 tools/hwdoc.py meta core-speech-introduction    # 只看版本与锚点
```

## 怎么重新反查（脚本失效时）

1. `curl -sSL https://developer.huawei.com/consumer/cn/doc/ | grep -Eo 'src="[^"]*main[^"]*"'` 取主 bundle 名。
2. 下载该 `main.*.js`，`grep -oE '"/cn/documentPortal/[a-zA-Z]+"'` 列出全部端点。
3. `grep -oE 'ruleURL\(.{0,200}'` 看 URL 拼装规则（会在路径前补 `/consumer`，基址取自 `assets/const/official/env.*.js` 里的 `$siteConfig.cn.servletUrl`）。
4. **用空 body POST 探参数**：接口会把缺失字段和枚举约束原样报回来，例如
   `{"code":92511002,"message":"getDocumentById.req.objectId:must not be blank;..."}`。比读压缩后的 JS 快得多。

## 注意

- 只读官方公开文档，不涉及登录态、不提交任何数据，仅替代浏览器渲染。请求量保持克制。
- 接口无版本参数，返回的是文档中心当前线上版本。跨版本对比需另找「版本说明」类页面（`harmonyos-releases` 目录），不要指望 `versionLabels`——它是常量，见上。
