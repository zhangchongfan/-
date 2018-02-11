//
//  SAConstantString.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/9/14.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SAConstantString.h"

@implementation SAConstantString

@end
//
//  DBConstantString.h
//  WYPHealthyThird
//
//  Created by 张冲 on 16/7/18.
//  Copyright © 2016年 veepoo. All rights reserved.
//

NSString *const WYP_DB_NAME = @"wypDataBase.sqlite";//数据库名称
NSString *const DBKEY = @"888^Wyp";//数据库密码

NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
json TEXT NOT NULL, \
createdTime TEXT,\
accountUser TEXT,\
userCreatedTime TEXT,\
dataVersion TEXT, \
PRIMARY KEY(userCreatedTime))\
";//创建某个表
NSString *const SELECT_LAST_DATA = @"SELECT * from %@ where createdTime < '%@' and createdTime > '%@' and accountUser = '%@'";//选取某段时间的数据
NSString *const UPDATE_HEART_SQL = @"REPLACE INTO %@ (json, createdTime,accountUser,userCreatedTime,dataVersion) values (?, ? ,?,?,?)";//更新表
NSString *const QUERY_STEPORSLEEP_SQL = @"SELECT json from %@ where createdTime = ?";//选择某一天的数据

NSString *const QUERY_SEVENDAY = @"SELECT * from %@ order by createdTime desc Limit 7";//选择7天内的有效数据倒序

NSString *const QUERY_HEART_SQL = @"SELECT json,createdTime,dataVersion from %@ where userCreatedTime = ?";//从某个表取出数据  创造时间  版本号 根据userCreatedTime

NSString *const QUERY_DataVersion_SQL = @"SELECT dataVersion,createdTime from %@ where userCreatedTime = ?";//从某个表取出创造时间  版本号 根据userCreatedTime

NSString *const SELECT_ALL_SQL = @"SELECT * from %@ where accountUser = ? ORDER BY createdTime DESC";//取出某个表所有的数据，根据账号 倒序

NSString *const SELECT_ZERO_SQL = @"SELECT * from %@ where dataVersion = ? ORDER BY createdTime DESC";

NSString *const SELECT_OBJ_SQL = @"SELECT createdTime from %@ where accountUser = ? ORDER BY createdTime ASC";//根据账号取出某个表的所有创造日期 递增

NSString *const SELECT_VESION_SQL = @"SELECT * from %@ where userCreatedTime = ?";//删除用户某天的数据

NSString *const CLEAR_ALL_SQL = @"DELETE from '%@'";//删除某个表

NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where userCreatedTime = ? ";//删除某个表内的某个用户一天数据
NSString *const DELETE_ITEM_WITH_DATE = @"DELETE from %@ where userCreatedTime = '%@'";//删除某个表内某个用户一天的数据

NSString *const UPDATE_STEP_SQL  = @"update %@ set json = ? where createdTime = '%@' and userCreatedTime = '%@'";

//存储设备信息的key
NSString *const DeviceUUIDKey = @"deviceUUIDKey";
NSString *const DeviceMacKey = @"deviceMacKey";
NSString *const DevicePasswordKey = @"devicePasswordKey";
NSString *const DeviceMessageKey = @"deviceMessageKey";
NSString *const BangMacKey = @"bangMacKey";
NSString *const StatureKey = @"statureKey";
NSString *const DeviceBatteryLever = @"deviceBatteryLever";
NSString *const DeviceAlarmClockMessage = @"DeviceAlarmClockMessage";

//
NSString *const HistoryType = @"HistoryType";
NSString *const OpenYearKey = @"OpenYearKey";
NSString *const OpenMonthKey = @"OpenMonthKey";
NSString *const OpenDayKey = @"OpenDayKey";
NSString *const OpenHourKey = @"OpenHourKey";
NSString *const OpenMinuteKey = @"OpenMinuteKey";
NSString *const OpenSecondKey = @"OpenSecondKey";
NSString *const OpenTotalTimeKey = @"OpenTotalTimeKey";
NSString *const LostlatitudeKey = @"LostlatitudeKey";
NSString *const LostlongitudeKey = @"LostlongitudeKey";

NSString *const OpenBox_table = @"OpenBox_table";
NSString *const Lost_table = @"Lost_table";

NSString *const OpenBoxNoti = @"OpenBoxNoti";
NSString *const RSSINoti = @"RSSINoti";
