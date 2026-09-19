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
            method_setImplementation(setEnableCollectGFMethod, (IMP)^void(id self, SEL _cmd, BOOL enabled) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    // 禁用 GF 采集
                    return;
                }
                void (*orig)(id, SEL, BOOL) = (void *)method_getImplementation(setEnableCollectGFMethod);
                orig(self, _cmd, enabled);
            });
        }
        
        // setEnableDtrait:
        Method setEnableDtraitMethod = class_getInstanceMethod(installIDManagerClass, @selector(setEnableDtrait:));
        if (setEnableDtraitMethod) {
            method_setImplementation(setEnableDtraitMethod, (IMP)^void(id self, SEL _cmd, BOOL enabled) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    // 禁用 Dtrait
                    return;
                }
                void (*orig)(id, SEL, BOOL) = (void *)method_getImplementation(setEnableDtraitMethod);
                orig(self, _cmd, enabled);
            });
        }
    }
    
    // Hook TTInstallGFManager 禁用 GF 管理
    Class installGFManagerClass = NSClassFromString(@"TTInstallGFManager");
    if (installGFManagerClass) {
        // dtraitCollectConfigEmpty
        Method dtraitCollectConfigEmptyMethod = class_getInstanceMethod(installGFManagerClass, @selector(dtraitCollectConfigEmpty));
        if (dtraitCollectConfigEmptyMethod) {
            method_setImplementation(dtraitCollectConfigEmptyMethod, (IMP)^BOOL(id self, SEL _cmd) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return YES; // 返回空配置
                }
                BOOL (*orig)(id, SEL) = (void *)method_getImplementation(dtraitCollectConfigEmptyMethod);
                return orig(self, _cmd);
            });
        }
        
        // dtraitConfigFromFile
        Method dtraitConfigFromFileMethod = class_getInstanceMethod(installGFManagerClass, @selector(dtraitConfigFromFile));
        if (dtraitConfigFromFileMethod) {
            method_setImplementation(dtraitConfigFromFileMethod, (IMP)^id(id self, SEL _cmd) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return nil; // 返回空配置
                }
                id (*orig)(id, SEL) = (void *)method_getImplementation(dtraitConfigFromFileMethod);
                return orig(self, _cmd);
            });
        }
    }
    
    // Hook TTNetworkManager 替换 URL 中的 Bundle ID
    Class networkManagerClass = NSClassFromString(@"TTNetworkManager");
    if (networkManagerClass) {
        Method transferedURLMethod = class_getInstanceMethod(networkManagerClass, @selector(transferedURL:));
        if (transferedURLMethod) {
            method_setImplementation(transferedURLMethod, (IMP)^id(id self, SEL _cmd, id url) {
                id (*orig)(id, SEL, id) = (void *)method_getImplementation(transferedURLMethod);
                id originalURL = orig(self, _cmd, url);
                
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    return [DYYYLoginBypassManager URLByReplacingTargetBundleIdentifiers:originalURL];
                }
                
                return originalURL;
            });
        }
    }
    
    // Hook TTHttpRequest 替换 URL
    Class httpRequestClass = NSClassFromString(@"TTHttpRequest");
    if (httpRequestClass) {
        Method setURLMethod = class_getInstanceMethod(httpRequestClass, @selector(setURL:));
        if (setURLMethod) {
            method_setImplementation(setURLMethod, (IMP)^void(id self, SEL _cmd, id url) {
                if ([DYYYLoginBypassManager shouldApplyLoginNetworkCamouflage]) {
                    url = [DYYYLoginBypassManager URLByReplacingTargetBundleIdentifiers:url];
                }
                void (*orig)(id, SEL, id) = (void *)method_getImplementation(setURLMethod);
                orig(self, _cmd, url);
            });
        }
    }
}

@end
