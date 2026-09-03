# ArkTS 代码生成规则（给 AI 用的避坑清单）

最后更新：2026-09-03 ｜ 事实来源：华为官方文档（见文末来源表）｜ 代码片段的验证状态：**W1 已由 ArkTS 编译器实测确认**；其余落进 `harmony/HybridShell/` 的片段为「已过 OpenHarmony API 23 编译，未在 HarmonyOS SDK 上编译，未运行」；未落进工程的片段仍是**未编译验证**

## 怎么用这份清单

- 面向「让大模型写 ArkTS 少犯错」。每条规则给 ❌/✅ 最小示例与官方依据 slug。
- 官方 URL 拼法：`https://developer.huawei.com/consumer/cn/doc/<catalogName>/<slug>`，catalogName 见来源表。
- `arkts-no-*` 规则 ID 与五位错误码来自官方《从TypeScript到ArkTS的适配规则》，可直接写进 prompt 或 review 意见。该文档只有两级：**错误**（不遵从则编译失败）与**警告**（当前不影响编译，未来可能失败）。R1–R7 全部出自该文档。
- R8 起是 ArkUI / 工程配置层，官方无统一编号，依据为对应页面的「限制条件」「实现规则」小节。
- **K1–K12** 是调用端侧 AI Kit 时特有的坑，与语言规则分开列在「端侧 AI Kit 调用陷阱」一节。这些多数不会编译报错，而是运行时静默失效。
- **W1–W27** 是 ArkWeb / 混合容器（原生 + H5）的坑，列在「ArkWeb 混合容器陷阱」一节。混合容器是本项目当前主线，见 `docs/05-arkweb-hybrid-container.md`。
- 未标注 API Level 的按全版本适用理解（未逐条向官方确认下限，见「未确认」节）。

## 规则速查表

| 编号 | 规则 | 严重度 | 官方依据 slug |
| --- | --- | --- | --- |
| R1 | 禁用 `any` / `unknown`，`ESObject` 受限 | 编译错误 10605008 | typescript-to-arkts-migration-guide |
| R2 | 对象字面量、返回类型、泛型实参都要有显式类型 | 编译错误 10605038 等 | 同上 |
| R3 | 不支持 structural typing；对象布局运行时不可变 | 编译错误 10605030 / 10605029 等 | 同上 |
| R4 | 用箭头函数；禁函数内声明函数、禁解构、禁 `apply`/`call` | 编译错误 10605046 / 10605074 等 | 同上 |
| R5 | 类型检查不可关闭：无 `@ts-ignore`；`catch` 不标类型；只用 `as T` | 编译错误 10605146 等 | 同上 |
| R6 | 动态特性黑名单：`eval`、`Object` 反射方法、`Reflect`、`Proxy`、`Symbol()`、`for..in` | 编译错误 10605144 等 | 同上 |
| R7 | `import` 必须在其他语句之前；`.ts/.js` 不能 import `.ets` | 编译错误 10605150 / 10605147 | 同上 |
| R8 | ArkTS 导入路径用 `@kit.XxxKit`，`@ohos.*` 是模块名 / JS 写法 | 约定 | development-intro-api、js-apis-base |
| R9 | 组件骨架：`struct` + `@Entry`/`@Component` + 必须有 `build()`，不能继承 | 编译错误 | arkts-create-custom-components |
| R10 | `build()`：唯一根节点、禁本地变量 / `switch` / 三元 / 调非 `@Builder` 方法 / 改状态 | 编译错误、运行时异常 | arkts-create-custom-components |
| R11 | `@State` 须本地初始化；`@Prop` 单向深拷贝；`@Link` 双向且禁本地初始化 | 编译错误 / 告警 | arkts-state、arkts-prop、arkts-link |
| R12 | V2 装饰器只能在 `@ComponentV2` 内；同一 struct 不能双装饰 | 编译错误（API 12+） | arkts-new-local、arkts-new-param |
| R13 | `private`/`public`/`protected` 与装饰器初始化规则冲突会告警 | 编译告警（API 12+） | arkts-custom-components-access-restrictions |
| R14 | `@Builder` 内禁状态变量 / 生命周期；参数不能 `undefined`/`null`；不能改参数 | 编译错误 / 运行时错误 | arkts-builder |
| R15 | 事件回调用箭头函数，不用匿名函数 | 编译错误 | arkts-declarative-ui-description |
| R16 | 同一接口常有 callback 与 Promise 两个重载，二选一；`await` 只能在 `async` 内 | 编译错误 | async-concurrency-overview |
| R17 | `catch` 到的错误要 `as BusinessError` 才能取 `code`/`message` | 编译错误 | js-apis-base、errorcode-universal |
| R18 | `module.json5` 必填字段；新页面须登记到 `pages` 指向 profile 的 `src` | 构建失败 / 找不到页面 | module-configuration-file |
| R19 | 权限＝`module.json5` 声明 + 运行时 `requestPermissionsFromUser` | 授权失败 / 上架驳回 | declare-permissions、request-user-authorization |
| R20 | 模块级 `oh-package.json5` 的 `name`/`version` 必选 | 构建失败 | ide-oh-package-json5 |
| R21 | 资源用 `$r('app.type.name')` / `$rawfile('path')`，系统资源用 `sys.` | 取不到资源 | resource-categories-and-access |

## 详细规则

### R1 不要用 `any` / `unknown`
```ts
let x: any = 1;               // ❌ arkts-no-any-unknown 10605008
let y: number = 1;            // ✅
let s: string = null;          // ❌ 编译时报错
let s2: string | null = null;  // ✅
```
`ESObject` 只能用于与 TS/JS 互操作的局部变量，属警告级（`arkts-limited-esobj` 10605151）。

### R2 类型必须显式：对象字面量、返回类型、泛型实参
```ts
class Point { x: number = 0; y: number = 0 }
let p = { x: 1, y: 2 };                        // ❌ arkts-no-untyped-obj-literals 10605038
let q: (o: { x: number }) => void;             // ❌ arkts-no-obj-literals-as-types 10605040
let p2: Point = { x: 1, y: 2 };                // ✅ 标注提供上下文
function f(): Point { return { x: 1, y: 2 } }  // ✅ 返回类型提供上下文
```
返回类型不可省略（`arkts-no-implicit-return-types` 10605090）；泛型函数需显式标注类型实参（`arkts-no-inferred-generic-params` 10605034）。

### R3 没有 structural typing，对象布局也不可变
```ts
class A { n: number = 0 }
class B { n: number = 0 }
let a: A = new B();                  // ❌ arkts-no-structural-typing 10605030
console.info(p['x']);                // ❌ arkts-no-props-by-index 10605029，改写 p.x
delete (p as any).x;                 // ❌ arkts-no-delete 10605059
interface D { [k: string]: string }  // ❌ arkts-no-indexed-signatures 10605017
```
动态键值改用 `Map<string, T>`；`Record`/`Partial` 等工具类型被禁（`arkts-no-utility-types` 10605138）；原型赋值被禁（10605136）；类只能 `implements` 接口不能 `implements` 类（10605051）。

### R4 箭头函数，不嵌套声明，不解构
```ts
let f = function (s: string) { return s };  // ❌ arkts-no-func-expressions 10605046
let f2 = (s: string): string => s;         // ✅
function outer() { function inner() {} }   // ❌ arkts-no-nested-funcs 10605092
function g({ a, b }: Point) {}             // ❌ arkts-no-destruct-params 10605091
let [a, b] = [1, 2];                       // ❌ arkts-no-destruct-decls 10605074
foo.apply(this, [1, 2]);                   // ❌ arkts-no-func-apply-call 10605152
```
解构赋值同禁（10605069），逐字段取值。`bind`、`globalThis` 为警告级（10605140 / 10605137）；普通函数与静态方法内不能出现 `this`（10605093）；展开运算符仅部分支持（10605099）。

### R5 类型检查关不掉
```ts
// @ts-ignore                 ❌ arkts-strict-typing-required 10605146（@ts-nocheck 同禁）
try {} catch (e: Error) {}   // ❌ arkts-no-types-in-catch 10605079
try {} catch (e) {}          // ✅ 不标类型，用时再转（见 R17）
let n = <number>v;           // ❌ 尖括号断言不支持
let n2 = v as number;        // ✅ arkts-as-casts 10605053
let m = +'42';               // ❌ 编译时错误，改用 parseInt / Number()
```
`as const` 亦禁（10605142）。

### R6 动态特性 / 反射 API 黑名单
`arkts-limited-stdlib`（错误 10605144）逐项列出禁用：`eval`；`Object` 上的 `__proto__`、`__defineGetter__`、`__defineSetter__`、`__lookupGetter__`、`__lookupSetter__`、`assign`、`create`、`defineProperties`、`defineProperty`、`freeze`、`fromEntries`、`getOwnPropertyDescriptor(s)`、`getOwnPropertySymbols`、`getPrototypeOf`、`hasOwnProperty`、`is`、`isExtensible`、`isFrozen`、`isPrototypeOf`、`isSealed`、`preventExtensions`、`propertyIsEnumerable`、`seal`、`setPrototypeOf`；`Reflect` 全部方法；`Proxy` 全部 handler。此外 `Symbol()`（10605002）、`for..in`（10605080）、`in` 运算符（10605066）均为错误级——遍历改用 `Map`/`Array` + `for..of`。

### R7 import 的位置与方向
```ts
let x = 1;
import { hilog } from '@kit.PerformanceAnalysisKit'; // ❌ arkts-no-misplaced-imports 10605150
const m = require('m');                              // ❌ arkts-no-require 10605121
export = MyClass;                                    // ❌ arkts-no-export-assignment 10605126
```
`.ets` 可 import `.ets`/`.ts`/`.js` 源码，反之 `.ts`/`.js` **不允许** import `.ets`（`arkts-no-ts-deps` 10605147）。`var` 亦禁（10605005）。

### R8 导入路径：ArkTS 用 `@kit.XxxKit`
API 参考页标题是模块名（`@ohos.base`），页面「导入模块」小节给的才是应写入代码的路径。`js-apis-base` 把两者并列：
```ts
// 官方「ArkTS示例」
import { AsyncCallback, BusinessError, Callback, ErrorCallback } from '@kit.BasicServicesKit';
// 官方「JS示例」
import base from '@ohos.base';
```
已逐页核对的归属：`@kit.AbilityKit`（`abilityAccessCtrl`、`bundleManager`、`Permissions`、`common`、`UIAbility`）；`@kit.BasicServicesKit`（`BusinessError`、`AsyncCallback`、`Callback`、`ErrorCallback`）；`@kit.ArkUI`（`window`、`router`）；`@kit.PerformanceAnalysisKit`（`hilog`）；`@kit.NetworkKit`（`http`）；`@kit.ArkData`（`preferences`）。依据：`development-intro-api`（「SDK 对同一个 Kit 下的接口模块进行了封装……可通过导入 Kit 的方式来使用」）+ 各参考页「导入模块」小节。⚠️ 「所有 Kit 是否都走 `@kit.*`」「`@ohos.*` 在 ArkTS 中是否仍有效」未获总纲页确认，见末节。

### R9 自定义组件骨架
```ts
@Entry        // 页面入口，一个页面仅一个；API 9+ 卡片，API 10+ 可传 EntryOptions
@Component    // V1；V2 用 @ComponentV2（API 12+），两者不能装饰同一 struct
struct Index {
  build() { Column() { Text('hi') } }   // build() 必须有
}
```
自定义组件是 `struct`，**不能有继承关系**，创建时可省略 `new`，名字不能与系统组件同名。V1 组件不支持静态代码块（静默失效，API 22+ 给告警），`@ComponentV2` 支持。依据：`arkts-create-custom-components`。

### R10 `build()` 的实现规则
```ts
build() {
  let n = this.count;        // ❌ 禁止本地变量声明
  Column() {
    Text(this.f ? 'a' : 'b') // ❌ 禁止三元，改 if/else
    Text(`${this.count++}`)  // ❌ 禁止改状态变量（运行时异常）
    switch (this.t) { }      // ❌ 禁止 switch
    this.plainMethod()       // ❌ 禁止调用非 @Builder 成员方法
    Text(this.plainMethod()) // ✅ 但其返回值可作参数
  }
}
```
根节点唯一且必需；`@Entry` 的根节点必须是容器组件且不能是 `ForEach`；不允许 `{}` 本地作用域；UI 描述里不能直接写 `console.info`。「禁止改状态变量」同样适用 `@Builder`/`@Extend`/`@Styles`。依据：`arkts-create-custom-components`。

### R11 V1 状态装饰器：`@State` / `@Prop` / `@Link`
```ts
@Component
struct Child {
  @State count: number = 0;  // ✅ 必须本地初始化（@State count: number; 是编译错误）
  @Prop msg: string = '';    // ✅ 父→子单向，深拷贝
  @Link n: number;           // ✅ 双向；写 @Link n: number = 10 是编译错误
}
Child({ msg: this.text, n: $num })  // ✅ API 9+ 也可写 n: this.num
```
- 三者都不能装饰 `Function` 类型（API 23+ 编译错误）；父组件传 `undefined` 时保留本地默认值。
- `@State` 支持 `Date`（API 10+）、`Map`/`Set`/`undefined`/`null`/联合类型（API 11+）。
- `@Prop` 深拷贝只保留基础类型、`Map`/`Set`/`Date`/`Array`，`PixelMap`、`RegExp` 会失效。
- `@Link` 必须由父组件的状态变量初始化，类型不匹配在 API 23+ 从运行时报错升为编译错误；不建议用于 `@Entry` 组件（告警，若该组件为页面根节点则运行时报错）。

依据：`arkts-state`、`arkts-prop`、`arkts-link`。

### R12 V1 与 V2 装饰器不能混用
V2（`@ComponentV2` + `@Local`/`@Param`/`@Once`/`@Event`/`@Provider`/`@Consumer`/`@Monitor`/`@Computed`）自 **API version 12** 起可用。
```ts
@ComponentV2
struct Child {
  @Local msg: string = 'hi';   // ✅ 必须本地初始化，且不能由外部传入
  @Param title: string = '';   // ✅ 单向传入；无默认值时必须配 @Require
  @Param p: string;            // ❌ 无默认值又无 @Require → 编译错误
}
@Component
struct Wrong { @Local x: number = 0 }   // ❌ @Local 只能在 @ComponentV2 内
```
`@Param` 不能在子组件内改写（回写用 `@Event`，需首次同步后可改用 `@Once`）。混用约束自 **API 19** 放宽（新增 `UIUtils.makeV1Observed`、`enableV2Compatibility`），但 V1 装饰器仍不能与 `@ObservedV2` 类组合。状态管理**仅支持 UI 主线程**，Worker / TaskPool 内不可用。依据：`arkts-new-local`、`arkts-new-param`、`arkts-state-management-overview`、`arkts-v1-v2-mixusage`、`arkts-decorator-overview`。

### R13 访问限定符会和装饰器的初始化规则冲突
API version 12 起编译期校验，违反给**告警**：

| 写法 | 结果 |
| --- | --- |
| `private` 修饰 `@State`/`@Prop`/`@Provide`/`@BuilderParam`/普通变量 | 禁止外部初始化，父组件传值即告警 |
| `public` 修饰 `@StorageLink`/`@StorageProp`/`@LocalStorageLink`/`@LocalStorageProp`/`@Consume` | 告警（本就不支持父传） |
| `private` 修饰 `@Link`/`@ObjectLink` | 告警（必须由外部初始化） |
| `protected` 修饰任何成员 | 告警（struct 无继承） |
| `@Require` + `private` | 语义矛盾，告警 |

依据：`arkts-custom-components-access-restrictions`。

### R14 `@Builder` 的限制
```ts
@Builder function itemRow(text: string) { Row() { Text(text) } }  // ✅ 全局
@Builder myRow(o: Wrapped) {
  // @State s: number = 0;  ❌ 不能定义状态变量
  // aboutToAppear() {}     ❌ 不能定义生命周期
  // o.text = 'x'           ❌ 不能改参数（运行时错误，API 23+ 错误码 140109）
  Text(o.text)
}
```
参数类型不能是 `undefined`/`null`。「按引用传递」（可触发刷新）只在**恰好传入一个对象字面量参数**时成立；≥2 个参数或值引用混用会退化为按值传递、失去动态刷新，API 20+ 可用 `UIUtils.makeBinding()` / `Binding` / `MutableBinding` 恢复。`@Builder` 自 API 7 起（API 9 卡片、API 11 元服务）。依据：`arkts-builder`。

### R15 事件回调必须是箭头函数
```ts
Button('ok').onClick(function () { this.x = 1 })  // ❌ 不允许匿名函数
Button('ok').onClick(this.handler.bind(this))     // 官方标注「不建议」
Button('ok').onClick(() => { this.x = 1 })        // ✅
```
官方原文：箭头函数内部的 `this` 是词法作用域，匿名函数可能出现 `this` 指向不明确的问题，因此在 ArkTS 中不允许使用。组件创建不写 `new`，属性方法链式调用、建议每行一个。依据：`arkts-declarative-ui-description`。

### R16 callback 与 Promise 两个重载，别混着写
```ts
// Promise 形式
atManager.requestPermissionsFromUser(context, permissions)
  .then((data) => { /* data.authResults */ })
  .catch((err: BusinessError) => { console.error(err.message) });
// callback 形式（同一接口自 API 9 起两种签名并存）
atManager.requestPermissionsFromUser(context, permissions, (err, data) => { });
```
`await` 只能出现在 `async` 函数内；`async` 函数返回 `Promise`。未处理的 reject 可用 `errorManager.on('globalUnhandledRejectionDetected')` 全局捕获。依据：`async-concurrency-overview`、`js-apis-abilityaccessctrl`。

### R17 取错误码要先 `as BusinessError`
`catch` 参数不能标类型（R5），必须转换后才能访问 `code`/`message`。
```ts
import { BusinessError } from '@kit.BasicServicesKit';   // API 6+，卡片 API 12+
try {
  await bundleManager.getBundleInfoForSelf(flag);
} catch (error) {
  const err: BusinessError = error as BusinessError;     // ✅
  console.error(`code: ${err.code}, message: ${err.message}`);
}
```
`BusinessError<T = void> extends Error { code: number; data?: T }`；`AsyncCallback<T, E = void>` 的 `err` 在成功时为 `null`。通用错误码：201 权限校验失败、202 非系统应用调用系统 API、203 企业设备管控、401 参数校验失败、801 设备不支持、804 模拟器不支持。依据：`js-apis-base`、`errorcode-universal`。

### R18 `module.json5` 必填字段与页面登记
路径 `工程名/模块名/src/main/module.json5`。
```json5
{ "module": {
  "name": "entry",                     // 不可缺省
  "type": "entry",                     // 不可缺省：entry/feature/har/shared/skill
  "deviceTypes": ["phone", "tablet"],  // 不可缺省
  "deliveryWithInstall": true,         // HAP/HSP 场景不可缺省
  "pages": "$profile:main_pages",      // 指向 resources/base/profile/main_pages.json
  "abilities": [{
    "name": "EntryAbility",                            // 不可缺省
    "srcEntry": "./ets/entryability/EntryAbility.ets"  // 不可缺省
  }]
} }
```
pages profile 里的 `src` 数组不可缺省，路径相对模块的 `src/main/ets`：`{ "src": ["pages/Index", "pages/Detail"] }`——只建 `.ets` 不登记则运行时找不到页面。`launchType` 缺省 `singleton`，`exported` 缺省 `false`，`window.designWidth` 缺省 720px；`type: "skill"` 自 API 26.0.0 起且仅预置应用可用。依据：`module-configuration-file`。

### R19 权限＝配置声明 + 运行时申请
```json5
// module.json5：user_grant / manual_settings 权限的 reason 与 usedScene 必填
"requestPermissions": [{
  "name": "ohos.permission.APPROXIMATELY_LOCATION",
  "reason": "$string:location_permission_reason",  // string.json 需有同名条目
  "usedScene": { "abilities": ["EntryAbility"], "when": "inuse" }  // when∈{inuse,always}
}]
```
```ts
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
const atManager = abilityAccessCtrl.createAtManager();
const context = this.getUIContext().getHostContext() as common.UIAbilityContext;  // UI 内取
atManager.requestPermissionsFromUser(context, permissions).then((data) => { });
```
每次访问受保护接口前都要重新校验（`checkAccessToken(tokenId, permission)`），**不能持久化授权状态**；在 `onWindowStageCreate()` 中申请必须等 `loadContent()`/`setUIContent()` 结束或写在其回调里；entry 已声明的权限不需在 feature 重复声明；用户拒绝后不再弹窗，需引导设置或调 `requestPermissionOnSetting()`。依据：`declare-permissions`、`request-user-authorization`。

### R20 `oh-package.json5` 分工程级与模块级
自 OHPM 5.0.0 起拆两层：工程级 `modelVersion` 必选；模块级 `name`、`version` 必选。
```json5
{
  "name": "entry",       // 小写字母开头，@group/pkg 或 pkg，不能是 ArkTS 保留字
  "version": "1.0.0",    // 必须 X.Y.Z
  "dependencies": { "@ohos/library": "^1.0.1", "mylib": "file:../mylib" }
}
```
依赖形式：`"1.0.0"`、`"^1.0.1"`、`"tag:beta"`、`"file:./xx.har"`、`"file:../module1"`、`"@module:Foo"`（DevEco 6.0.0 Beta1+）；另有 `devDependencies`、`dynamicDependencies`。依据：`ide-oh-package-json5`。

### R21 资源引用语法
```ts
Text($r('app.string.title'))              // ✅ app.<type>.<name>
Text($r('app.string.label', 'aaa', 444))  // ✅ 占位符替换
Image($r('sys.media.ohos_app_icon'))      // ✅ 系统资源用 sys.
Image($rawfile('images/logo.png'))        // ✅ 带扩展名、相对路径
Image($rawfile('/images/logo.png'))       // ❌ 不能以 / 开头
```
`app.` 支持 `color`/`float`/`string`/`plural`/`media`/`profile`；`sys.` 支持 `color`/`float`/`string`/`media`/`symbol`。跨 HSP 用 `$r('[hsp].type.name')` / `$rawfile('[hsp].dir/file.png')`（**编译期不校验**）。资源 ID 重新编译后会变，不要缓存；`rawfile`/`resfile` 不参与限定词匹配。依据：`resource-categories-and-access`。

## 端侧 AI Kit 调用陷阱（K1–K12）

R1–R21 是语言与工程层面的规则，本节是**调用端侧 AI 能力时特有的坑**，来自本轮 10 个 Kit 的逐页研读。
与上面不同，这些错误多数**不会编译失败**，而是运行时静默失效或行为与直觉相反——对 AI 生成代码尤其危险。

逐条事实的官方 slug、文档 version 与访问日期见对应的 `docs/ai-kit/*.md` 文末来源表。

| 编号 | 陷阱 | 表现 | 依据 |
| --- | --- | --- | --- |
| K1 | `@kit.CoreSpeechKit` 与 `@kit.SpeechKit` 是**两个不同的 Kit** | 导入错 Kit 找不到符号 | [core-speech-kit.md](ai-kit/core-speech-kit.md) · [scenario-kits.md](ai-kit/scenario-kits.md) |
| K2 | 语音识别参数 `online: 1` 的语义是**离线** | 逻辑写反且无报错 | [core-speech-kit.md](ai-kit/core-speech-kit.md) |
| K3 | `writeAudio` 只接受 **640 / 1280 字节**的 `Uint8Array`，且须按 **20 / 40 ms** 固定间隔送 | 识别不出结果 | 同上 |
| K4 | 不调 `setListener` 就调用识别/合成 → **静默失败**，回调一个都不来 | 无任何输出、无异常 | 同上 |
| K5 | TTS 实例上限 3 个，是**设备级、跨应用共享**的配额 | 别的应用占满时本应用创建失败 | 同上 |
| K6 | Core Vision 存在**两套互不兼容的 API 风格** | 混写必错，见下方说明 | [core-vision-kit.md](ai-kit/core-vision-kit.md) |
| K7 | 同一进程内**并发调用同一视觉能力**返回系统繁忙——不能 `Promise.all` | 运行时错误 | 同上 |
| K8 | `textSearchImage` 入参是**沙箱路径**，不是 `PixelMap` | 参数类型错 | 同上 |
| K9 | 人脸活体检测 / 卡证识别 / 文档扫描 / AI 识图 属 **Vision Kit**（非 Core Vision Kit）；二维码两者都没有 | 找错 Kit | [core-vision-kit.md](ai-kit/core-vision-kit.md) · [scenario-kits.md](ai-kit/scenario-kits.md) |
| K10 | **不存在「Core Natural Language Kit」**：Natural Language Kit 本身就是无 UI 的原子 API | 凭对称性臆造 Kit 名 | [scenario-kits.md](ai-kit/scenario-kits.md) |
| K11 | `CardRecognition` 的 `callback` 参数自 **5.1.1(19)** 起废弃，改用 `onResult` | 用到已废弃参数 | 同上 |
| K12 | ⏳ Vision Kit 动作活体检测、卡证识别**试用期免费至 2026-12-31** | 时效信息，之后计费口径需重新核实 | 同上 |

### K6 展开：Core Vision 的两套 API 风格

同一个 Kit 里两种风格并存，且**都不能 `new`**（构造函数私有），是 AI 最容易写串的地方：

| | 风格 A（模块级） | 风格 B（Analyzer 级） |
| --- | --- | --- |
| 生命周期 | 模块 `init()` → 调用 → `release()` | `XxxAnalyzer.create()` → `process()` → `destroy()` |
| 入参类型 | 与能力同名的 `VisionInfo { pixelMap }` | `visionBase.Request { inputData }` |
| 注意 | 每个能力有**自己的**同名 `VisionInfo` 类型 | `create()` 是静态工厂，不能 `new XxxAnalyzer()` |

### 端侧属性这件事要特别小心

⚠️ Core Vision Kit 的 8 项能力，官方 16 篇正文**从未出现「端侧」「离线」或「需联网」任一表述**。因此不要在生成的代码注释或文档里宣称它们是端侧能力——那是本项目此前自己加的假设，已在 `docs/02-ondevice-ai-map.md` 改标 `⚠️ 未确认`。明确标注了离线的只有 Core Speech Kit 的语音识别（官方原文「语音识别支持的模型类型：离线」）。

## ArkWeb 混合容器陷阱（W1–W27）

访问日期 2026-09-02（W1–W16）与 2026-09-03（W17–W27）。
W1–W8 来自 `harmonyos-guides` 的指南页，W9–W16 来自 `harmonyos-references`
的 `@ohos.web.webview` API 参考页，**W17–W27 来自同层渲染 / 渲染模式 / 离线组件 / 进程模型四组指南页**。
细节与代码见 `docs/05-arkweb-hybrid-container.md`。
这一组的共同特征：**多数不报编译错，只是收不到消息、加载不出资源，或者白屏。**

| 编号 | 陷阱 | 表现 | 依据 slug |
| --- | --- | --- | --- |
| W1 | 消息端口两侧方法名**不对称**：ArkTS 侧是 `onMessageEvent` / `postMessageEvent`，H5 侧才是 `onmessage` / `postMessage` | 在 ArkTS 侧写 `port.postMessage()` —— **✅ 2026-09-03 实测：编译期直接报错** `10505001 Property 'postMessage' does not exist on type 'WebMessagePort'`（不是静默无效） | web-app-page-data-channel |
| W2 | 同一份代码里有两个 `postMessage` 语义：`controller.postMessage(name, ports, uri)` 是**把端口送给 H5**，`port.postMessageEvent(data)` 才是**发数据** | 混用后通道建不起来，无报错 | 同上 |
| W3 | `WebMessage` 只支持 `string` 与 `ArrayBuffer`，**传对象必须 `JSON.stringify`**。注意这只是**基础协议**的限制——扩展协议 `postMessageEventExt` / `onMessageEventExt`（API 10+，载体 `WebMessageExt`）支持更丰富的数据类型 | 「H5 发消息应用侧收不到」，官方 FAQ 把这个列为第一原因 | 同上 · arkts-apis-webview-webmessageport |
| W4 | `registerJavaScriptProxy()` 注册后**不会立即生效**，要等下次加载或显式 `refresh()` | 注册完马上调，前端报对象未定义 | web-in-page-app-function-invoking |
| W5 | `javaScriptProxy` / `registerJavaScriptProxy` **必须配 `deleteJavaScriptRegister()`**，官方明写否则内存泄漏 | 泄漏，不报错 | 同上 |
| W6 | ArkWeb 内核**禁止 `file` / `resource` 协议跨域**。CORS 白名单只有 `http, arkweb, data, chrome-extension, chrome, https, chrome-untrusted` | `$rawfile` 加载的 index.html 里引用的 js/css 全部被 CORS 拦掉 | web-cross-origin |
| W7 | `setPathAllowingUniversalAccess()` 一旦设置，**`file` 协议就只能访问列表内资源**，`fileAccess` 行为被覆盖；路径含 `cache/web` 抛 **401**，任一路径不合规则整个列表设置失败 | 本来能读的本地文件读不到了；或直接 401 | 同上 |
| W8 | 拦截有两套机制且能力不同：`onInterceptRequest` **拿不到 Post Data**；`SchemeHandler` 能拿到、还能覆盖 ServiceWorker，但**必须在请求结束回调里清理资源**否则泄漏 | 用 `onInterceptRequest` 做 POST 转发，永远拿不到请求体 | web-scheme-handler |
| W9 | **`postMessageEvent` 之前必须先调用 `onMessageEvent`**，否则发送失败（Ext 协议同理：先 `onMessageEventExt`） | 抛 17100010 `Failed to post messages through the port` | arkts-apis-webview-webmessageport |
| W10 | **前端页面传到应用侧的 `string` 会被视为 JSON 格式数据，需要 `JSON.parse` 反序列化** | 直接当普通字符串用，拿到的是带引号的 JSON 文本 | arkts-apis-webview-webviewcontroller（`runJavaScript` / `runJavaScriptExt` 都写了） |
| W11 | **`runJavaScriptExt` 必须在 `loadUrl` 完成后调用**，官方指明比如放在 `onPageEnd` 里 | 页面没加载完就调，无效 | 同上 |
| W12 | `registerJavaScriptProxy` 的**同步与异步方法列表不可同时为空**，否则注册失败；**同一方法在两个列表里重复注册会默认走异步**；异步方法**无法返回值且执行顺序不保证** | 注册静默失败；或以为同步却拿不到返回值 | 同上 |
| W13 | 注册的对象会**暴露给页面所有 frames**。官方要求「尽可能只在可信 URL 及 HTTPS 场景下注册」，否则可能被恶意攻击 | 加载三方页面时把原生能力整个敞开 | 同上 |
| W14 | **跨导航（如 `loadUrl`）后 `runJavaScript` 注入的 JavaScript 状态不再保留**（导航前定义的全局变量和函数都不存在）。要跨页面保持状态，官方建议改用 `registerJavaScriptProxy` | 跳页后前端报函数未定义 | 同上 |
| W15 | `WebviewController` 的方法必须在 controller **已绑定到 `Web` 组件之后**才能调 | 抛 17100001 `The WebviewController must be associated with a Web component.` | 同上 |
| W16 | `setWebDebuggingAccess(true)` 官方带**安全提示：不建议在正式发布版本中启用**。带 `port` 的无线调试重载是 API 20+，且 `port` 必须 **> 1024** | 调试开关误留到发布版；或 port ≤ 1024 抛异常 | 同上 |
| W17 | 同层渲染**必须显式** `enableNativeEmbedMode(true)`（默认关闭）。`<embed>` 的 `type` 要以 `native/` 开头；用 `<object>` 必须先 `registerNativeEmbedRule('object', '<type前缀>')` | 页面显示「该插件不支持」 | web-same-layer |
| W18 | 同层标签的三条硬禁：**不能**把 W3C 标准标签（`<input>`、`<video>`）定义为同层标签；**不能同时**把 `<embed>` 与 `<object>` 都配成同层标签；`registerNativeEmbedRule` 的类型若与 W3C 标准类型重合（官方举例 `("object", "application/pdf")`），ArkWeb **走 W3C 标准行为**不识别为同层标签 | 标签不被识别，静默按普通标签渲染 | 同上 |
| W19 | **开启同层渲染后，该 `Web` 组件打开的所有页面都不支持 `RenderMode.SYNC_RENDER`** | 「同层渲染」与「超长页面同步渲染」不可兼得，二选一 | 同上 |
| W20 | 渲染模式的高度上限：默认 `ASYNC_RENDER` 下 `Web` 组件高度**超过 7,680px 物理像素会白屏**；`SYNC_RENDER` 上限 500,000px。**两者都不支持动态切换** | 长页面白屏，且没法运行时改模式救回来 | web-render-mode |
| W21 | 同层标签受 GPU 限制**最大高度 / 最大纹理 8,000px**；自定义同层组件**最外层容器宽高必须等于同层标签宽高**；每页同层标签**≤ 5 个** | 组件被拉伸；或渲染性能下降 | web-same-layer |
| W22 | 交互型 ArkUI 同层组件（`TextInput`/`TextArea` 等）必须用 **`Stack` 包裹**同层组件容器与 `BuilderNode`，且 `NodeContainer` 的 `position`/`width`/`height` 与同层标签绑定 | 光标与文本选择框错位；`LoadingProgress`/`Marquee` 动画启停与可见状态不匹配 | 同上（含官方对比图与 FAQ） |
| W23 | 同层标签**只支持有限 CSS 子集**，`transform` 仅支持 `translate` / `scale`（scale 参数须 ≥ 0），`rotate`、`skew` 不保证；有同层标签的页面**不支持缩放**（`initialScale`、`zoom`、`zoomIn`、`zoomOut` 均不支持）；鼠标/键盘/触摸板事件暂不上报 | 写了 rotate 没效果或表现异常；调缩放接口无效 | 同上 |
| W24 | **「离线 Web 组件」不是「离线包」**，指用 `NodeContainer` + `NodeController` + `BuilderNode` 离屏预创建、暂不挂树（状态 Hidden + Inactive）的 Web 组件。另：**每个 `Web` 组件约占 200MB 内存**，官方建议**每窗口只用一个** | 按字面理解去找离线资源打包能力，方向错；或一次创建多个组件导致内存被系统终止 | web-offline-mode |
| W25 | 预渲染必须 `onPageBegin` → `onActive()` 开启、`onFirstMeaningfulPaint` → `onInactive()` **立刻停止**，否则后台持续渲染造成**发热与功耗**。⚠️ `onFirstMeaningfulPaint` **只适用 http/https 页面**（本地 `$rawfile` 场景不可用）；不要预渲染自动播放音视频的页面 | 后台一直烧电；或本地页面拿不到停止时机 | 同上 |
| W26 | 释放离线 Web 组件**必须先确认未被 `NodeContainer` 绑定**（用 `NodeController` 的 `onBind`/`onUnbind` 跟踪），否则对应 `NodeContainer` **白屏**。复用前要先 `loadUrl('about:blank')` | 强制释放已绑定组件 → 白屏 | 同上 |
| W27 | 渲染进程**只有在所有 `Web` 组件都销毁后才终止**，故「预启动渲染进程」只在单渲染进程模式下收益显著（**移动设备默认单进程，2in1 默认多进程**）。⚠️ `setRenderProcessMode` 传入不在 `RenderProcessMode` 枚举范围的值 → **自动按多进程处理**，不是回落单进程；`terminateRenderProcess()` 会影响**共享该进程的所有实例**；共享进程时 `onRenderExited` 在**每个受影响组件上各触发一次** | 以为省了内存实际开了多进程；或关进程连带打挂别的 Web 实例 | web_component_process |

另外两条不是陷阱但会影响架构选择，记在这里备查：

- **元服务不能用 `Web` 组件。** 应用用 ArkWeb 的 `Web`；元服务内嵌网页要用 **ASCF Webview** 或
  **AtomicServiceEnhancedWeb**（`web-component-overview`）。⚠️ 这两个组件待核实。
- **要判断某个 Web 特性能不能用，查 Chromium 版本而不是鸿蒙版本。** 6.1 = M132，7.0 = M144（默认）。
  按现网分布，实际主力内核是 **M132**。

### 时序：一条官方确认的执行顺序

**`javaScriptOnDocumentStart` 在 `onControllerAttached` 之后执行**（`web-app-page-data-channel` FAQ）。
需要「页面脚本执行前注入」的逻辑要放对位置。

## 经验性规则（⚠️ 无官方依据，待核实）

- ⚠️ 让模型先写数据模型（`class`/`interface`）再写 `build()`，可减少 R2 类错误 —— 无官方依据。
- ⚠️ 新项目一律用 V2 范式。官方只说「对于新开发的应用，建议直接使用 V2 版本范式」（`arkts-state-management-overview`），「一律」是本项目的推断。
- ⚠️ 页面跳转优先 `Navigation`。官方依据仅到「`@ohos.router` 标注为不推荐、推荐使用 Navigation 组件」（`js-apis-router`、`arkts-router-to-navigation`），未见强制要求。

## 常见幻觉清单

只列**能确认「官方文档中检索不到」**的项，不断言其不存在。核实方式为用 `python3 tools/hwdoc.py tree/doc` 全量导出目录树与正文后本地检索（2026-09-01 执行）。

| AI 常写的东西 | 实际情况 | 核实方式 |
| --- | --- | --- |
| `View` / `Container` / `TextView` / `ScrollView` / `StackView` 等组件 | 未在官方组件参考树中检索到。容器实为 `Column`/`Row`/`Flex`/`Stack`/`List`/`Grid`，基础组件为 `Text`/`Button`/`Divider` 等 | 全量导出 `harmonyos-references` 目录树后检索组件节点 |
| `AppStorage.Get()` / `AppStorage.SetOrCreate()`（首字母大写） | 未检索到大写形式。`arkts-appstorage` 给出的是 `AppStorage.setOrCreate()`、`AppStorage.get<T>()`、`AppStorage.link()`、`AppStorage.prop()` | 读 `arkts-appstorage` |
| `import router from '@ohos.router'` 且当作推荐路由方案 | 页面标题已带「(不推荐)」，方法逐个 deprecated，官方推荐 `Navigation`；ArkTS 导入应为 `import { router } from '@kit.ArkUI'` | 读 `js-apis-router`、`arkts-routing` |
| `Record<string, T>` / `Partial<T>` 等 TS 工具类型 | 官方明确禁止：`arkts-no-utility-types`（错误 10605138） | 读 `typescript-to-arkts-migration-guide` |
| `Object.assign(...)` 拷贝对象 | 在 `arkts-limited-stdlib` 禁用清单内（错误 10605144） | 同上 |
| `struct` 组件用 `extends` 复用 | 官方明确「自定义组件不能有继承关系」 | 读 `arkts-create-custom-components` |
| 在 `Worker` / `TaskPool` 里读写 `@State` | 官方明确「状态管理仅支持在 UI 主线程使用」 | 读 `arkts-state-management-overview` |
| `Core Natural Language Kit` 这个 Kit 名 | 目录树里只有 `Natural Language Kit`，无 `Core` 前缀版本（见 K10） | 全量导出 `harmonyos-guides` 的 AI 节点 |
| `new SpeechRecognizer(...)` / `new XxxAnalyzer(...)` | 构造函数私有，须用工厂方法（见 K6） | 读 `docs/ai-kit/core-vision-kit.md` 引用的官方页 |
| 二维码识别归 Core Vision Kit 或 Vision Kit | 两个 Kit 的能力清单里都没有二维码（见 K9） | 逐页读两个 Kit 的能力页 |

## 未确认 / 待核实

- ⚠️ **导入约定的总纲页没找到**。`development-intro-api` 提到「导入 Kit 的方式请参见导入-导入HarmonyOS SDK的开放能力」，但该页在 `harmonyos-guides`、`harmonyos-references` 两棵目录树中均未检索到（试过 `import-sdk`、`sdk-import`、`import-capabilities`、`development-intro-import`、`kit-import`，均返回 `92531031 document not found`；裸 `import` 命中无关的仓颉文档）。故 R8 只有「各模块导入模块小节 + `js-apis-base` 的 ArkTS/JS 分例」这一级证据，「所有 Kit 都走 `@kit.*`」与「`@ohos.*` 在 ArkTS 中是否仍有效」未获总纲确认。
- ⚠️ `ide-oh-package-json5` 所属 catalogName 未确认（经 `doc <slug>` 直取正文，未定位其目录树位置）。
- ⚠️ `arkts-routing`、`arkts-router-to-navigation` 只取到标题，未记录 version 与更新时间。
- ⚠️ 幻觉清单中的「未检索到」基于目录树节点名与页面正文检索，不等于该 API 一定不存在。
- 🔶 **代码片段的验证状态分三档**（2026-09-03 免登录 OpenHarmony 编译链打通后重写）：
  1. **✅ 已过编译**：落进 `harmony/HybridShell/entry/src/main/ets/pages/Index.ets` 的 281 行
     （W1–W16 逐条标了规则编号）已过 `devecocli build`，`BUILD SUCCESSFUL in 3 s 109 ms`。
     准确说法是「已过 **OpenHarmony API 23** 编译，未在 HarmonyOS SDK 上编译，未运行」——
     OpenHarmony SDK 是子集，过了它**不等于**过 HarmonyOS SDK。
  2. **✅ 编译器正面确认**：只有 W1。反向实验把 `postMessageEvent` 改成 `postMessage`，
     编译器报 `10505001 Property 'postMessage' does not exist on type 'WebMessagePort'`（`Index.ets:177:21`）。
     推论：靠 API 签名成立的规则（W5/W12/W16、R2/R16 等）同样过了类型检查。
  3. **⚠️ 仍未编译验证**：未落进工程的片段。且 `code-linter` 至今跑不起来
     （OpenHarmony CLT 包内无 codelinter 实体，`$CLT/bin/codelinter` 只是个壳），静态检查这条线是空的。
- ⚠️ 「适用 API Level」只标注官方明确写出的起始版本，未逐条向官方确认下限。
- ⚠️ K1–K12 全部来自文档研读，**无一条经实机调用验证**。其中 K3（640/1280 字节、20/40 ms）、K5（TTS 实例设备级共享）、K7（并发返回系统繁忙）都是最需要实测确认的行为型结论。
- ⏳ K12 是时效性信息（试用期免费至 2026-12-31），2027 年起须重新核实计费口径。
- ⚠️ **W2/W3/W4/W9/W10/W11/W15 属运行期语义，编译通过不构成验证**，仍只有文档依据。
  W1 之外的 W 系列**无一条经实机验证**，全部来自 2026-09-02 / 2026-09-03 抓取的官方文档。
  但与 K 系列不同：**ArkWeb 官方明确支持模拟器**（`web-component-overview`），
  所以 W 系列是**可以被验证的**，不必等真机。现在的卡点已不是工具链而是**没有设备/模拟器**，
  见 `experiments/002-混合容器最小基座` 的步 3–8。
  ⚠️ 一处口径冲突：`arkts-apis-webview` 模块描述页写「示例效果请**以真机运行为准**」，
  与指南页的「支持模拟器」并不矛盾（一个讲准确性、一个讲可运行性），但**哪些能力在模拟器上有差异未确认**。
- ✅ W1–W16 的起始版本已补齐（见 `docs/05` 的「起始版本」一节）：模块首批接口 **API 9**，
  API 参考页标题无上角标即 9。仍未查的是 `Web` **组件**属性/事件（`onInterceptRequest`、
  `javaScriptProxy`、`fileAccess` 等）的起始版本——那些在组件描述页，不在 webview 模块页。
- ⚠️ **W17–W27 涉及的接口起始版本全未查**：`renderMode`、`enableNativeEmbedMode`、
  `registerNativeEmbedRule`、`onNativeEmbed*` 四个回调、`sharedRenderProcessToken` 在组件描述页；
  `setRenderProcessMode` / `terminateRenderProcess` / `onActive` / `onInactive` 在 webview 模块页但本轮未查。
  按 `CLAUDE.md`「凭印象写版本号 = 事故」，这些暂不标版本。
- ⚠️ W20/W21 的像素阈值（7,680 / 500,000 / 8,000）**是官方给的物理像素数字，未实测**。
  W24 的「每个 Web 组件约 200MB」同理，官方原文是「大约」。

## 来源

访问日期均为 2026-09-01。URL 拼法：`https://developer.huawei.com/consumer/cn/doc/<catalogName>/<slug>`。

| 文档标题 | slug | catalogName | version / 更新时间 |
| --- | --- | --- | --- |
| 从TypeScript到ArkTS的适配规则 | typescript-to-arkts-migration-guide | harmonyos-guides | V233 / 2026-08-31 17:51:14 |
| 声明式UI描述 | arkts-declarative-ui-description | harmonyos-guides | V235 / 展示 2026-08-29 |
| 自定义组件 | arkts-create-custom-components | harmonyos-guides | V235 / 展示 2026-08-29 |
| 装饰器概述 | arkts-decorator-overview | harmonyos-guides | V92 / 展示 2026-06-09 |
| 状态管理概述 | arkts-state-management-overview | harmonyos-guides | V236 / 展示 2026-08-29 |
| \@State | arkts-state | harmonyos-guides | V236 / 展示 2026-08-29 |
| \@Prop | arkts-prop | harmonyos-guides | V236 / 展示 2026-08-29 |
| \@Link | arkts-link | harmonyos-guides | V236 / 展示 2026-08-29 |
| \@Local | arkts-new-local | harmonyos-guides | V236 / 展示 2026-08-29 |
| \@Param | arkts-new-param | harmonyos-guides | V236 / 展示 2026-08-29 |
| V1V2混用 | arkts-v1-v2-mixusage | harmonyos-guides | V216 / 展示 2026-08-29 |
| \@Builder | arkts-builder | harmonyos-guides | V235 / 展示 2026-08-29 |
| 自定义组件成员属性访问限定符 | arkts-custom-components-access-restrictions | harmonyos-guides | V235 / 2026-08-31 17:57:49 |
| AppStorage | arkts-appstorage | harmonyos-guides | V236 / 展示 2026-08-29 |
| 异步并发 (Promise和async/await) | async-concurrency-overview | harmonyos-guides | V234 / 2026-08-31 17:55:21 |
| 声明权限 | declare-permissions | harmonyos-guides | V237 / 展示 2026-08-29 |
| 向用户申请授权 | request-user-authorization | harmonyos-guides | V237 / 2026-08-31 17:59:52 |
| module.json5配置文件 | module-configuration-file | harmonyos-guides | V235 / 展示 2026-09-01 |
| 资源分类与访问 | resource-categories-and-access | harmonyos-guides | V234 / 展示 2026-08-29 |
| 接口说明（导入 Kit 约定） | development-intro-api | harmonyos-guides | V233 / 展示 2026-09-01 |
| 页面路由 (@ohos.router)(不推荐) | arkts-routing | harmonyos-guides | ⚠️ 未记录 |
| Router切换Navigation | arkts-router-to-navigation | harmonyos-guides | ⚠️ 未记录 |
| @ohos.base (公共回调信息) | js-apis-base | harmonyos-references | V235 / 2026-08-31 18:11:50 |
| @ohos.abilityAccessCtrl (程序访问控制管理) | js-apis-abilityaccessctrl | harmonyos-references | V234 / 展示 2026-08-29 |
| @ohos.router (页面路由)(不推荐) | js-apis-router | harmonyos-references | V234 / 展示 2026-08-29 |
| 通用错误码 | errorcode-universal | harmonyos-references | V232 / 展示 2026-07-28 |
| oh-package.json5 | ide-oh-package-json5 | ⚠️ 未确认 | V111 / 2026-08-28 |

K1–K12 的逐条依据不在上表：它们来自各 Kit 的细节笔记，完整来源表见
[core-speech-kit.md](ai-kit/core-speech-kit.md)、[core-vision-kit.md](ai-kit/core-vision-kit.md)、[scenario-kits.md](ai-kit/scenario-kits.md)。

W1–W27 的依据同样不在上表，访问日期 **2026-09-02**（W1–W16）与 **2026-09-03**（W17–W27），
来源表见 [05-arkweb-hybrid-container.md](05-arkweb-hybrid-container.md)。







