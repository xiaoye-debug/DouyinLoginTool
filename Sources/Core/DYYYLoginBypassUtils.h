#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYYYLoginBypassUtils : NSObject

+ (UIWindow *)getActiveWindow;
+ (UIViewController *)topView;
+ (void)showToast:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
