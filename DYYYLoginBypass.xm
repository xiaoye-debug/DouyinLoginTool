#import "DYYYLoginBypassManager.h"
#import "DYYYLoginRepairHooks.h"
#import "DYYYBypassSettingsPanel.h"
#import <UIKit/UIKit.h>

// 双指长按手势处理函数
static void DYYYHandleTwoFingerLongPress(id self, SEL _cmd, UILongPressGestureRecognizer *gesture) {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [DYYYBypassSettingsPanel show];
    }
}

// Hook 抖音主界面控制器
%hook AWEFeedContainerViewController

- (void)viewDidLoad {
    %orig;
    
    // 添加双指长按手势
    UILongPressGestureRecognizer *twoFingerLongPress = [[UILongPressGestureRecognizer alloc] 
        initWithTarget:self 
        action:@selector(dyyy_twoFingerLongPress:)];
    twoFingerLongPress.numberOfTouchesRequired = 2;
    twoFingerLongPress.minimumPressDuration = 0.8;
    
    // 动态添加方法
    Class cls = [self class];
    if (!class_getInstanceMethod(cls, @selector(dyyy_twoFingerLongPress:))) {
        class_addMethod(cls,
                       @selector(dyyy_twoFingerLongPress:),
                       (IMP)DYYYHandleTwoFingerLongPress,
                       "v24@0:8@16");
    }
    
    [self.view addGestureRecognizer:twoFingerLongPress];
}

%end

// Hook 登录成功
%hook AWEUserService

- (void)loginWithUserID:(NSString *)userID completion:(void (^)(BOOL))completion {
    %orig(userID, completion);
    [DYYYLoginBypassManager handleOfficialLoginCompletionWithUserID:userID];
}

%end

// Hook 登出
%hook AWEUserService

- (void)logout {
    %orig;
    [DYYYLoginBypassManager handleOfficialLogout];
}

%end

// 构造函数
%ctor {
    NSLog(@"[DYYYLoginBypass] 插件已加载");
    
    // 安装设备指纹 hook
    [DYYYLoginRepairHooks installHooks];
    
    // 初始化登录状态检测
    [DYYYLoginBypassManager configureInitialStateIfNeeded];
    
    NSLog(@"[DYYYLoginBypass] 初始化完成");
}
