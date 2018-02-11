//
//  TPBGTask.m
//  SmartCharger
//
//  Created by chendi on 2017/5/31.
//  Copyright © 2017年 Techpreneurs.pk. All rights reserved.
//

#import "TPBGTask.h"

@interface TPBGTask()
@property (nonatomic, strong) NSMutableArray *bgTaskIdList;
@property (assign) UIBackgroundTaskIdentifier masterTaskId;
@end

@implementation TPBGTask

+ (instancetype)shareBGTask{
    static TPBGTask *task;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task = [[TPBGTask alloc] init];
    });
    return task;
}

- (instancetype)init{
    if (self = [super init]) {
        _bgTaskIdList = [NSMutableArray array];
        _masterTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if ([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"bgTask 过期 %lu", (unsigned long)bgTaskId);
            [self.bgTaskIdList removeObject:@(bgTaskId)];
            [application endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }];
    }
    if (_masterTaskId == UIBackgroundTaskInvalid) {
        self.masterTaskId = bgTaskId;
        [self.bgTaskIdList addObject:@(bgTaskId)];
        NSLog(@"开启后台任务 %lu",(unsigned long)bgTaskId);
    }else{
        NSLog(@"保持后台任务 %lu", (unsigned long)bgTaskId);
        [self.bgTaskIdList addObject:@(bgTaskId)];
        [self endBackGroundTask:NO];
    }
    return bgTaskId;
}

- (void)endBackGroundTask:(BOOL)all{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(endBackgroundTask:)]) {
        for (int i = 0; i < (all ? _bgTaskIdList.count :_bgTaskIdList.count -1); i++) {
            UIBackgroundTaskIdentifier bgTaskId = [self.bgTaskIdList[0]integerValue];
            NSLog(@"关闭后台任务 %lu",(unsigned long)bgTaskId);
            [application endBackgroundTask:bgTaskId];
            [self.bgTaskIdList removeObjectAtIndex:0];
        }
    }
    if(self.bgTaskIdList.count > 0){
        NSLog(@"后台任务正在保持运行 %ld",(long)[_bgTaskIdList[0]integerValue]);
    }
    if(all){
        [application endBackgroundTask:self.masterTaskId];
        self.masterTaskId = UIBackgroundTaskInvalid;
    }else{
        NSLog(@"kept master background task id %lu", (unsigned long)self.masterTaskId);
    }
}

@end
