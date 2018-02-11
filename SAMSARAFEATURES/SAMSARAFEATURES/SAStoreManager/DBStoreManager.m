//
//  DBStoreManager.m
//  WYPHealthyThird
//
//  Created by 张冲 on 16/7/18.
//  Copyright © 2016年 veepoo. All rights reserved.
//

#import "DBStoreManager.h"
#import "DateHandle.h"
#import "FMDB.h"
@implementation DBStoreItem
static NSString *const SA_DB_NAME = @"SADataBase.sqlite";//数据库名称
static NSString *const DBKEY = @"888^SA";//数据库密码

static NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
json TEXT NOT NULL, \
createdTime TEXT,\
accountUser TEXT,\
userCreatedTime TEXT,\
dataVersion TEXT, \
PRIMARY KEY(userCreatedTime))\
";//创建某个表

static NSString *const SELECT_LAST_DATA = @"SELECT * from %@ where createdTime < '%@' and createdTime > '%@' and accountUser = '%@'";//选取某段时间的数据

static NSString *const UPDATE_HEART_SQL = @"REPLACE INTO %@ (json, createdTime,accountUser,userCreatedTime,dataVersion) values (?, ? ,?,?,?)";//更新表

static NSString *const QUERY_STEPORSLEEP_SQL = @"SELECT json from %@ where createdTime = ?";//选择某一天的数据

static NSString *const QUERY_SEVENDAY = @"SELECT * from %@ order by createdTime desc Limit 7";//选择7天内的有效数据倒序

static NSString *const QUERY_HEART_SQL = @"SELECT json,createdTime,dataVersion from %@ where userCreatedTime = ?";//从某个表取出数据  创造时间  版本号 根据userCreatedTime

static NSString *const QUERY_DataVersion_SQL = @"SELECT dataVersion,createdTime from %@ where userCreatedTime = ?";//从某个表取出创造时间  版本号 根据userCreatedTime

static NSString *const SELECT_ALL_SQL = @"SELECT * from %@ where accountUser = ? ORDER BY createdTime DESC";//取出某个表所有的数据，根据账号 倒序

static NSString *const SELECT_ZERO_SQL = @"SELECT * from %@ where dataVersion = ? ORDER BY createdTime DESC";

static NSString *const SELECT_OBJ_SQL = @"SELECT createdTime from %@ where accountUser = ? ORDER BY createdTime ASC";//根据账号取出某个表的所有创造日期 递增

static NSString *const SELECT_VESION_SQL = @"SELECT * from %@ where userCreatedTime = ?";//删除用户某天的数据

static NSString *const CLEAR_ALL_SQL = @"DELETE from '%@'";//删除某个表的所有数据

static NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where userCreatedTime = ? ";//删除某个表内的某个用户一天数据

static NSString *const DELETE_ITEM_WITH_DATE = @"DELETE from %@ where userCreatedTime = '%@'";//删除某个表内某个用户一天的数据

static NSString *const UPDATE_STEP_SQL  = @"update %@ set json = ? where createdTime = '%@' and userCreatedTime = '%@'";

- (NSString *)description {
    return [NSString stringWithFormat:@"Value=%@, TimeStamp=%@, DataVerssion=%@", _objectValue, _createdTime, _dataVerssion];
}
@end

@interface DBStoreManager()
@property (nonatomic ,strong) FMDatabaseQueue * dbQueue;
@end

@implementation DBStoreManager

+ (instancetype)shareStoreManager {
    static DBStoreManager *storeManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        storeManager = [[self alloc]init];
        //创建表
        [storeManager createTableWithName:OpenBox_table];
    });
    return storeManager;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString * dbPath = [SADocumentPath stringByAppendingPathComponent:SA_DB_NAME];
        
        if (_dbQueue) {
            [self closeDataBase];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        __block BOOL result;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            /**
             *  设置数据库密码
             */
            result = [db setKey:DBKEY];
        }];
    }
    return self;
}

- (void)createTableWithName:(NSString *)tableName {//创建表
    NSString * sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"创建表失败: %@", tableName);
    }
}

- (void)deleteAllDataWithTabalName:(NSString *)tableName {
    NSString * sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"删除表内所有数据失败");
    }
}

- (void)deleteObjectByDeviceAddress:(NSString *)DeviceAddress CreateTime:(NSString *)time withTable:(NSString *)tableName {
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",DeviceAddress,time];
    
    
    NSString * sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, userCreateTime];
        
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete item from table: %@", tableName);
    }
}

//保存数据到数据库
- (void)putObject:(id)object DeviceAddress:(NSString *)deviceAddress withTime:(NSString *)createTime intoTable:(NSString *)tableName withDataVession:(NSString *)vession
{
    if (object == nil||createTime==nil) {
        return;
    }
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (error) {
        NSLog(@"ERROR, put object faild to get json data");
        return;
    }
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    
    NSString * sql = [NSString stringWithFormat:UPDATE_HEART_SQL, tableName];
    
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",deviceAddress,createTime];
    __block BOOL result = false;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, jsonString, createTime,deviceAddress,userCreateTime,vession];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to insert/replace into table: %@", tableName);
    }
}


- (void)updateObject:(id)object withTime:(NSString *)timeObj DeviceAddress:(NSString *)DeviceAddress intoTable:(NSString *)tableName {
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        return;
    }
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",DeviceAddress,timeObj];
    
    NSString * sql = [NSString stringWithFormat:UPDATE_STEP_SQL, tableName,timeObj,userCreateTime];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, jsonString];
    }];
    if (!result) {
        NSLog(@"更新表失败: %@", tableName);
    }
}

- (DBStoreItem *)getYTKKeyValueItemByDate:(NSString *)timeID DeviceAddress:(NSString *)DeviceAddress fromTable:(NSString *)tableName {
    NSString * sql = [NSString stringWithFormat:QUERY_HEART_SQL, tableName];
    
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",DeviceAddress,timeID];
    
    __block NSString * json = nil;
    __block NSString *createdTime = nil;
    __block NSString *dataVersion = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * rs = [db executeQuery:sql,userCreateTime];
        if ([rs next]) {
            
            json = [rs stringForColumn:@"json"];
            createdTime = [rs stringForColumn:@"createdTime"];
            dataVersion = [rs stringForColumn:@"dataVersion"];
        }
        [rs close];
    }];
    
    if (json) {
        NSError * error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            NSLog(@"ERROR, 解析json失败=%@",tableName);
            return nil;
        }
        DBStoreItem * item = [[DBStoreItem alloc] init];
        item.objectValue = result;
        item.createdTime = createdTime;
        item.dataVerssion = dataVersion;
        return item;
    }
    return nil;
}

- (NSArray *)getTimeItemsFromTable:(NSString *)tableName withDeviceAddress:(NSString *)DeviceAddress
{
    NSString * sql = [NSString stringWithFormat:SELECT_OBJ_SQL,tableName];
    
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * rs = [db executeQuery:sql,DeviceAddress];
        
        while ([rs next]) {
            DBStoreItem * item = [[DBStoreItem alloc] init];
            item.createdTime = [rs stringForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    return result;
}

- (NSString *)getDataVersionWithCreatTime:(NSString *)timeID DeviceAddress:(NSString *)deviceAddress fromTable:(NSString *)tableName {//根据表内某个账户和创造日期，取出当天的数据版本号
    NSString * sql = [NSString stringWithFormat:QUERY_DataVersion_SQL, tableName];
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",deviceAddress,timeID];
    __block NSString * dataVersion = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql,userCreateTime];
        if ([rs next]) {
            dataVersion = [rs stringForColumn:@"dataVersion"];
        }
        [rs close];
    }];
    return dataVersion;
}

- (NSArray *)getAllItemsFromTable:(NSString *)tableName withDeviceAddress:(NSString *)userAccout{
    if (tableName == nil || userAccout == nil) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql,userAccout];
        while ([rs next]) {
            
            DBStoreItem * item = [[DBStoreItem alloc] init];
            item.objectValue = [rs stringForColumn:@"json"];
            item.createdTime = [rs stringForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    
    NSError * error;
    for (DBStoreItem * item in result) {
        error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[item.objectValue dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        
        if (error) {
            NSLog(@"ERROR, 解析数据失败=%@",tableName);
        } else {
            item.objectValue = object;
        }
    }
    return result;
}

- (void)deleteObjectByCreatedDate:(NSString*)createdDate DeviceAddress:(NSString *)DeviceAddress withTable:(NSString*)tableName {
    NSString *userCreateTime = [NSString stringWithFormat:@"%@{%@",DeviceAddress,createdDate];
    NSString *sql = [NSString stringWithFormat:DELETE_ITEM_WITH_DATE,tableName,userCreateTime];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db){
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR,删除失败 %@-%@",tableName,createdDate);
    }
}


- (void)closeDataBase {//关闭数据库操作
    [_dbQueue close];
    _dbQueue = nil;
}
@end
