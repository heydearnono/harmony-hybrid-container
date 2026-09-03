// W6 探针：这个文件被 index.html 用 <script src="./js/probe.js"> 引用。
//
// 预期结果是**加载失败**——ArkWeb 内核禁止 file / resource 协议跨域，
// CORS 白名单只有 http, arkweb, data, chrome-extension, chrome, https, chrome-untrusted。
// 所以 $rawfile 加载的页面引用同目录下的外部脚本会被拦掉。
//
// 若页面上「W6 外部脚本」显示「已加载（与预期不符）」，说明 W6 需要改写。
window.__probeLoaded = true;
