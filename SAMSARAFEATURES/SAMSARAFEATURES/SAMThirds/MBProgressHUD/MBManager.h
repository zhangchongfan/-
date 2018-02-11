//
//  MBManage.h
//  WYPHealthyThird
//
//  Created by 张冲 on 16/7/11.
//  Copyright © 2016年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface MBManager : NSObject
+ (MBProgressHUD *)showHUDWarnMessage:(NSString *)warn Model:(MBProgressHUDMode)model View:(UIView *)view;

+ (MBProgressHUD *)showHUDWarnMessage:(NSString *)warn Model:(MBProgressHUDMode)model View:(UIView *)view afterDelay:(NSTimeInterval)delay;

+ (MBProgressHUD *)addIndeterminateHUDToView:(UIView *)view;

@end
