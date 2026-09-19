#import "DYYYLoginRepairHooks.h"
#import "DYYYLoginBypassManager.h"
#import <objc/runtime.h>

@implementation DYYYLoginRepairHooks

+ (void)installHooks {
    // Hook TTInstallIDManager 禁用 GF 和 Dtrait 采集
    Class installIDManagerClass = NSClassFromString(@"TTInstallIDManager");
    if (installIDManagerClass) {
        // setEnableCollectGF:
        Method setEnableCollectGFMethod = class_getInstanceMethod(installIDManagerClass, @selector(setEnableCollectGF:));
        if (setEnableCollectGFMethod) {
            IMP newIMP = imp_implementationWithBlock(^void(id self, BOOL enabled) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    // 禁用 GF 采集
                    return;
                }
                void (*orig)(id, SEL, BOOL) = (void *)method_getImplementation(setEnableCollectGFMethod);
                orig(self, @selector(setEnableCollectGF:), enabled);
            });
            method_setImplementation(setEnableCollectGFMethod, newIMP);
        }
        
        // setEnableDtrait:
        Method setEnableDtraitMethod = class_getInstanceMethod(installIDManagerClass, @selector(setEnableDtrait:));
        if (setEnableDtraitMethod) {
            IMP newIMP = imp_implementationWithBlock(^void(id self, BOOL enabled) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    // 禁用 Dtrait
                    return;
                }
                void (*orig)(id, SEL, BOOL) = (void *)method_getImplementation(setEnableDtraitMethod);
                orig(self, @selector(setEnableDtrait:), enabled);
            });
            method_setImplementation(setEnableDtraitMethod, newIMP);
        }
    }
    
    // Hook TTInstallGFManager 禁用 GF 管理
    Class installGFManagerClass = NSClassFromString(@"TTInstallGFManager");
    if (installGFManagerClass) {
        // dtraitCollectConfigEmpty
        Method dtraitCollectConfigEmptyMethod = class_getInstanceMethod(installGFManagerClass, @selector(dtraitCollectConfigEmpty));
        if (dtraitCollectConfigEmptyMethod) {
            IMP newIMP = imp_implementationWithBlock(^BOOL(id self) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return YES; // 返回空配置
                }
                BOOL (*orig)(id, SEL) = (void *)method_getImplementation(dtraitCollectConfigEmptyMethod);
                return orig(self, @selector(dtraitCollectConfigEmpty));
            });
            method_setImplementation(dtraitCollectConfigEmptyMethod, newIMP);
        }
        
        // dtraitConfigFromFile
        Method dtraitConfigFromFileMethod = class_getInstanceMethod(installGFManagerClass, @selector(dtraitConfigFromFile));
        if (dtraitConfigFromFileMethod) {
            IMP newIMP = imp_implementationWithBlock(^id(id self) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return nil; // 返回空配置
                }
                id (*orig)(id, SEL) = (void *)method_getImplementation(dtraitConfigFromFileMethod);
                return orig(self, @selector(dtraitConfigFromFile));
            });
            method_setImplementation(dtraitConfigFromFileMethod, newIMP);
        }
    }
    
    // Hook TTNetworkManager 替换 URL 中的 Bundle ID
    Class networkManagerClass = NSClassFromString(@"TTNetworkManager");
    if (networkManagerClass) {
        Method transferedURLMethod = class_getInstanceMethod(networkManagerClass, @selector(transferedURL:));
        if (transferedURLMethod) {
            IMP newIMP = imp_implementationWithBlock(^id(id self, id url) {
                id (*orig)(id, SEL, id) = (void *)method_getImplementation(transferedURLMethod);
                id originalURL = orig(self, @selector(transferedURL:), url);
                
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return [DYYYLoginBypassManager URLByReplacingTargetBundleIdentifiers:originalURL];
                }
                
                return originalURL;
            });
            method_setImplementation(transferedURLMethod, newIMP);
        }
    }
    
    // Hook TTHttpRequest 替换 URL
    Class httpRequestClass = NSClassFromString(@"TTHttpRequest");
    if (httpRequestClass) {
        Method setURLMethod = class_getInstanceMethod(httpRequestClass, @selector(setURL:));
        if (setURLMethod) {
            IMP newIMP = imp_implementationWithBlock(^void(id self, id url) {
                id finalURL = url;
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    finalURL = [DYYYLoginBypassManager URLByReplacingTargetBundleIdentifiers:url];
                }
                void (*orig)(id, SEL, id) = (void *)method_getImplementation(setURLMethod);
                orig(self, @selector(setURL:), finalURL);
            });
            method_setImplementation(setURLMethod, newIMP);
        }
    }
}

@end