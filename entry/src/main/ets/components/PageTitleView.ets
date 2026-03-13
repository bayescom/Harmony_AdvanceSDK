
@Component
export struct PageTitleView {
  title: string = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}