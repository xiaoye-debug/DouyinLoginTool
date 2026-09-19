#import "DYYYLoginBypassManager.h"
#import <objc/runtime.h>

static NSString *const kDYYYLoginBypassEnabledKey = @"DYYYLoginBypassEnabled";

@implementation DYYYLoginBypassManager

+ (BOOL)isLoginBypassEnabled {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kDYYYLoginBypassEnabledKey];
    if (!value) {
        return YES; // 默认启用
    }
    return [value boolValue];
}

+ (void)setLoginBypassEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:kDYYYLoginBypassEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)configureInitialStateIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 检查是否已经登录
        Class userServiceClass = NSClassFromString(@"AWEUserService");
        if (userServiceClass) {
            id userService = [userServiceClass performSelector:@selector(sharedInstance)];
            if (userService) {
                BOOL isLoggedIn = NO;
                if ([userService respondsToSelector:@selector(isLoggedIn)]) {
                    isLoggedIn = [userService performSelector:@selector(isLoggedIn)];
                }
                
                if (isLoggedIn) {
                    // 已登录，禁用绕过
                    [self setLoginBypassEnabled:NO];
                } else {
                    // 未登录，启用绕过
                    [self setLoginBypassEnabled:YES];
                }
            }
        }
    });
}

+ (void)handleOfficialLoginCompletionWithUserID:(NSString *)userID {
    [self setLoginBypassEnabled:NO];
}

+ (void)handleOfficialLogout {
    [self setLoginBypassEnabled:YES];
}

+ (BOOL)shouldApplyLoginNetworkCamouflage {
    return [self isLoginBypassEnabled];
}

+ (NSString *)replacementBundleIdentifier:(NSString *)bundleIdentifier {
    if (![self shouldApplyLoginNetworkCamouflage]) {
        return bundleIdentifier;
    }
    
    // 返回伪装后的 Bundle ID
    static NSArray *emojiSuffixes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emojiSuffixes = @[@"😄", @"😊", @"😃", @"😉", @"😍", @"😘", @"😜", @"😝", @"😛", @"😋"];
    });
    
    NSString *randomEmoji = emojiSuffixes[arc4random_uniform((uint32_t)emojiSuffixes.count)];
    return [bundleIdentifier stringByAppendingString:randomEmoji];
}

+ (NSDictionary *)headersByReplacingBundleIdentifiers:(NSDictionary *)headers {
    if (![self shouldApplyLoginNetworkCamouflage]) {
        return headers;
    }
    
    NSMutableDictionary *mutableHeaders = [headers mutableCopy];
    
    // 替换常见的 Bundle ID 相关字段
    NSArray *bundleIDKeys = @[@"X-Bundle-ID", @"Bundle-ID", @"BundleID"];
    for (NSString *key in bundleIDKeys) {
        NSString *value = mutableHeaders[key];
        if (value) {
            mutableHeaders[key] = [self replacementBundleIdentifier:value];
        }
    }
    
    return [mutableHeaders copy];
}

+ (NSString *)stringByReplacingTargetBundleIdentifiers:(NSString *)value {
    if (![self shouldApplyLoginNetworkCamouflage]) {
        return value;
    }
    
    // 替换字符串中的 Bundle ID
    NSArray *targetIdentifiers = @[
        @"com.ss.iphone.ugc.Aweme",
        @"com.ss.iphone.ugc.Aweme3760",
        @"com.ss.iphone.ugc.Aweme3800",
        @"com.ss.iphone.ugc.Aweme3861",
        @"com.ss.iphone.ugc.Aweme3890",
        @"com.ss.iphone.ugc.Aweme3920",
        @"com.ss.iphone.ugc.Aweme3950"
    ];
    
    NSString *result = value;
    for (NSString *identifier in targetIdentifiers) {
        if ([result containsString:identifier]) {
            result = [result stringByReplacingOccurrencesOfString:identifier 
                                                       withString:[self replacementBundleIdentifier:identifier]];
        }
    }
    
    return result;
}

+ (NSURL *)URLByReplacingTargetBundleIdentifiers:(NSURL *)url {
    if (![self shouldApplyLoginNetworkCamouflage]) {
        return url;
    }
    
    NSString *urlString = [url absoluteString];
    NSString *modifiedString = [self stringByReplacingTargetBundleIdentifiers:urlString];
    
    if (![modifiedString isEqualToString:urlString]) {
        return [NSURL URLWithString:modifiedString];
    }
    
    return url;
}

+ (BOOL)shouldApplyEmojiBundleSpoof {
    return [self isLoginBypassEnabled];
}

+ (BOOL)shouldMaintainCloneSessionIdentity {
    return [self isLoginBypassEnabled];
}

+ (BOOL)isNumericAwemeCloneProcess {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [bundleIdentifier hasPrefix:@"com.ss.iphone.ugc.Aweme"];
}

@end
