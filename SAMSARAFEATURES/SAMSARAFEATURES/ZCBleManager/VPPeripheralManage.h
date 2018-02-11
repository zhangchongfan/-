//
//  VPPeripheralManage.h
//  VPBleSdk
//
//  Created by 张冲 on 17/1/11.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPBleHelper.h"
#import "VPPeripheralModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface VPPeripheralManage : NSObject<CBPeripheralDelegate>

//连接的设备模型
@property (nonatomic, strong) VPPeripheralModel *peripheralModel;

@property (nonatomic, copy) void(^readFirmVersionBlock)(NSString *deviceVersion);

@property (nonatomic, copy) void(^settingDeviceMianMessageBlock)(NSData *messageData);

@property (nonatomic, copy) void(^readDeviceBatteryLevelBlock)(NSInteger batteryLevel);

+ (instancetype)shareVPPeripheralManager;

- (void)readDeviceFirmVersion:(void(^)(NSString *deviceVersion))versionBlock;

- (void)settingDeviceMainMessageWithData:(NSData *)settingData result:(void(^)(NSData *messageData))settingBlock;

- (void)synchronizationLocalTimeToDevice;

- (void)readDeviceBatteryLevel:(void(^)(NSInteger batteryLevel))batteryBlock;

- (void)readDeviceOpenHistory;

@end







