/**
 * M1 · 装到模拟器
 *
 * 这一步只要求「屏幕上有一个原生页面」，**不碰 Web 组件**（pro 的 plan/M1 明写）。
 * 承载、注入、UA、导航降级从 M2 起，见本仓 TASKS.md。
 *
 * 页面上的字都是静态的：这一步没有任何需要运行期取值的判据，
 * 而 bundleName / versionName 从 AppScope/app.json5 读要走异步的 bundleManager，
 * 那是 M1 用不上的风险。
 */

@Entry
@Component
struct Index {
  private readonly appLabel: string = '螃蟹 · Crab';
  private readonly milestone: string = 'M1 装到模拟器';
  private readonly note: string = '原生页面已起来。Web 组件从 M2 接。';

  build() {
    Column({ space: 12 }) {
      Text(this.appLabel)
        .id('CrabAppLabel')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
      Text(this.milestone)
        .id('CrabMilestone')
        .fontSize(18)
      Text(this.note)
        .id('CrabNote')
        .fontSize(14)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(24)
  }
}
