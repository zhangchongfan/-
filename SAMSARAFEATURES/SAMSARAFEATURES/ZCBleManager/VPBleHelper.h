//
//  VPBleHelper.h
//  VeepooBleSDK
//
//  Created by 张冲 on 17/2/7.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "VPPeripheralModel.h"

extern NSString *const Ble_Main_Service;
extern NSString *const Ble_Main_Con;

@interface VPBleHelper : NSObject

+ (void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;

+ (void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;

+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

/**
 *  判断蓝牙是否包含某个服务
 *
 *  @param service 查询的服务
 *
 *  @return 有无
 */
+ (BOOL)searchCharacteristicsWithService:(CBService *)service;


/**
 储存当前连接设备的信息以供下次设备重新连接
 
 @param peripheralModel 设备模型
 @param password 设备的密码
 */
+ (void)saveDeviceMessageWithVPPeripheralModel:(VPPeripheralModel *)peripheralModel DevicePassword:(NSString *)password;


//删除上次连接的设备信息
+ (void)deleteLastConnectDeviceMessage;


/**
 获取上次连接的设备
 
 @return 上次连接设备的信息
 */
+ (NSDictionary *)getLastConnectDeviceMessage;

/**
 获取上次连接设备的密码
 
 @return 上次连接设备的密码
 */
+ (NSString *)getLastConnectDevicePassword;

/**
 获取上次连接设备的地址
 
 @return 上次连接设备的地址
 */
+ (NSString *)getLastConnectDeviceAddress;

/**
 判断是否是上次连接的设备
 
 @param peripheralModel 设备的模型
 @return 是否是上次连接的设备
 */
+ (BOOL)justIsLastConnectDeviceWithVPPeripheralModel:(VPPeripheralModel *)peripheralModel;

@end
