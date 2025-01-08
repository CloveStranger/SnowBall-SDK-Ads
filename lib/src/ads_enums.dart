///广告平台
///[MediationType.max] Applovin Max
///[MediationType.admob] Google Admob
enum MediationType {
  max,
  admob,
}

///广告类型
///[AdType.rewarded] 奖励广告
///[AdType.interstitial] 插屏广告
///[AdType.appOpen] 开屏广告
///[AdType.banner] 横幅广告
///[AdType.native] 原生广告
enum AdType {
  rewarded,
  interstitial,
  appOpen,
  banner,
  native,
}

///广告状态
///[AdState.shouldNotShow] 不显示
///[AdState.notReady] 未准备好
///[AdState.showSuccess] 显示成功
///[AdState.showFail] 显示失败
///[AdState.closed] 关闭
///[AdState.rewarded] 奖励
enum AdState {
  shouldNotShow,
  notReady,
  showSuccess,
  showFail,
  closed,
  rewarded,
}
