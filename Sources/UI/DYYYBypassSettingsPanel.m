#import "DYYYBypassSettingsPanel.h"
#import "DYYYLoginBypassManager.h"
#import "DYYYLoginBypassUtils.h"

static NSString *const kDYYYLoginBypassEnabledKey = @"DYYYLoginBypassEnabled";

@implementation DYYYBypassSettingsPanel

+ (void)show {
    UIWindow *window = [DYYYLoginBypassUtils getActiveWindow];
    if (!window) return;
    
    // 移除已存在的面板
    for (UIView *subview in window.subviews) {
        if ([subview isKindOfClass:[DYYYBypassSettingsPanel class]]) {
            [subview removeFromSuperview];
        }
    }
    
    DYYYBypassSettingsPanel *panel = [[DYYYBypassSettingsPanel alloc] initWithFrame:window.bounds];
    [window addSubview:panel];
    [panel showWithAnimation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        // 创建卡片视图
        UIView *cardView = [[UIView alloc] init];
        cardView.backgroundColor = [UIColor whiteColor];
        cardView.layer.cornerRadius = 16;
        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:cardView];
        
        // 标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"绕过登录设置";
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:titleLabel];
        
        // 开关
        UISwitch *bypassSwitch = [[UISwitch alloc] init];
        bypassSwitch.on = [DYYYLoginBypassManager isLoginBypassEnabled];
        [bypassSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        bypassSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:bypassSwitch];
        
        // 状态标签
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.text = bypassSwitch.isOn ? @"状态：已开启" : @"状态：已关闭";
        statusLabel.font = [UIFont systemFontOfSize:14];
        statusLabel.textColor = [UIColor grayColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:statusLabel];
        
        // 提示标签
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.text = @"双指长按可打开此设置面板";
        hintLabel.font = [UIFont systemFontOfSize:12];
        hintLabel.textColor = [UIColor lightGrayColor];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:hintLabel];
        
        // 关闭按钮
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
        closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:closeButton];
        
        // 布局约束
        [NSLayoutConstraint activateConstraints:@[
            // 卡片居中
            [cardView centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [cardView centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [cardView widthAnchor constraintEqualToConstant:280],
            [cardView heightAnchor constraintEqualToConstant:220],
            
            // 标题
            [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:20],
            [titleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
            [titleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
            
            // 开关
            [bypassSwitch.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
            [bypassSwitch.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],
            
            // 状态标签
            [statusLabel.topAnchor constraintEqualToAnchor:bypassSwitch.bottomAnchor constant:15],
            [statusLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
            [statusLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
            
            // 提示标签
            [hintLabel.topAnchor constraintEqualToAnchor:statusLabel.bottomAnchor constant:10],
            [hintLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
            [hintLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
            
            // 关闭按钮
            [closeButton.topAnchor constraintEqualToAnchor:hintLabel.bottomAnchor constant:15],
            [closeButton.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],
        ]];
        
        // 点击背景关闭
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)switchChanged:(UISwitch *)sender {
    [DYYYLoginBypassManager setLoginBypassEnabled:sender.isOn];
    
    // 更新状态标签
    UILabel *statusLabel = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text hasPrefix:@"状态："]) {
                statusLabel = label;
                break;
            }
        }
    }
    
    if (statusLabel) {
        statusLabel.text = sender.isOn ? @"状态：已开启" : @"状态：已关闭";
    }
    
    [DYYYLoginBypassUtils showToast:sender.isOn ? @"绕过登录已开启" : @"绕过登录已关闭"];
}

- (void)closeTapped {
    [self hideWithAnimation];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    
    // 检查是否点击在卡片外
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:[UIView class]] || subview == self) continue;
        if (CGRectContainsPoint(subview.frame, location)) {
            return; // 点击在卡片内，不关闭
        }
    }
    
    [self hideWithAnimation];
}

- (void)showWithAnimation {
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
