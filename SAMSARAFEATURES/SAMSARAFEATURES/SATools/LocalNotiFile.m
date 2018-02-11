//
//  LocalNotiFile.m
//  WYPHealthyThird
//
//  Created by 张冲 on 16/8/24.
//  Copyright © 2016年 veepoo. All rights reserved.
//

#import "LocalNotiFile.h"
#import "EBBannerView.h"
NSString *const SleepNotiKey = @"sleepNotiKey";
NSString *const SportNotiKey = @"sportNotiKey";
@implementation LocalNotiFile

+ (void)registrationSleepAndSportNotice{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    BOOL haveSleepNoti = NO;
    BOOL haveSportNoti = NO;
    //获取当前所有的本地通知
    if (notificaitons || notificaitons.count > 0) {
        for (UILocalNotification *notify in notificaitons) {
            if ([[notify.userInfo objectForKey:SleepNotiKey] isEqualToString:SleepNotiKey]) {
                //取消一个特定的通知
                haveSleepNoti = YES;
            }
            if ([[notify.userInfo objectForKey:SportNotiKey] isEqualToString:SportNotiKey]) {
                //取消一个特定的通知
                haveSportNoti = YES;
            }
        }
    }
}

+ (void)registNoticeWithTime:(NSTimeInterval)timeInterval key:(NSString *)key content:(NSString *)content {
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    //触发通知的时间
//    NSDate *now = [formatter dateFromString:time];
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    notice.fireDate = now;
    
    //时区
    notice.timeZone = [NSTimeZone defaultTimeZone];
    //通知重复提示的单位，可以是天、周、月
    //
    notice.repeatInterval = NSCalendarUnitDay;
    
    //通知内容
    notice.userInfo = @{key:key};
    notice.alertBody = content;
    
    //通知被触发时播放的声音
    notice.soundName = UILocalNotificationDefaultSoundName;
    
    //执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
}

+ (void)registrationDeviceFindPhoneNotice{//注册设备寻找手机的通知
    
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    BOOL haveFinePhoneNoti = NO;
    //获取当前所有的本地通知
    if (notificaitons || notificaitons.count > 0) {
        for (UILocalNotification *notify in notificaitons) {
            if ([[notify.userInfo objectForKey:@"FindPhoneNotiKey"] isEqualToString:@"FindPhoneNotiKey"]) {
                //取消一个特定的通知
                haveFinePhoneNoti = YES;
            }
        }
        if (haveFinePhoneNoti) {
//            return;
        }
    }
    
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    
    //触发通知的时间
    NSDate *now = [NSDate date];
    notice.fireDate = now;
    
    //时区
    notice.timeZone = [NSTimeZone defaultTimeZone];
    
    //通知重复提示的单位，可以是天、周、月
    notice.repeatInterval = kCFCalendarUnitMinute;
    
    //通知内容
    notice.userInfo = @{@"FindPhoneNotiKey":@"FindPhoneNotiKey"};
    notice.alertBody = @"设备正在查找手机";
    
    //通知被触发时播放的声音
    notice.soundName = UILocalNotificationDefaultSoundName;
    
    //执行通知注册
//    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
}

+ (void)registImmediatelyNoticeWithContent:(NSString *)content {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [EBBannerView showWithContent:content];
        return;
    }
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    notice.fireDate = [NSDate date];
    //时区
    notice.timeZone = [NSTimeZone defaultTimeZone];
    
    if ([content isEqualToString:@"Your suitcase opened while you were away, Open \"Log History\" for details."]) {
        //通知内容
        notice.userInfo = @{@"DisconnectOpenBoxNoti":@"openBox"};
    }else {
        //通知内容
        notice.userInfo = @{@"OpenBoxLocalNoti":@"OpenBoxLocalNoti"};
    }
    
    
    
    notice.alertBody = content;
    
    //通知被触发时播放的声音
    notice.soundName = UILocalNotificationDefaultSoundName;
    
    //执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
}


@end
