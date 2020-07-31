#import "AppDelegate.h"
#import <objc/runtime.h>

@interface AppDelegate (Fyusion360Plugin)

- (void)fyusion360Plugin_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

+ (void)swizzleFromMethod:(SEL )originalSelector toMethod:(SEL)swizzledSelector;

@end
