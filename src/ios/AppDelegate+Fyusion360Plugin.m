#import "AppDelegate+Fyusion360Plugin.h"

#import "FyuseSessionTagging/FyuseSessionTagging.h"

@implementation AppDelegate (Fyusion360Plugin)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleFromMethod:@selector(application:handleEventsForBackgroundURLSession:completionHandler:)
                        toMethod:@selector(fyusion360Plugin_application:handleEventsForBackgroundURLSession:completionHandler:)];

        [self swizzleFromMethod:@selector(application:didFinishLaunchingWithOptions:)
                        toMethod:@selector(fyusion360Plugin_application:didFinishLaunchingWithOptions:)];

    });
}

+ (void)swizzleFromMethod:(SEL )originalSelector toMethod:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSString *)getValueFromPList:(NSString *)key {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

- (void)fyusion360Plugin_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    [super application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

- (BOOL)fyusion360Plugin_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *apiKey = [self getValueFromPList:@"FYUSION360_API_KEY"];
    NSString *apiSecret = [self getValueFromPList:@"FYUSION360_API_SECRET"];
    
    [FYAuthManager initializeWithAppID:apiKey appSecret:apiSecret onSuccess:^{
        NSLog(@"Fyuse360 initialized successfully");
    } onError:^(NSError * _Nonnull error) {
        NSLog(@"Error initializing");
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
