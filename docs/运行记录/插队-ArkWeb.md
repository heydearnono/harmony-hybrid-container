# 运行记录 · 插队 spike：ArkWeb 起不起得来 ＋ `data:` iframe

- **跑的时间**：2026-10-08
- **在哪跑**：另一台 Mac（macOS 27.0 / arm64），检出在
  `/Users/wangjian/work/native-work/harmony-hybrid-container`，本仓 `576d9ac`（代码同 `c9ce790`），平台配置 `hos`
- **环境**：DevEco Studio 6.1.0（`DS-243.24978.46.36.610860`）；HarmonyOS SDK `6.1.0.105`（API 23）；
  模拟器镜像 HarmonyOS 6.1.0(23)，本机只下了这一档，镜像目录 `/Users/wangjian/Library/Huawei/Sdk`
- **按的是 `pro` 的 commit**：`5ddc786`
- **结论**：**ArkWeb 在模拟器上起得来**，页面加载完、`SPIKE done missing=0`，每一条都有答案

下面是原样输出，不重新叙述一遍。

## 构建

Studio「重新构建项目」（带 `clean`）：

```
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js clean --mode module -p product=default assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor Finished :entry:clean... after 40 ms 
> hvigor Finished :entry:default@PreBuild... after 107 ms 
> hvigor Finished :entry:default@CreateModuleInfo... after 1 ms 
> hvigor Finished :entry:default@GenerateMetadata... after 2 ms 
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor Finished :entry:default@MergeProfile... after 2 ms 
> hvigor Finished :entry:default@CreateBuildProfile... after 1 ms 
> hvigor Finished :entry:default@PreCheckSyscap... after 1 ms 
> hvigor Finished :entry:default@GeneratePkgContextInfo... after 2 ms 
> hvigor Finished :entry:default@GeneratePkgSdkInfo... after 1 ms 
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 1 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor Finished :entry:default@MakePackInfo... after 2 ms 
> hvigor Finished :entry:default@SyscapTransform... after 1 ms 
> hvigor Finished :entry:default@ProcessProfile... after 57 ms 
> hvigor Finished :entry:default@ProcessRouterMap... after 2 ms 
> hvigor Finished :entry:default@ProcessShareConfig... after 1 ms 
> hvigor Finished :entry:default@ProcessStartupConfig... after 1 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 1 ms 
> hvigor Finished :entry:default@ProcessResource... after 2 ms 
> hvigor Finished :entry:default@GenerateLoaderJson... after 3 ms 
> hvigor Finished :entry:default@ProcessLibs... after 2 ms 
> hvigor Finished :entry:default@CompileResource... after 94 ms 
> hvigor Finished :entry:default@DoNativeStrip... after 1 ms 
> hvigor Finished :entry:default@BuildJS... after 1 ms 
> hvigor Finished :entry:default@CacheNativeLibs... after 4 ms 
> hvigor Finished :entry:default@CompileArkTS... after 3 s 179 ms 
> hvigor Finished :entry:default@GeneratePkgModuleJson... after 2 ms 
> hvigor Finished :entry:default@ProcessCompiledResources... after 1 ms 
> hvigor Finished :entry:default@PackageHap... after 305 ms 
> hvigor Finished :entry:default@PackingCheck... after 2 ms 
> hvigor WARN: Will skip sign 'hos_hap'. No signingConfigs profile is configured in current project.
             If needed, configure the signingConfigs in /Users/wangjian/work/native-work/harmony-hybrid-container/harmony/Crab/build-profile.json5.
> hvigor Finished :entry:default@SignHap... after 1 ms 
> hvigor Finished :entry:default@CollectDebugSymbol... after 1 ms 
> hvigor Finished :entry:assembleHap... after 1 ms 
> hvigor BUILD SUCCESSFUL in 5 s 90 ms 

进程已结束，退出代码为 0
```

产物（M1 那一版是 22,596 B，多出来的是 `rawfile/spike/`）：

```
$ git log -1 --oneline
576d9ac .gitignore 补上 .appanalyzer/：DevEco Studio 打开工程时生成
$ ls -l harmony/Crab/entry/build/default/outputs/default/
-rw-r--r--@ 1 wangjian  staff  31631 10月  8 18:17 entry-default-unsigned.hap
drwxr-xr-x@ 3 wangjian  staff     96 10月  8 18:17 mapping
-rw-r--r--@ 1 wangjian  staff    603 10月  8 18:17 pack.info
```

## 日志（`CrabSpike`）

从 Studio 的 HiLog 面板按 tag `CrabSpike` 过滤后复制：

```
10-08 19:11:34.493   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     NATIVE attached
10-08 19:11:35.303   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     NATIVE page-begin resource://rawfile/spike/index.html
10-08 19:11:35.344   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE href resource://rawfile/spike/index.html
10-08 19:11:35.344   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE origin "resource://rawfile"
10-08 19:11:35.344   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE secure-context true
10-08 19:11:35.344   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE ua Mozilla/5.0 (Phone; OpenHarmony 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36  ArkWeb/6.1.0.115 Mobile
10-08 19:11:35.374   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE subresource-script executed
10-08 19:11:35.377   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     Fetch API cannot load resource://rawfile/spike/probe.txt. URL scheme "resource" is not supported.
10-08 19:11:35.392   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE subresource-fetch error TypeError: Failed to fetch
10-08 19:11:35.393   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE subresource-img loaded 1x1
10-08 19:11:35.403   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE iframe-data-onload fired
10-08 19:11:35.407   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE iframe-srcdoc-onload fired
10-08 19:11:35.410   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     NATIVE page-end resource://rawfile/spike/index.html
10-08 19:11:35.413   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE iframe-data message origin="null" event.origin="null" __CRAB__=undefined
10-08 19:11:35.413   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE iframe-srcdoc message origin="null" event.origin="null" __CRAB__=undefined
10-08 19:11:40.388   3127-3127     A00000/CrabSpike                net.xiaoluzhu.crab    I     SPIKE done missing=0
```

几处读法：

- 没有 `NATIVE error` / `http-error` / `render-exited`。`fetch` 那次失败不走 `onErrorReceive`，只在页面侧与控制台
  （`Fetch API cannot load …` 那一行，`onConsole` 转进来的）留痕
- UA 里 `Safari/537.36` 与 `ArkWeb/6.1.0.115` 之间是**两个空格**，日志原样如此；截图里是一个，那是 HTML 折叠了空白
- `done` 比 `page-end` 晚 5 秒，是页面里那个 5 秒兜底计时器到点，不是加载慢

## 屏幕上看到的

| 截图 | 看到什么 |
| --- | --- |
| [`插队-ArkWeb/1-spike页面.jpg`](插队-ArkWeb/1-spike页面.jpg) | 原生标题下 `Web` 组件把 spike 页加载出来，十二行 `SPIKE` 与日志一致，末行 `done missing=0`；左下红块是那张 1×1 图 |

## 没留下的

- **装法没留输出**：那一刻终端里的 `hdc list targets` 是 `[Empty]`，脚本的卸载 / 安装 / 启动全部
  `need connect-key`，屏幕上这一次是从 Studio 装上去的。M1 已证未签名 HAP 可直装，这里不影响结论
- **跑的是哪台模拟器没记下**（M1 用的是 Mate X7）。镜像档位只有 6.1.0(23) 一种，所以系统档位是确定的
- **命令行回读 hilog 这次没走通**：日志取自 Studio 的 HiLog 面板，`hdc shell hilog -x -T CrabSpike` 没跑成。
  M4「三端从命令行回读应用日志的路」鸿蒙那一格仍未成立
- 没测样式表与 `type="module"` 脚本；它们走 CORS 模式，按 `fetch` 的结果推断会被拦，未实测
