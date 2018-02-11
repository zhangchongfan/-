//
//  DateHandle.h
//  Veepoo_Health
//
//  Created by will on 14-10-20.
//  Copyright (c) 2014年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHandle : NSObject
{
    NSTimeInterval sencondsPerDay;
}


@property(nonatomic,strong)NSDate *currentDay;
@property (nonatomic,strong)NSDateFormatter *formatter;

+ (NSString*)getTodayStrWithFormatter:(NSString*)formatStr;
+ (NSString*)getLastPerDay:(NSInteger)day;
- (NSString *)handleday:(BOOL)addOrcut withTwo:(BOOL)flag;
- (NSDate *)getLastday;
- (NSString*)getDayStingWithDate:(NSDate *)tod;
- (id)initWithFormatterStr:(NSString *)format;
+ (NSString *)getBinaryByhex:(NSString *)hex;
+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
+ (NSString *)componentsDate:(NSString *)date withSpear:(NSString *)spear;


/**
 *  本地时间 HH:mm:ss
 */
+(NSString *)localTime;
/**
 *  转换服务器数据时间格式
 *
 *  @param sertime 服务器时间
 */
+ (NSString*)transformServerDateString:(NSString*)sertime withFormatStr:(NSString *)format;


+(NSString *)servertimeToLocaltime:(NSString *)sertime withFormatStr:(NSString *)serverFormat toLocalFormat:(NSString*)localFormat;

+ (NSString*)healthSouceDate:(NSString*)date;
/**
 *  生日时间转换
 *
 *  @param birth 生日
 *
 *  @return 多少岁
 */
+ (NSInteger)userBirthDate:(NSString *)birth;


//得到当前日期
+ (NSString *)getTheCurTimeWithYear:(BOOL)isHaveYear Mon:(BOOL)isHaveMon Day:(BOOL)isHaveDay Hour:(BOOL)isHaveHour Minut:(BOOL)isHaveMinut Second:(BOOL)isHaveSecond;

//得到当前时间转化成多少分钟
+ (NSInteger)getTheCurTimeMinut;

//距离time 小时的秒数
+ (NSInteger)getTheCurTimeWith:(NSInteger)time;

//两个日期之间相差几天
+ (NSInteger)howMuchDaysFromDate:(NSDate *)fromDate toDate:(NSDate *)date;

+ (NSDate *)getOneDayStartTimeWithDayNumber:(NSInteger)dayNumber;


+ (NSDate *)changetoYearMonDayDateWithDate:(NSDate *)date;

/**
 判断某个时间如2017-05-05 05：00 是过去还是未来
 
 @param compareTime 要和当前时间比较的日期
 @return 是否是过去
 */
+ (BOOL)justOneTimeIsLastWithTime:(NSString *)compareTime;

//得到当前2015-12-05 08:10:05
+ (NSString *)getYearMonthDayHourMinuteSecondTime;

@end
