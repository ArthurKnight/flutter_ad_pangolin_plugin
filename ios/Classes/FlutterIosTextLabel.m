//#import "FlutterIosTextLabel.h"
//#import "PangolinPlugin.h"
//#import <BUAdSDK/BUAdSDK.h>
//#import "BUDMacros.h"
//
//@interface FlutterIosTextLabel ()<BUNativeAdsManagerDelegate,BUVideoAdViewDelegate,BUNativeAdDelegate,
//BUNativeExpressAdViewDelegate,UITableViewDelegate, UITableViewDataSource>
//
//@property (strong, nonatomic) UIWindow *window;
////个性化渲染 信息流
//@property (strong, nonatomic) NSMutableArray<__kindof BUNativeExpressAdView *> *expressAdViews;
//@property (strong, nonatomic) BUNativeExpressAdManager *nativeExpressAdManager;
//@end
//
//@implementation FlutterIosTextLabel{
//    //FlutterIosTextLabel 创建后的标识
//    int64_t _viewId;
//    UIView * myView;
//    //消息回调
//    FlutterMethodChannel* _channel;
//}
//
//
////在这里只是创建了一个UILabel
//-(instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
//    if ([super init]) {
//        
////        if (frame.size.width==0) {
////            frame=CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 100);
////        }
//        
//        if(myView == nil){
//            UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//            [keyWindow makeKeyAndVisible];
//            myView = keyWindow;
//        }
//        
//        NSString* value = args[@"text"];
//        
//        _viewId = viewId;
//        //[myView addSubview:_uiLabel];
//        
//        NSString* slotId = @"945141670";
//       
//        [self loadExpressAd:slotId];
//        
//        return self;
//    }
//    return self;
//    
//}
//
//- (nonnull UIView *)view{
//    return myView;
//}
//
////展示视频用
//- (UIViewController *)rootViewController{
//    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
//    
//    UIViewController *parent = rootVC;
//    while((parent = rootVC.presentingViewController) != nil){
//        rootVC = parent;
//    }
//    
//    while ([rootVC isKindOfClass:[UINavigationController class]]) {
//        rootVC = [(UINavigationController *)rootVC topViewController];
//    }
//    
//    return rootVC;
//}
//
//- (void)loadExpressAd:(NSString *)slotId {
//    
////    if(self.window == nil){
////        UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
////        [keyWindow makeKeyAndVisible];
////        self.window = keyWindow;
////        self.window.rootViewController = [self rootViewController];
////    }
//
//    self.expressAdViews = [NSMutableArray new];
//    if (!self.expressAdViews) {
//        self.expressAdViews = [NSMutableArray arrayWithCapacity:20];
//    }
//    
//    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
//    slot1.ID = slotId;
//    slot1.AdType = BUAdSlotAdTypeFeed;
//    BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
//    slot1.imgSize = imgSize;
//    slot1.position = BUAdSlotPositionFeed;
//    slot1.isSupportDeepLink = YES;
//
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    // self.nativeExpressAdManager可以重用
//    if (!self.nativeExpressAdManager) {
//        self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(width, 0)];
//    }
//    self.nativeExpressAdManager.adSize = CGSizeMake(width, 0);
//    self.nativeExpressAdManager.delegate = self;
//    NSInteger count = 1;//(NSInteger)self.adCountSlider.value;
//    [self.nativeExpressAdManager loadAd:count];
//}
//
//- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
//    [self.expressAdViews removeAllObjects];//【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
//    if (views.count) {
//        [self.expressAdViews addObjectsFromArray:views];
//        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
//            expressView.rootViewController = [self rootViewController];
//            [expressView render];
//        }];
//    }
//    NSLog(@"【BytedanceUnion】个性化模板拉取广告成功回调");
//}
//
//- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
//    BUD_Log(@"%s",__func__);
//    NSLog(@"error code : %ld , error message : %@",(long)error.code,error.description);
//}
//
//- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
//    NSLog(@"====== %p videoDuration = %ld",nativeExpressAdView,(long)nativeExpressAdView.videoDuration);
//    [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj;
//        //[self.window.rootViewController.view addSubview:expressView];
//        [self.view addSubview:expressView];
//    }];
//}
//
//- (void)updateCurrentPlayedTime {
//    for (BUNativeExpressAdView *nativeExpressAdView in self.expressAdViews) {
//        NSLog(@"====== %p currentPlayedTime = %f",nativeExpressAdView,nativeExpressAdView.currentPlayedTime);
//    }
//}
//
//- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView stateDidChanged:(BUPlayerPlayState)playerState {
//    NSLog(@"====== %p playerState = %ld",nativeExpressAdView,playerState);
//}
//
//- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdViewPlayerDidPlayFinish:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {//【重要】需要在点击叉以后 在这个回调中移除视图，否则，会出现用户点击叉无效的情况
//    [self.expressAdViews removeObject:nativeExpressAdView];
//    //NSUInteger index = [self.expressAdViews indexOfObject:nativeExpressAdView];
//    //NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
//    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//}
//
//- (void)nativeExpressAdViewDidClosed:(BUNativeExpressAdView *)nativeExpressAdView {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
//    BUD_Log(@"%s",__func__);
//}
//
//- (void)nativeExpressAdViewDidCloseOtherController:(BUNativeExpressAdView *)nativeExpressAdView interactionType:(BUInteractionType)interactionType {
//    NSString *str = nil;
//    if (interactionType == BUInteractionTypePage) {
//        str = @"ladingpage";
//    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
//        str = @"videoDetail";
//    } else {
//        str = @"appstoreInApp";
//    }
//    BUD_Log(@"%s __ %@",__func__,str);
//}
//@end
