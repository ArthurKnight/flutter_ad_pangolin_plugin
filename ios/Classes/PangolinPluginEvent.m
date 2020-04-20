//#import <Foundation/Foundation.h>
//#import "PangolinPluginEvent.h"
//#import <objc/runtime.h>
//
//@implementation PangolinPluginEvent
//
//@dynamic eventSink;
//
//- (FlutterEventSink)eventSink
//{
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//- (void)setEeventSink:(FlutterEventSink)eventSink
//{
//    objc_setAssociatedObject(self, @selector(eventSink), eventSink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (FlutterEventChannel *)eventChannel
//{
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//- (void)setEventChannel:(FlutterEventChannel *)eventChannel
//{
//    objc_setAssociatedObject(self, @selector(eventChannel),eventChannel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
//    self.eventSink = nil;
//    return nil;
//}
//
//- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)sink{
//    self.eventSink = sink;
//    return nil;
//}
//
//@end
