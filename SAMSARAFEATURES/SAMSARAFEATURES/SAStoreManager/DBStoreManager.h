//
//  DBStoreManager.h
//  WYPHealthyThird
//
//  Created by 张冲 on 16/7/18.
//  Copyright © 2016年 veepoo. All rights reserved.
//





#import <Foundation/Foundation.h>

@interface DBStoreItem : NSObject
@property (nonatomic, strong) id objectValue;
@property (nonatomic, strong) NSString *createdTime;
@property (nonatomic, strong) NSString *dataVerssion;
@end


@interface DBStoreManager : NSObject
+ (instancetype)shareStoreManager;

- (void)createTableWithName:(NSString *)tableName;//创建表
- (void)deleteObjectByDeviceAddress:(NSString *)DeviceAddress CreateTime:(NSString *)time withTable:(NSString *)tableName;
- (void)deleteAllDataWithTabalName:(NSString *)tableName;
- (void)putObject:(id)object DeviceAddress:(NSString *)DeviceAddress withTime:(NSString *)createTime intoTable:(NSString *)tableName withDataVession:(NSString *)vession;//存放一天的数据
- (void)updateObject:(id)object withTime:(NSString *)timeObj DeviceAddress:(NSString *)user intoTable:(NSString *)tableName;//更新表内某一天的数据
- (DBStoreItem *)getYTKKeyValueItemByDate:(NSString *)timeID DeviceAddress:(NSString *)DeviceAddress fromTable:(NSString *)tableName;//获取表内某个账户某一天的数据
- (NSArray *)getTimeItemsFromTable:(NSString *)tableName withDeviceAddress:(NSString *)DeviceAddress;//得到某个表内某个账户的所有日期
- (NSString *)getDataVersionWithCreatTime:(NSString *)timeID DeviceAddress:(NSString *)DeviceAddress  fromTable:(NSString *)tableName;//根据表内某个账户和创造日期，取出当天的数据版本号
- (NSArray *)getAllItemsFromTable:(NSString *)tableName withDeviceAddress:(NSString *)userAccout;//取出某个用户某个表内所有的数据

@end































