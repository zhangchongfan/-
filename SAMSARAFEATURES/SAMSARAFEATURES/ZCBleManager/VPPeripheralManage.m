//
//  VPPeripheralManage.m
//  VPBleSdk
//
//  Created by 张冲 on 17/1/11.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import "VPPeripheralManage.h"
#import "SAOpenRecordModel.h"
#import "DBStoreManager.h"
#import "LocalNotiFile.h"
@interface VPPeripheralManage ()

@end

@implementation VPPeripheralManage

static VPPeripheralManage *peripheralManage = nil;

+ (instancetype)shareVPPeripheralManager {
    if (peripheralManage == nil) {
        peripheralManage = [[VPPeripheralManage alloc]init];
    }
    return peripheralManage;
}

- (void)readDeviceFirmVersion:(void(^)(NSString *deviceVersion))versionBlock {
    self.readFirmVersionBlock = versionBlock;
    Byte byte[20] = {0xA0,0x02};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}

- (void)settingDeviceMainMessageWithData:(NSData *)settingData result:(void(^)(NSData *messageData))settingBlock {//0xA1
    self.settingDeviceMianMessageBlock = settingBlock;
    NSData *commandData = settingData;
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}

- (void)synchronizationLocalTimeToDevice {
    NSCalendar *gregor = [NSCalendar currentCalendar];
    NSInteger unitF = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comps = [gregor components:unitF fromDate:[NSDate date]];
    NSInteger year  = [comps year];
    NSInteger month = [comps month];
    NSInteger day  = [comps day];
    NSInteger hour  = [comps hour];
    NSInteger min   = [comps minute];
    NSInteger sec   = [comps second];
    NSData *yearData = [NSData dataWithBytes:&year length:2];
    const uint8_t *tbyte = yearData.bytes;
    Byte byte[20] = {0xA2,0x01,tbyte[1],tbyte[0],month,day,hour,min,sec};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}


- (void)readDeviceBatteryLevel:(void(^)(NSInteger batteryLevel))batteryBlock {
    self.readDeviceBatteryLevelBlock = batteryBlock;
    Byte byte[20] = {0xA3,0x02};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}

- (void)readDeviceOpenHistory {
    Byte byte[20] = {0xA4,0x02};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}

- (void)readDeviceRSSI {
    Byte byte[20] = {0xA5,0x02};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [VPBleHelper setNotificationForCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    [VPBleHelper writeCharacteristic:self.peripheralModel.peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con data:commandData];
}

#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"characteristic:%@",characteristic.value);
    if (characteristic.value.length != 20) {
        return;
    }
    const uint8_t *tbyte = characteristic.value.bytes;
    if (tbyte[0] == 0xA0) {
        NSString *deviceVersion = [NSString stringWithFormat:@"%x.%x",tbyte[2],tbyte[3]];
        [[NSUserDefaults standardUserDefaults]setObject:deviceVersion forKey:@"SADeviceVersion"];
        self.peripheralModel.deviceVersion = deviceVersion;
        if (self.readFirmVersionBlock) {
            self.readFirmVersionBlock(deviceVersion);
        }
    }
    else if (tbyte[0] == 0xA1) {
        self.peripheralModel.mainMessageData = characteristic.value;
        if (self.settingDeviceMianMessageBlock) {
            self.settingDeviceMianMessageBlock(characteristic.value);
        }
    }
    else if (tbyte[0] == 0xA3) {
        if (self.readDeviceBatteryLevelBlock) {
            self.readDeviceBatteryLevelBlock(tbyte[2]);
        }
    }
    else if (tbyte[0] == 0xA4) {
        SAOpenRecordModel *openModel = [[SAOpenRecordModel alloc]initWithOpenData:characteristic.value];
        if (openModel.month < 1 || openModel.month > 12) {//没有开箱记录
            return;
        }
        NSDictionary *dict = [openModel changeOpenDict];
        [[DBStoreManager shareStoreManager]putObject:dict DeviceAddress:self.peripheralModel.deviceAddress withTime:openModel.saveTime intoTable:OpenBox_table withDataVession:@"0"];
        if (tbyte[1] == 0x01) {
            if (self.peripheralModel.openBoxType) {
                [LocalNotiFile registImmediatelyNoticeWithContent:[NSString stringWithFormat:@"Samsara suitcase opened: %@",openModel.showTime]];
            }
        }else if (tbyte[1] == 0x02) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SABOXOPEN" object:nil];
        }
    }
    else if (tbyte[0] == 0xA5) {
        Byte a = (tbyte[2] ^ 0xFF) + 1;
        [[NSNotificationCenter defaultCenter]postNotificationName:RSSINoti object:@(0 - a)];
    }
}
 
@end






