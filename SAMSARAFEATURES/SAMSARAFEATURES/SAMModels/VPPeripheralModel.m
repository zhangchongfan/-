//
//  VPPeripheralModel.m
//  VPBleSdk
//
//  Created by 张冲 on 17/1/11.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import "VPPeripheralModel.h"
@implementation VPPeripheralModel

//通过广播包初始化模型
- (id)initWithPeripher:(CBPeripheral*)peripher advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber *)RSSI
{
    self = [super init];
    if (self) {
        _peripheral = peripher;
        _deviceAddress = _peripheral.identifier.UUIDString;
        _deviceName = peripher.name;
        _RSSI = [RSSI integerValue] == 127 ? @(0) : RSSI;
    }
    return self;
}

//通过获取已连接的设备初始化模型
- (id)initWithPeripher:(CBPeripheral*)peripher {
    self = [super init];
    if (self) {
        _peripheral = peripher;
        //因拿不到广播包，所以地址只能用设备的UUID
        _deviceAddress = peripher.identifier.UUIDString;
        _deviceName = peripher.name;
        _RSSI = @(0);
    }
    return self;
}

- (void)setMainMessageData:(NSData *)mainMessageData {
    _mainMessageData = mainMessageData;
    const uint8_t *tbyte = mainMessageData.bytes;
    self.lostAlarmType = tbyte[2];
    self.openBoxType = tbyte[3];
    self.openLightType = tbyte[4];
    self.alarmDistanceType = tbyte[5];
}

- (NSInteger)rssiAlarmValue {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:DistantRangeStateKey] == 0) {//短距离
        return -72;
    }else {//长距离
        return -85;
    }
}


@end








