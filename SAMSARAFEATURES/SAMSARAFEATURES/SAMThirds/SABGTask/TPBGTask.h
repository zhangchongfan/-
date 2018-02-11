//
//  TPBGTask.h
//  SmartCharger
//
//  Created by chendi on 2017/5/31.
//  Copyright © 2017年 Techpreneurs.pk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TPBGTask : NSObject

+ (instancetype)shareBGTask;
//开启后台任务
- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

@end
