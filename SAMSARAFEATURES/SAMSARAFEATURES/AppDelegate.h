//
//  AppDelegate.h
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/9/14.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPBleCentralManage.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) VPBleCentralManage *bleManager;

@property (nonatomic, copy) void(^locationBlock)(NSString *latitude, NSString *longitude);

+ (AppDelegate *)shareDelegate;

- (void)getCurrentLocation:(void(^)(NSString *latitude, NSString *longitude))locationBlock;

@end

