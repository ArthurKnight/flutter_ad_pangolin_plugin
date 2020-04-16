#import "PangolinPlugin.h"
#import <BUAdSDK/BUAdSDK.h>
//#import "PangolinPluginEvent.h"

@interface PangolinPlugin ()<BUNativeExpressRewardedVideoAdDelegate,BUSplashAdDelegate>
//@interface PangolinPlugin ()
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
//事件处理
//PangolinPluginEvent * pangolinEvent;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"com.luoyang.ad.pangolin" binaryMessenger:[registrar messenger]];
    PangolinPlugin* instance = [[PangolinPlugin alloc] initWithChannel:channel registrar:registrar messenger:[registrar messenger]];
    //PangolinPlugin* instance = [[PangolinPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
//    pangolinEvent = [[PangolinPluginEvent alloc] init];
//    pangolinEvent.eventChannel = [FlutterEventChannel eventChannelWithName:@"com.luoyang.ad.pangolin.event" binaryMessenger:[registrar messenger]];
//    [pangolinEvent.eventChannel setStreamHandler:pangolinEvent];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    NSLog(@"FlutterInCallManager.init(): initialized");
    _eventChannel = [FlutterEventChannel
                                eventChannelWithName:@"com.luoyang.ad.pangolin.event"
                                binaryMessenger:messenger];
    [_eventChannel setStreamHandler:self];

//    pangolinEvent
//    pangolinEvent = [FlutterEventChannel
//                                    eventChannelWithName:@"com.luoyang.ad.pangolin.event"
//                                    binaryMessenger:messenger];
//        [pangolinEvent setStreamHandler:pangolinEvent];
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
    }
    else if([@"loadRewardAd" isEqualToString:call.method])
    {
        NSString* slotId = call.arguments[@"slotId"];
        NSString* userId = call.arguments[@"userId"];
        NSString* rewardName = call.arguments[@"rewardName"];
        
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        model.userId = userId;
        model.rewardName = rewardName;
    
        //self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:@"945133267" rewardedVideoModel:model];
        //self.rewardedVideoAd.delegate = self;
        //[self.rewardedVideoAd loadAdData];
        
        //slotId = @"945133267";
        self.rewardedAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:slotId rewardedVideoModel:model];
        self.rewardedAd.delegate = self;
        [self.rewardedAd loadAdData];
        result(@YES);
//        FlutterEventSink eventSink = pangolinEvent.eventSink;
//        if(eventSink){
//            eventSink(@{
//                @"event":@"demoEvent",
//                @"value":@"ok",
//                      });
//        }
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

//激励视频渲染完成展示
- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.rewardedAd showAdFromRootViewController: [self theTopViewController]];
    printf("激励视频渲染完成展示");
    _eventSink(@{
        @"event":@"rewardVideoRenderSuccess",
        @"value":1}
    );
}

//展示视频用
- (UIViewController *)theTopViewController{
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

//激励视频播放完成
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    printf(__func__);
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
- (BOOL)loadSplashAD:(NSString *)slotId {
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:slotId frame:frame];
    splashView.delegate = self;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
    return YES;
}

//点击关闭
- (void) splashAdDidClose:(BUSplashAdView *)splashAd{
    [splashAd removeFromSuperview];
}




@end



