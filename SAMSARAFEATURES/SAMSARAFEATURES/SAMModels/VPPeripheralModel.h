//
//  VPPeripheralModel.h
//  VPBleSdk
//
//  Created by 张冲 on 17/1/11.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface VPPeripheralModel : NSObject

#pragma mark -- 扫描时候获取的属性值
//蓝牙设备，开发者不用
@property (strong, nonatomic, readonly) CBPeripheral *peripheral;
//设备的名字，扫描的列表中显示
@property (nonatomic, strong, readonly) NSString *deviceName;
//设备地址，密码验证成功之后可能会改变，扫描的列表中显示
@property (nonatomic, strong, readonly) NSString *deviceAddress;
//设备的信号，可以通过此信号，在列表中排序，rssi值越大信号越好，一般是负数
@property (nonatomic, strong) NSNumber *RSSI;

#pragma mark -- 连接并密码验证成功后获取的属性值
//设备的显示版本，告知用户当前的版本是都少
@property (nonatomic, strong) NSString *deviceVersion;

@property (nonatomic, strong) NSData *mainMessageData;

@property (nonatomic, assign) short lostAlarmType;
@property (nonatomic, assign) short openBoxType;
@property (nonatomic, assign) short openLightType;
@property (nonatomic, assign) short alarmDistanceType;

@property (nonatomic, assign) NSInteger rssiAlarmValue;

//通过广播包初始化模型
- (instancetype)initWithPeripher:(CBPeripheral*)peripher advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber *)RSSI;

//通过获取已连接的设备初始化模型
- (instancetype)initWithPeripher:(CBPeripheral*)peripher;


@end






