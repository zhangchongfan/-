//
//  MBManage.m
//  WYPHealthyThird
//
//  Created by 张冲 on 16/7/11.
//  Copyright © 2016年 veepoo. All rights reserved.
//

#import "MBManager.h"
@implementation MBManager

+ (MBProgressHUD *)showHUDWarnMessage:(NSString *)warn Model:(MBProgressHUDMode)model View:(UIView *)view
{
    static MBProgressHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[MBProgressHUD alloc]init];
    });
    hud.labelText = @"";
    hud.backgroundColor = [UIColor clearColor];
    hud.mode = model;
    
    if (model == MBProgressHUDModeText) {
        hud.labelText = warn;
        [hud hide:YES afterDelay:1.0];
    }
    [hud show:YES];
    [view addSubview:hud];
    return hud;
}

+ (MBProgressHUD *)showHUDWarnMessage:(NSString *)warn Model:(MBProgressHUDMode)model View:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    static MBProgressHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[MBProgressHUD alloc]init];
    });
    hud.labelText = @"";
    hud.backgroundColor = [UIColor clearColor];
    hud.mode = model;
    
    if (model == MBProgressHUDModeText) {
        hud.labelText = warn;
        [hud hide:YES afterDelay:delay];
    }
    [hud show:YES];
    [view addSubview:hud];
    return hud;
}

+ (MBProgressHUD *)addIndeterminateHUDToView:(UIView *)view {
    MBProgressHUD *hud = [[MBProgressHUD alloc]init];
    hud.mode = MBProgressHUDModeIndeterminate;
    [view addSubview:hud];
    [hud show:YES];
    return hud;
}

@end
