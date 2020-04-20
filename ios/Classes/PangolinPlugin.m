#import "PangolinPlugin.h"
#import <BUAdSDK/BUAdSDK.h>
#import "BUDMacros.h"
//#import "FlutterIosTextLabelFactory.h"

@interface PangolinPlugin ()<BUNativeExpressRewardedVideoAdDelegate,BUSplashAdDelegate,
BUNativeAdsManagerDelegate,BUVideoAdViewDelegate,BUNativeAdDelegate,
BUNativeExpressAdViewDelegate,UITableViewDelegate, UITableViewDataSource,
BUNativeExpressFullscreenVideoAdDelegate,
BUNativeExpresInterstitialAdDelegate>
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, strong) UITextField *playableUrlTextView;
@property (nonatomic, strong) UITextField *downloadUrlTextView;
@property (nonatomic, strong) UITextField *deeplinkUrlTextView;
@property (nonatomic, strong) UILabel *isLandscapeLabel;
@property (nonatomic, strong) UISwitch *isLandscapeSwitch;
@property (nonatomic, assign) BOOL isPlayableUrlValid;
@property (nonatomic, assign) BOOL isDownloadUrlValid;
@property (nonatomic, assign) BOOL isDeeplinkUrlValid;

@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *rewardedAd;

@property (nonatomic, strong) BUFullscreenVideoAd *fullscreenVideoAd;

//个性化激励视频
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) BUNativeAdsManager *adManager;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *dataSource;

//个性化渲染 信息流
@property (strong, nonatomic) NSMutableArray<__kindof BUNativeExpressAdView *> *expressAdViews;
@property (strong, nonatomic) BUNativeExpressAdManager *nativeExpressAdManager;
@property (strong, nonatomic) UILabel *widthLabel;
@property (strong, nonatomic) UISlider *widthSlider;
@property (strong, nonatomic) UILabel *heightLabel;
@property (strong, nonatomic) UISlider *heightSlider;
@property (strong, nonatomic) UISlider *adCountSlider;
@property (strong, nonatomic) UILabel *adCountLabel;
@property (strong, nonatomic) NSTimer *timer;

//全屏视频
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *fullscreenAd;

//插屏广告
@property (nonatomic, strong) BUNativeExpressInterstitialAd *interstitialAd;

@end

@implementation PangolinPlugin

FlutterEventSink _eventSink;
FlutterEventChannel* _eventChannel;


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    //注册原生view=》flutter_express_ad_view
    //[registrar registerViewFactory:[[FlutterIosTextLabelFactory alloc] initWithMessenger:registrar.messenger] withId:@"flutter_express_ad_view"];
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"com.luoyang.ad.pangolin" binaryMessenger:[registrar messenger]];
    PangolinPlugin* instance = [[PangolinPlugin alloc] initWithChannel:channel registrar:registrar messenger:[registrar messenger]];
    //PangolinPlugin* instance = [[PangolinPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    NSLog(@"FlutterInCallManager.init(): initialized");
    _eventChannel = [FlutterEventChannel
                                eventChannelWithName:@"com.luoyang.ad.pangolin.event"
                                binaryMessenger:messenger];
    [_eventChannel setStreamHandler:self];
    return self;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"register" isEqualToString:call.method]) {
        NSString* appId = call.arguments[@"appId"];
        
        [BUAdSDKManager setAppID:appId];
        
        //[BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
        [BUAdSDKManager setLoglevel:BUAdSDKLogLevelError];

        [BUAdSDKManager setIsPaidApp:NO];
        
        result(@YES);
    }
    else if([@"loadSplashAd" isEqualToString:call.method])
    {
        NSString* slotId = call.arguments[@"slotId"];
        [self loadSplashAD : slotId];
        result(@YES);
    }
    else if([@"removeSplashView" isEqualToString:call.method])
    {
        [[UIApplication sharedApplication].windows.firstObject removeFromSuperview];
        result(@YES);
    }
    else if([@"loadRewardAd" isEqualToString:call.method])
    {
        NSString* slotId = call.arguments[@"slotId"];
        NSString* userId = call.arguments[@"userId"];
        NSString* rewardName = call.arguments[@"rewardName"];
        
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        model.userId = userId;
        model.rewardName = rewardName;
    
        self.rewardedAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:slotId rewardedVideoModel:model];
        self.rewardedAd.delegate = self;
        [self.rewardedAd loadAdData];
        result(@YES);
    }
    else if([@"loadNativeAd" isEqualToString:call.method])
    {
        NSString* slotId = call.arguments[@"slotId"];
        [self loadNativeAds:slotId loadCount:1];
        result(@YES);
    }
    else if([@"loadExpressAd" isEqualToString:call.method])
    {
        NSString* slotId = call.arguments[@"slotId"];
        [self loadExpressAd:slotId];
        result(@YES);
    }
    else if([@"loadFullscreenVideoAdWithSlotID" isEqualToString:call.method])
    {
       NSString* slotId = call.arguments[@"slotId"];
       [self loadFullscreenVideoAdWithSlotID:slotId];
       result(@YES);
    }
    else if([@"loadInterstitialWithSlotID" isEqualToString:call.method])
    {
       NSString* slotId = call.arguments[@"slotId"];
       [self loadInterstitialWithSlotID:slotId];
       result(@YES);
    }
    else
    {
        result(FlutterMethodNotImplemented);
    }
}

//- (UIViewController *)rootViewController {
//    BUDMainViewController *mainViewController = [[BUDMainViewController alloc] init];
//    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:mainViewController];
//    return navigationVC;
//}

//- (void)showRewardVideoAd {
//    if (self.rewardedAd) {
//
//        [self.rewardedAd showAdFromRootViewController: [self rootViewController]];
//    }
//}



//展示视频用
- (UIViewController *)rootViewController{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    while((parent = rootVC.presentingViewController) != nil){
        rootVC = parent;
    }
    
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    return rootVC;
}

//激励视频渲染完成并展示
- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    printf("激励视频渲染完成并展示视频");
    [self.rewardedAd showAdFromRootViewController: [self rootViewController]];
    //事件通知
    _eventSink(@{
        @"event":@"rewardVideoRenderSuccess",
        @"value":@"1"}
    );
}

//激励视频播放完成
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    printf("激励视频播放完成");
}

//激励视频关闭
- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    printf("已看完激励视频，用户点击关闭");
    _eventSink(@{
        @"event":@"rewardVideoClose",
        @"value":self.rewardedAd.rewardedVideoModel.rewardName}
    );
}



//加载开屏广告
- (void)loadSplashAD:(NSString *)slotId {
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:slotId frame:frame];
    
    //穿山甲默认开屏广告超时时间为3秒，可通过tolerateTimeout设置
    //splashView.tolerateTimeout =3;
    splashView.delegate = self;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    self.startTime = CACurrentMediaTime();
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
}

//开屏广告点击关闭
- (void) splashAdDidClose:(BUSplashAdView *)splashAd{
    [splashAd removeFromSuperview];
    NSLog(@"开屏广告点击关闭 移除view");
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Total Runtime: %g s \n",endTime - self.startTime);
    
    _eventSink(@{
        @"event":@"splashAdDidClose",
        @"value":@"1"}
    );
}

//开屏广告报错
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    printf("开屏广告报错 移除view");
    [splashAd removeFromSuperview];
    CFTimeInterval endTime = CACurrentMediaTime();
    double totalTime = endTime - self.startTime;
    NSLog(@"Total Runtime: %g s error=%@\n", totalTime, error);
    
    _eventSink(@{
        @"event":@"splashAdDidFailWithError",
        @"value":@"1"}
    );
}

//开屏广告隐藏
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    CFTimeInterval endTime = CACurrentMediaTime();
    double totalTime = endTime - self.startTime;
    printf("Total Showtime: %g s", totalTime);
    
    _eventSink(@{
        @"event":@"splashAdWillVisible",
        @"value":@"1"}
    );
}

//----------全屏视频----------
- (void)loadFullscreenVideoAdWithSlotID:(NSString *)slotID {
    self.fullscreenAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:slotID];
    self.fullscreenAd.delegate = self;
    [self.fullscreenAd loadAdData];
    //为保证播放流畅和展示流畅建议可在收到渲染成功和视频下载完成回调后再展示视频。
}

- (void)showFullscreenVideoAd {
    if (self.fullscreenAd) {
        [self.fullscreenAd showAdFromRootViewController:[self rootViewController]];
    }
}
#pragma mark - BUFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    BUD_Log(@"%s",__func__);
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    [self showFullscreenVideoAd];
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdWillVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClickSkip:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdWillClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpressFullscreenVideoAdDidCloseOtherController:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    BUD_Log(@"%s __ %@",__func__,str);
}

//----------全屏视频----------



//----------插屏广告3:2----------
- (void)loadInterstitialWithSlotID:(NSString *)slotID {
    NSDictionary *sizeDict = @{
        //express_interstitial_ID_1_1:[NSValue valueWithCGSize:CGSizeMake(300, 300)],
        //express_interstitial_ID_2_3:[NSValue valueWithCGSize:CGSizeMake(300, 450)],
        //express_interstitial_ID_3_2:[NSValue valueWithCGSize:CGSizeMake(300, 200)],
        //express_interstitial_ID_overSeas:[NSValue valueWithCGSize:CGSizeMake(300, 300)]
        slotID:[NSValue valueWithCGSize:CGSizeMake(300, 200)]
    };
    NSValue *sizeValue = [sizeDict objectForKey:slotID];
    CGSize size = [sizeValue CGSizeValue];
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds)-40;
    CGFloat height = width/size.width*size.height;
    #warning 升级的用户请注意，初始化方法去掉了imgSize参数
    self.interstitialAd = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:slotID adSize:CGSizeMake(width, height)];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAdData];
}

- (void)showInterstitial {
    if (self.interstitialAd) {
        [self.interstitialAd showAdFromRootViewController:[self rootViewController]];
    }
}

#pragma ---BUNativeExpresInterstitialAdDelegate
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self showInterstitial];
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    BUD_Log(@"%s",__func__);
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
}

- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdWillClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    BUD_Log(@"%s",__func__);
}

- (void)nativeExpresInterstitialAdDidCloseOtherController:(BUNativeExpressInterstitialAd *)interstitialAd interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    BUD_Log(@"%s __ %@",__func__,str);
}

//----------插屏广告3:2----------


//加载原生信息流广告
- (void)loadNativeAds:(NSString *)slotId loadCount:(NSInteger)loadCount {
    BUNativeAdsManager *nad = [BUNativeAdsManager new];
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = slotId;
    slot1.AdType = BUAdSlotAdTypeFeed;
    slot1.position = BUAdSlotPositionTop;
    slot1.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
    slot1.isSupportDeepLink = YES;
    nad.adslot = slot1;
    nad.delegate = self;
    self.adManager = nad;
    
    [nad loadAdDataWithCount:loadCount];
}

//原生信息流加载成功
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    NSLog(@"feed datas load success");
    for (BUNativeAd *model in nativeAdDataArray) {
        //NSUInteger index = rand() % (self.dataSource.count-3)+2;
        //[self.dataSource insertObject:model atIndex:index];
        [self.dataSource insertObject:model atIndex:0];
    }
    [self.tableView reloadData];
}

//原生信息流加载失败
- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    NSLog(@"feed datas load fail");
    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
}

//----------信息流广告个性化模版----------
- (void)loadExpressAd:(NSString *)slotId {
//    CGRect frame = [UIScreen mainScreen].bounds;
//    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:slotId frame:frame];
//
//    splashView.delegate = self;
//    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
//    self.startTime = CACurrentMediaTime();
//    [splashView loadAdData];
//    [keyWindow.rootViewController.view addSubview:splashView];
//    splashView.rootViewController = keyWindow.rootViewController;
//
    
    if(self.window == nil){
        UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [keyWindow makeKeyAndVisible];
        self.window = keyWindow;
        self.window.rootViewController = [self rootViewController];
    }

    self.expressAdViews = [NSMutableArray new];
    if (!self.expressAdViews) {
        self.expressAdViews = [NSMutableArray arrayWithCapacity:20];
    }
    

    [self.window.rootViewController.view addSubview:self.tableView];
    
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = slotId;
    slot1.AdType = BUAdSlotAdTypeFeed;
    BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    slot1.imgSize = imgSize;
    slot1.position = BUAdSlotPositionFeed;
    slot1.isSupportDeepLink = YES;

    // self.nativeExpressAdManager可以重用
    if (!self.nativeExpressAdManager) {
        self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1
        //adSize:CGSizeMake(self.widthSlider.value, self.heightSlider.value)];
        adSize:CGSizeMake(414, 0)];
    }

    self.nativeExpressAdManager.adSize = CGSizeMake(1000, 0);
    self.nativeExpressAdManager.delegate = self;
    NSInteger count = (NSInteger)self.adCountSlider.value;
    count = 1;
    [self.nativeExpressAdManager loadAd:count];
}

- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    [self.expressAdViews removeAllObjects];//【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
    if (views.count) {
        [self.expressAdViews addObjectsFromArray:views];
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
            expressView.rootViewController = [self rootViewController];
            [expressView render];
        }];
    }
    
    //[self.tableView reloadData];
    NSLog(@"【BytedanceUnion】个性化模板拉取广告成功回调");
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    printf("nativeExpressAdFailToLoad");
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    printf("nativeExpressAdViewRenderSuccess");
    [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
        [self.window.rootViewController.view addSubview:expressView];
    }];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {//【重要】需要在点击叉以后 在这个回调中移除视图，否则，会出现用户点击叉无效的情况
    [self.expressAdViews removeObject:nativeExpressAdView];

    NSUInteger index = [self.expressAdViews indexOfObject:nativeExpressAdView];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
//----------信息流广告个性化模版----------

@end



