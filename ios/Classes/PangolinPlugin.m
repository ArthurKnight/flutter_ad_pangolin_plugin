#import "PangolinPlugin.h"
#import <BUAdSDK/BUAdSDK.h>

@interface PangolinPlugin ()<BUNativeExpressRewardedVideoAdDelegate,BUSplashAdDelegate>
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
@end

@implementation PangolinPlugin

FlutterEventSink _eventSink;
FlutterEventChannel* _eventChannel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
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




@end



