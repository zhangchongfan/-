//
//  EBBannerWindow.m
//  demo
//
//  Created by 吴星辰 on 2017/10/23.
//  Copyright © 2017年 吴星辰. All rights reserved.
//

#import "EBBannerWindow.h"
#import "EBBannerViewController.h"
#import "EBBannerView+Categories.h"

@implementation EBBannerWindow

static EBBannerWindow *sharedWindow;
+(instancetype)sharedWindow{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWindow = [[self alloc] initWithFrame:CGRectZero];
        sharedWindow.windowLevel = UIWindowLevelAlert;
        sharedWindow.layer.masksToBounds = NO;
        UIWindow *originKeyWindow = UIApplication.sharedApplication.keyWindow;
        [sharedWindow makeKeyAndVisible];
        [originKeyWindow makeKeyAndVisible];
        
        EBBannerViewController *vc = [EBBannerViewController new];
        [EBBannerViewController setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape];
        [EBBannerViewController setStatusBarHidden:NO];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        sharedWindow.rootViewController = vc;
    });
    return sharedWindow;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    __block UIView *view;
    [self.rootViewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, point)) {
            view = obj;
        }
    }];
    if (view) {
        CGPoint point1 = [self convertPoint:point toView:view];
        return [view hitTest:point1 withEvent:event];
    }else{
        return [super hitTest:point withEvent:event];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"] && !CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = CGRectZero;
    }
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"frame"];
}

@end
