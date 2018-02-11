//
//  VPBleHelper.m
//  VeepooBleSDK
//
//  Created by 张冲 on 17/2/7.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import "VPBleHelper.h"
#import "SAConstantString.h"

NSString *const Ble_Main_Service = @"FFF0";
NSString *const Ble_Main_Con = @"FFF1";

@implementation VPBleHelper

+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID {
    for ( CBService *service in peripheral.services ) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

+ (void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                }
            }
        }
    }
}

#define CB(x) [CBUUID UUIDWithString:x]
#define VPDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
+ (BOOL)searchCharacteristicsWithService:(CBService *)service
{
    for (CBCharacteristic *c in service.characteristics) {
        if ([c.UUID isEqual:CB(Ble_Main_Con)]) {
            return YES;
        }
    }
    return NO;
}

+ (void)saveDeviceMessageWithVPPeripheralModel:(VPPeripheralModel *)peripheralModel DevicePassword:(NSString *)password {
    NSMutableDictionary *storeConnectDeviceMessage = [NSMutableDictionary dictionary];
    [storeConnectDeviceMessage setObject:peripheralModel.deviceAddress forKey:DeviceMacKey];
    [storeConnectDeviceMessage setObject:peripheralModel.peripheral.identifier.UUIDString forKey:DeviceUUIDKey];
    password = password == nil ? @"0000" : password;
    [storeConnectDeviceMessage setObject:password forKey:DevicePasswordKey];
    
    [[NSUserDefaults standardUserDefaults]setObject:peripheralModel.deviceAddress forKey:DeviceMacKey];
    [[NSUserDefaults standardUserDefaults]setObject:peripheralModel.peripheral.identifier.UUIDString forKey:DeviceUUIDKey];
    [[NSUserDefaults standardUserDefaults]setObject:password forKey:DevicePasswordKey];
    [[NSUserDefaults standardUserDefaults]setObject:storeConnectDeviceMessage forKey:DeviceMessageKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (NSDictionary *)getLastConnectDeviceMessage {
    NSDictionary *lastConnectDeviceMessage = [[NSUserDefaults standardUserDefaults]objectForKey:DeviceMessageKey];
    return lastConnectDeviceMessage;
}

//删除上次连接的设备信息
+ (void)deleteLastConnectDeviceMessage {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:DeviceMessageKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

/**
 获取上次连接设备的密码
 
 @return 上次连接设备的密码
 */
+ (NSString *)getLastConnectDevicePassword {
    NSString *devicePassword = [[NSUserDefaults standardUserDefaults]objectForKey:DevicePasswordKey] == nil ? @"0000" : [[NSUserDefaults standardUserDefaults]objectForKey:DevicePasswordKey];
    return devicePassword;
}

/**
 获取上次连接设备的地址
 
 @return 上次连接设备的地址
 */
+ (NSString *)getLastConnectDeviceAddress  {
    NSString *deviceAddress = [[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey] == nil ? @"012345678900" : [[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey];
    return deviceAddress;
}

+ (BOOL)justIsLastConnectDeviceWithVPPeripheralModel:(VPPeripheralModel *)peripheralModel {
    NSDictionary *lastConnectMessage = [[NSUserDefaults standardUserDefaults]objectForKey:DeviceMessageKey];
    if (lastConnectMessage == nil) {
        return NO;
    }
    NSString *lastBleMac = [lastConnectMessage objectForKey:DeviceMacKey];
    NSString *lastUUID = [lastConnectMessage objectForKey:DeviceUUIDKey];
    if ([lastBleMac isEqualToString:peripheralModel.deviceAddress] || [lastUUID isEqualToString:peripheralModel.peripheral.identifier.UUIDString]) {//如果MAC或者uid和上次有一个是一样的那么就是上次连接的设备
        return YES;
    }
    return NO;
}

@end
