//
//  SAOpenRecordModel.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/10/25.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SAOpenRecordModel.h"

@implementation SAOpenRecordModel

- (instancetype)initWithOpenData:(NSData *)data {
    self = [super init];
    if (self) {
        const uint8_t *tbyte = data.bytes;
        _type = 0;
        _year = tbyte[2] << 8 | tbyte[3];
        _month = tbyte[4];
        _day = tbyte[5];
        _hour = tbyte[6];
        _minute = tbyte[7];
        _second = tbyte[8];
        _saveTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",_year,_month,_day,_hour,_minute,_second];
        
        NSInteger openTimeInteval = tbyte[9] << 16 | tbyte[10] << 8 | tbyte[11];
        NSDateFormatter *f = [[NSDateFormatter alloc]init];
        [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [f dateFromString:_saveTime];
        date = [date dateByAddingTimeInterval:openTimeInteval];
        _saveTime = [f stringFromDate:date];
        NSArray *saveTimeArray = [_saveTime componentsSeparatedByString:@" "];
        NSString *firstComponet = saveTimeArray[0];
        NSString *secondComponet = saveTimeArray[1];
        NSArray *firstComponetArray = [firstComponet componentsSeparatedByString:@"-"];
        NSArray *secondComponetArray = [secondComponet componentsSeparatedByString:@":"];
        _year = [firstComponetArray[0] intValue];
        _month = [firstComponetArray[1] intValue];
        _day = [firstComponetArray[2] intValue];
        _hour = [secondComponetArray[0] intValue];
        _minute = [secondComponetArray[1] intValue];
        _second = [secondComponetArray[2] intValue];
        if (!(_year > 2016 && _month <= 12 && _day <= 31 && _hour < 24 && _minute < 60 && _second < 60)) {//时间不合法
            
        }
    }
    return self;
}

- (instancetype)initWithSaveTime:(NSString *)saveTime {
    self = [super init];
    if (self) {
        _type = 1;
        _saveTime = saveTime;
        NSArray *saveTimeArray = [saveTime componentsSeparatedByString:@" "];
        NSString *firstComponet = saveTimeArray[0];
        NSString *secondComponet = saveTimeArray[1];
        NSArray *firstComponetArray = [firstComponet componentsSeparatedByString:@"-"];
        NSArray *secondComponetArray = [secondComponet componentsSeparatedByString:@":"];
        _year = [firstComponetArray[0] intValue];
        _month = [firstComponetArray[1] intValue];
        _day = [firstComponetArray[2] intValue];
        _hour = [secondComponetArray[0] intValue];
        _minute = [secondComponetArray[1] intValue];
        _second = [secondComponetArray[2] intValue];
        _latitude = @"0";
        _longitude = @"0";
    }
    return self;
}

- (instancetype)initWithDatabaseDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        int type = [dict[HistoryType] intValue];
        _type = type;
        _year = [dict[OpenYearKey] intValue];
        _month = [dict[OpenMonthKey] intValue];
        _day = [dict[OpenDayKey] intValue];
        _hour = [dict[OpenHourKey] intValue];
        _minute = [dict[OpenMinuteKey] intValue];
        _second = [dict[OpenSecondKey] intValue];
        _saveTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",_year,_month,_day,_hour,_minute,_second];
        if (_type == 0) {//开
            _totalTime = [dict[OpenTotalTimeKey] intValue];
        }else {//丢
            _latitude = dict[LostlatitudeKey];
            _longitude = dict[LostlongitudeKey];
        }
    }
    return self;
}

- (NSDictionary *)changeLostDict {
    return @{
             HistoryType:@"1",
             OpenYearKey:[NSString stringWithFormat:@"%04d",_year],
             OpenMonthKey:[NSString stringWithFormat:@"%02d",_month],
             OpenDayKey:[NSString stringWithFormat:@"%02d",_day],
             OpenHourKey:[NSString stringWithFormat:@"%02d",_hour],
             OpenMinuteKey:[NSString stringWithFormat:@"%02d",_minute],
             OpenSecondKey:[NSString stringWithFormat:@"%02d",_second],
             LostlatitudeKey:_latitude,
             LostlongitudeKey:_longitude
             };
}

- (NSDictionary *)changeOpenDict {
    return @{
             HistoryType:@"0",
             OpenYearKey:[NSString stringWithFormat:@"%04d",_year],
             OpenMonthKey:[NSString stringWithFormat:@"%02d",_month],
             OpenDayKey:[NSString stringWithFormat:@"%02d",_day],
             OpenHourKey:[NSString stringWithFormat:@"%02d",_hour],
             OpenMinuteKey:[NSString stringWithFormat:@"%02d",_minute],
             OpenSecondKey:[NSString stringWithFormat:@"%02d",_second],
             OpenTotalTimeKey:[NSString stringWithFormat:@"%d",_totalTime]
             };
}

- (NSString *)showTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:_saveTime];
    [dateFormatter setDateFormat:@"MMM dd, HH:mm"];
    return [dateFormatter stringFromDate:date];
}

- (NSInteger)beforeCurrentTimeSecond {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *saveDate = [dateFormatter dateFromString:self.saveTime];
    NSInteger interval = [[NSDate date] timeIntervalSinceDate:saveDate];
    return interval;
}

@end
