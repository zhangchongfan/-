//
//  LocalNotiFile.h
//  WYPHealthyThird
//
//  Created by 张冲 on 16/8/24.
//  Copyright © 2016年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotiFile : NSObject

+ (void)registImmediatelyNoticeWithContent:(NSString *)content;

+ (void)registrationSleepAndSportNotice;//注册睡眠和运动通知

+ (void)registrationDeviceFindPhoneNotice;//注册设备寻找手机的通知
@end
