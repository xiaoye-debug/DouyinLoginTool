#import "DYYYLoginBypassUtils.h"

@implementation DYYYLoginBypassUtils

+ (UIWindow *)getActiveWindow {
    UIWindow *keyWindow = nil;
    
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *window in scene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    return keyWindow;
}

+ (UIViewController *)topView {
    UIViewController *topVC = nil;
    UIWindow *window = [self getActiveWindow];
    
    if (window) {
        topVC = window.rootViewController;
        
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topVC;
            topVC = nav.visibleViewController;
        }
        
        if ([topVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topVC;
            topVC = tab.selectedViewController;
        }
    }
    
    return topVC;
}

+ (void)showToast:(NSString *)text {
    if (!text || text.length == 0) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topVC = [self topView];
        if (!topVC) return;
        
        UILabel *toastLabel = [[UILabel alloc] init];
        toastLabel.text = text;
        toastLabel.textColor = [UIColor whiteColor];
        toastLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        toastLabel.font = [UIFont systemFontOfSize:14];
        toastLabel.textAlignment = NSTextAlignmentCenter;
        toastLabel.layer.cornerRadius = 8;
        toastLabel.clipsToBounds = YES;
        toastLabel.numberOfLines = 0;
        
        CGFloat maxWidth = topVC.view.bounds.size.width - 80;
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: toastLabel.font}];
        CGFloat labelWidth = MIN(textSize.width + 20, maxWidth);
        CGFloat labelHeight = textSize.height + 16;
        
        toastLabel.frame = CGRectMake(0, 0, labelWidth, labelHeight);
        toastLabel.center = CGPointMake(topVC.view.center.x, topVC.view.bounds.size.height - 150);
        
        [topVC.view addSubview:toastLabel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                toastLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [toastLabel removeFromSuperview];
            }];
        });
    });
}

@end
