#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYYYLoginBypassManager : NSObject

#pragma mark - Login State Detection

+ (BOOL)isLoginBypassEnabled;
+ (void)setLoginBypassEnabled:(BOOL)enabled;
+ (void)configureInitialStateIfNeeded;

#pragma mark - Login/Logout Handling

+ (void)handleOfficialLoginCompletionWithUserID:(nullable id)userIDOrAccount;
+ (void)handleOfficialLogout;

#pragma mark - Bundle Identity / Request Rewrite

+ (BOOL)shouldApplyLoginNetworkCamouflage;
+ (NSString *)replacementBundleIdentifier:(NSString *)bundleIdentifier;
+ (NSDictionary *)headersByReplacingBundleIdentifiers:(NSDictionary *)headers;
+ (NSString *)stringByReplacingTargetBundleIdentifiers:(NSString *)value;
+ (NSURL *)URLByReplacingTargetBundleIdentifiers:(NSURL *)url;
+ (BOOL)shouldApplyEmojiBundleSpoof;
+ (BOOL)shouldMaintainCloneSessionIdentity;
+ (BOOL)isNumericAwemeCloneProcess;

@end

NS_ASSUME_NONNULL_END