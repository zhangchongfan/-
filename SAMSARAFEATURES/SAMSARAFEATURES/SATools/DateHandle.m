//
//  DateHandle.m
//  Veepoo_Health
//
//  Created by will on 14-10-20.
//  Copyright (c) 2014年 veepoo. All rights reserved.
//

#import "DateHandle.h"


@implementation DateHandle


- (id)initWithFormatterStr:(NSString *)format
{
    self = [super init];
    if (self) {
        self.formatter = [[NSDateFormatter alloc]init];
        [self.formatter setDateFormat:format];
        _currentDay = [NSDate date];
        sencondsPerDay  = 24 * 60 * 60;
        
        
    }
    return self;
}

- (NSString *)handleday:(BOOL)addOrcut withTwo:(BOOL)flag
{
    int i;
    i = addOrcut ? -1:1;
    NSDate* theDate  = [NSDate dateWithTimeInterval:sencondsPerDay * i sinceDate:_currentDay];
    _currentDay = theDate;
    NSString *d = [_formatter stringFromDate:_currentDay];
    if (flag) {
        theDate = [NSDate dateWithTimeInterval:sencondsPerDay * i sinceDate:_currentDay];
        d = [_formatter stringFromDate:theDate];
        return d;
    }
    else{
        
        return d;
    }
}


+ (NSString*)getLastPerDay:(NSInteger)day
{
    NSDate *date = [NSDate date];
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.timeStyle = kCFDateFormatterNoStyle;
    
    [f setDateFormat:@"yyyy/MM/dd Z"];
    NSCalendar *gregor = [NSCalendar currentCalendar];
    NSInteger daysToAdd = -1 * day;
    
    NSDateComponents *lasC = [[NSDateComponents alloc]init];
    [lasC setDay:daysToAdd];
    
    NSInteger unitF = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    
    NSDate *yest = [gregor dateByAddingComponents:lasC toDate:date options:0];
    
    NSDateComponents *comps = [gregor components:unitF fromDate:yest];
    
    NSInteger year  = [comps year];
    NSInteger month = [comps month];
    NSInteger dayz      = [comps day];
    NSString *ld = [NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)year,(long)month,(long)dayz];
    return ld;
}





- (NSDate *)getLastday
{
    NSDate *date = [NSDate dateWithTimeInterval:-sencondsPerDay  sinceDate:_currentDay];
    return date;
}



+ (NSString*)getTodayStrWithFormatter:(NSString*)formatStr
{
    NSString *s = nil;
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:formatStr];
    NSDate *d = [NSDate date];
    s = [f stringFromDate:d];
    return s;
}

- (NSString*)getDayStingWithDate:(NSDate *)tod
{
    NSString *d = [_formatter stringFromDate:tod];
    return d;
}

//将16进制转化为二进制
+ (NSString *)getBinaryByhex:(NSString *)hex
{
    
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1010" forKey:@"a"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1011" forKey:@"b"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1100" forKey:@"c"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1101" forKey:@"d"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1110" forKey:@"e"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    [hexDic setObject:@"1111" forKey:@"f"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [hex substringWithRange:rage];
        binaryString  = (NSMutableString*)[NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
    }
    return binaryString;
}
// 2000/12/12  to 2000-12-12
+ (NSString *)componentsDate:(NSString *)date withSpear:(NSString *)spear
{
    NSArray *dateArr = [date componentsSeparatedByString:spear];
    NSString *d = [NSString stringWithFormat:@"%@-%@-%@",dateArr[0],dateArr[1],dateArr[2]];
    return d;
}

+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
}

+(NSString *)localTime{
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:@"HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *timez = [f stringFromDate:date];
    return timez;
}


+(NSString *)servertimeToLocaltime:(NSString *)sertime withFormatStr:(NSString *)serverFormat toLocalFormat:(NSString*)localFormat
{
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:serverFormat];
    NSDate *date = [f dateFromString:sertime];
    
    [f setDateFormat:localFormat];
    NSString *localStr = [f stringFromDate:date];
    return localStr;
}

//expire time @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
// birth time @"@"yyyy-MM-dd'T'HH:mm:ssZ"  to yyyy
+ (NSString*)transformServerDateString:(NSString*)sertime withFormatStr:(NSString *)format
{
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:format];
    
    NSDate *date = [f dateFromString:sertime];
    NSString *serverTime = [f stringFromDate:date];
    return serverTime;
}

+ (NSString*)healthSouceDate:(NSString*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *healthdate = [formatter dateFromString:date];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *s = [formatter stringFromDate:healthdate];
    return s;
}

+ (NSInteger)userBirthDate:(NSString *)birth
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *healthdate = [formatter dateFromString:birth];
    [formatter setDateFormat:@"yyyy"];
    NSInteger s = [[formatter stringFromDate:healthdate] integerValue];
    return s;
}

//得到当前日期
+ (NSString *)getTheCurTimeWithYear:(BOOL)isHaveYear Mon:(BOOL)isHaveMon Day:(BOOL)isHaveDay Hour:(BOOL)isHaveHour Minut:(BOOL)isHaveMinut Second:(BOOL)isHaveSecond
{
    NSDate *date = [NSDate date];
    NSCalendar *gregor = [NSCalendar currentCalendar];
    
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.timeStyle = kCFDateFormatterNoStyle;
    
    [f setDateFormat:@"MM-dd-hh-mm-ss Z"];
    NSInteger unitF = NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitHour;
    
    
    NSDateComponents *comps = [gregor components:unitF fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger dayz  = [comps day];
    NSInteger hour  = [comps hour];
    NSInteger min   = [comps minute];
    NSInteger sec   = [comps second];
    
    NSString *currenttime = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)year,(long)month,(long)dayz,(long)hour,(long)min,(long)sec];
    if (isHaveMon&&isHaveDay&&isHaveHour&&isHaveMinut&&isHaveSecond) {
        return [NSString stringWithFormat:@"%02ld月%02ld日%02ld时%02ld分%02ld秒",(long)month,(long)dayz,(long)hour,(long)min,(long)sec];
    }else if (isHaveHour&&isHaveMinut&&isHaveSecond){
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)min,(long)sec];
    }else if (isHaveHour&&isHaveMinut){
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)min];
    }else if (isHaveMon) {
        currenttime = [NSString stringWithFormat:@"%02ld",(long)month];
    }else if (isHaveDay) {
        currenttime = [NSString stringWithFormat:@"%02ld",(long)dayz];
    }
    return currenttime;
}

//得到当前时间转化成多少分钟
+ (NSInteger)getTheCurTimeMinut
{
    NSDate *date = [NSDate date];
    NSCalendar *gregor = [NSCalendar currentCalendar];
    
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.timeStyle = kCFDateFormatterNoStyle;
    
    [f setDateFormat:@"MM-dd-hh-mm-ss Z"];
    NSInteger unitF = NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitHour;
    
    
    NSDateComponents *comps = [gregor components:unitF fromDate:date];
    NSInteger hour  = [comps hour];
    NSInteger min   = [comps minute];
    return hour*60 + min;
}
//距离time 小时的秒数
+ (NSInteger)getTheCurTimeWith:(NSInteger)time
{
    NSDate *date = [NSDate date];
    NSCalendar *gregor = [NSCalendar currentCalendar];
    
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.timeStyle = kCFDateFormatterNoStyle;
    
    [f setDateFormat:@"MM-dd-hh-mm-ss Z"];
    NSInteger unitF = NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitHour;
    
    NSDateComponents *comps = [gregor components:unitF fromDate:date];
    
    NSInteger hour  = [comps hour] *60*60;
    NSInteger min   = [comps minute]*60;
    NSInteger sec   = [comps second];
    return hour+min+sec-time*60*60;
}

+ (NSInteger)howMuchDaysFromDate:(NSDate *)fromDate toDate:(NSDate *)date{
    date = [DateHandle changetoYearMonDayDateWithDate:date];
    fromDate = [DateHandle changetoYearMonDayDateWithDate:fromDate];
    
    NSTimeInterval timeTerval = [date timeIntervalSinceDate:fromDate];
    return timeTerval/(24*3600);
}

+ (NSDate *)getOneDayStartTimeWithDayNumber:(NSInteger)dayNumber {
    NSString *dateString = [DateHandle getLastPerDay:dayNumber];
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [f dateFromString:dateString];
    return date;
}

+ (NSDate *)changetoYearMonDayDateWithDate:(NSDate *)date{
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [f setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateSp = [f stringFromDate:date];
    
    NSDate *yearMonDayDate = [f dateFromString:dateSp];
    return yearMonDayDate;
}

/**
 判断某个时间如2017-05-05 05：00 是过去还是未来
 
 @param compareTime 要和当前时间比较的日期
 @return 是否是过去
 */
+ (BOOL)justOneTimeIsLastWithTime:(NSString *)compareTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *compareDate = [dateFormatter dateFromString:compareTime];
    
    NSTimeInterval timeInterval = [compareDate timeIntervalSinceDate:[NSDate date]];
    
    return timeInterval <= 0 ? YES : NO;
}

//得到当前日期格式2017-05-01 07:01
+ (NSString *)getYearMonthDayHourMinuteSecondTime {
    NSDate *date = [NSDate date];
    NSCalendar *gregor = [NSCalendar currentCalendar];
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    f.locale =  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.timeStyle = kCFDateFormatterNoStyle;
    [f setDateFormat:@"yyyy-MM-dd-hh-mm-ss Z"];
    NSInteger unitF = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitHour;
    NSDateComponents *comps = [gregor components:unitF fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger dayz  = [comps day];
    NSInteger hour  = [comps hour];
    NSInteger min   = [comps minute];
    NSInteger sec   = [comps second];
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)year,(long)month,(long)dayz,(long)hour,(long)min,(long)sec];
}

@end
