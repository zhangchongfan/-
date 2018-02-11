//
//  SAOpenRecordModel.h
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/10/25.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAConstantString.h"
@interface SAOpenRecordModel : NSObject

@property (nonatomic, assign) int type;

@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;
@property (nonatomic, assign) int totalTime;
@property (nonatomic, strong) NSString *saveTime;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, strong) NSString *showTime;

- (instancetype)initWithOpenData:(NSData *)data;

- (instancetype)initWithSaveTime:(NSString *)saveTime;

- (instancetype)initWithDatabaseDict:(NSDictionary *)dict;

- (NSDictionary *)changeOpenDict;
- (NSDictionary *)changeLostDict;

- (NSInteger)beforeCurrentTimeSecond;

@end

