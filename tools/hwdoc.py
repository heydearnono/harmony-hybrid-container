#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""hwdoc.py — 抓取华为开发者文档中心（developer.huawei.com/consumer/cn/doc）的目录树与正文。

为什么需要它：文档中心是 Angular SPA，`curl` 拿到的只有 1.8KB 空壳，WebFetch/搜索引擎都读不到正文。
正文实际由站点自己的 JSON 接口提供（从 main.*.js 里的 `ruleURL("/cn/documentPortal/...")` 反查得到）：

    POST {SERVLET}/getCatalogTree   {"catalogName": "harmonyos-guides", "language": "cn",
                                     "objectId": "root", "showHide": "1"}
    POST {SERVLET}/getDocumentById  {"objectId": "<文档 slug>", "language": "cn"}

其中 objectId 传的就是 URL 末段的 slug（例如 core-speech-introduction 对应
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-speech-introduction）。

用法：
    tools/hwdoc.py tree harmonyos-guides                 # 打印整棵目录树（缩进 + slug）
    tools/hwdoc.py tree harmonyos-guides AI              # 只打印匹配节点及其子树
    tools/hwdoc.py doc core-speech-introduction          # 打印正文（HTML 转纯文本/markdown）
    tools/hwdoc.py meta core-speech-introduction         # 只看元信息（版本、更新日期、锚点）

已知 catalogName：harmonyos-guides（开发指南）、harmonyos-references（API 参考）。
注意：接口非公开契约，华为可能随时改动；脚本失效时回到 main.*.js 重新反查。
"""

import json
import re
import sys
import urllib.request
from html.parser import HTMLParser

SERVLET = ("https://svc-drcn.developer.huawei.com/community/servlet"
           "/consumer/cn/documentPortal")
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/126 Safari/537.36"


def post(endpoint, payload):
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        "%s/%s" % (SERVLET, endpoint), data=body, method="POST",
        headers={"Content-Type": "application/json", "User-Agent": UA,
                 "Origin": "https://developer.huawei.com",
                 "Referer": "https://developer.huawei.com/consumer/cn/doc/"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    if data.get("code") != 0:
        raise SystemExit("接口返回错误 %s: %s" % (data.get("code"), data.get("message")))
    return data["value"]


BLOCK = {"p", "div", "li", "tr", "h1", "h2", "h3", "h4", "h5", "h6",
         "pre", "table", "ul", "ol", "br", "section"}


class Html2Text(HTMLParser):
    """够用就好的 HTML→文本：标题转 markdown、列表加 -、表格行用 | 分隔、pre 包 ```。"""

    def __init__(self):
        HTMLParser.__init__(self)
        self.out = []
        self.in_pre = False
        self.skip = 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self.skip += 1
        elif tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.out.append("\n\n%s " % ("#" * int(tag[1])))
        elif tag == "li":
            self.out.append("\n- ")
        elif tag == "pre":
            self.in_pre = True
            self.out.append("\n```\n")
        elif tag in ("td", "th"):
            self.out.append(" | ")
        elif tag in BLOCK:
            self.out.append("\n")

    def handle_endtag(self, tag):
        if tag in ("script", "style"):
            self.skip = max(0, self.skip - 1)
        elif tag == "pre":
            self.in_pre = False
            self.out.append("\n```\n")
        elif tag in BLOCK:
            self.out.append("\n")

    def handle_data(self, data):
        if self.skip:
            return
        self.out.append(data if self.in_pre else re.sub(r"[ \t]*\n[ \t]*", " ", data))

    def text(self):
        s = "".join(self.out)
        s = re.sub(r"\[h[1-6]\]", "", s)  # 源文档里残留的层级标记，无意义
        s = re.sub(r"[ \t]+", " ", s)
        s = re.sub(r"\n{3,}", "\n\n", s)
        s = re.sub(r"\n +", "\n", s)
        return s.strip()


def walk(node, depth, lines):
    lines.append("%s%s  [%s]" % ("  " * depth, node.get("nodeName") or "?",
                                 node.get("relateDocument") or "-"))
    for child in node.get("children") or []:
        walk(child, depth + 1, lines)


def find(node, pattern):
    """返回所有 nodeName/slug 命中 pattern 的节点（命中后不再向下找，整棵子树一起给出）。"""
    hay = "%s %s" % (node.get("nodeName") or "", node.get("relateDocument") or "")
    if re.search(pattern, hay, re.I):
        return [node]
    hits = []
    for child in node.get("children") or []:
        hits.extend(find(child, pattern))
    return hits


def cmd_tree(catalog, pattern=None):
    value = post("getCatalogTree", {"catalogName": catalog, "language": "cn",
                                    "objectId": "root", "showHide": "1"})
    roots = value.get("catalogTreeList") or []
    lines = []
    if pattern:
        for root in roots:
            for hit in find(root, pattern):
                walk(hit, 0, lines)
    else:
        for root in roots:
            walk(root, 0, lines)
    print("\n".join(lines))


def doc_url(value, slug):
    catalog = value.get("catalogName") or "harmonyos-guides"
    return "https://developer.huawei.com/consumer/cn/doc/%s/%s" % (catalog, slug)


def cmd_doc(slug, meta_only=False):
    value = post("getDocumentById", {"objectId": slug, "language": "cn"})
    print("# %s" % value.get("title"))
    print("URL: %s" % doc_url(value, slug))
    print("version=%s  updated=%s  displayUpdateTime=%s  showBeta=%s"
          % (value.get("version"), value.get("updatedDate"),
             value.get("displayUpdateTime"), value.get("showBeta")))
    labels = value.get("versionLabels") or value.get("contentLabels")
    if labels:
        print("labels: %s" % json.dumps(labels, ensure_ascii=False))
    anchors = [a.get("title") for a in (value.get("anchorList") or [])]
    if anchors:
        print("anchors: %s" % " / ".join(x for x in anchors if x))
    if meta_only:
        return
    content = value.get("content")
    if isinstance(content, dict):
        content = content.get("content") or ""
    parser = Html2Text()
    parser.feed(content or "")
    print("\n" + parser.text())


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 1
    cmd, arg = argv[1], argv[2]
    if cmd == "tree":
        cmd_tree(arg, argv[3] if len(argv) > 3 else None)
    elif cmd == "doc":
        cmd_doc(arg)
    elif cmd == "meta":
        cmd_doc(arg, meta_only=True)
    else:
        print(__doc__)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
