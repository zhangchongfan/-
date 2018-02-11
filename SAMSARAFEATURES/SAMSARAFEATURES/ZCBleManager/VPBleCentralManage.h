//
//  VPBleCentralManage.h
//  VeepooBleSDK
//
//  Created by 张冲 on 17/2/7.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPPeripheralManage.h"
#import "VPBleHelper.h"

//系统蓝牙状态改变
typedef NS_ENUM (NSInteger, VPCentralManagerState) {
    VPCentralManagerStateUnknown = 0,
    VPCentralManagerStateResetting,
    VPCentralManagerStateUnsupported,
    VPCentralManagerStateUnauthorized,
    VPCentralManagerStatePoweredOff,//系统蓝牙关闭
    VPCentralManagerStatePoweredOn,//系统蓝牙开启
};

//系统蓝牙状态改变
typedef NS_ENUM (NSInteger, VPDeviceConnectState) {
    VPDeviceConnectStateDisConnect = 0,//断开连接
    VPDeviceConnectStateConnect,//已经连接
    VPDeviceConnectStateVerifyPasswordSuccess,//验证密码成功
    VPDeviceConnectStateVerifyPasswordFailure,//验证密码失败
    VPDeviceDiscoverNewUpdateFirm,//发现可以升级的新固件
};

typedef NS_ENUM(NSInteger, DeviceConnectState) {
    BlePoweredOff = 0,//蓝牙没有打开
    BleConnecting = 1,//蓝牙连接中
    BleConnectSuccess = 2, //蓝牙连接成功
    BleConnectFailed = 3, //蓝牙连接失败
    BleVerifyPasswordSuccess = 4,//验证密码成功
    BleVerifyPasswordFailure = 5,//验证密码失败
};

//接收扫描到的设备
typedef void(^ReceiveScanningDevice)(VPPeripheralModel *peripheralModel);
//接收扫描到的设备
typedef void(^DeviceConnectBlock)(DeviceConnectState connectState);

@interface VPBleCentralManage : NSObject<CBPeripheralDelegate,CBCentralManagerDelegate>

//中心设备管理者
@property (nonatomic, strong) CBCentralManager *centralManager;

//已经连接的设备模型
@property (nonatomic, strong) VPPeripheralModel *peripheralModel;

//数据发送和接收工具
@property (nonatomic, strong) VPPeripheralManage *peripheralManage;

//系统蓝牙状态改变的回调
@property (nonatomic, copy) void(^VPBleCentralManageChangeBlock)(VPCentralManagerState BleState);

//设备连接状态改变的回调
@property (nonatomic, copy) void(^VPBleConnectStateChangeBlock)(VPDeviceConnectState deviceConnectState);

//设备升级状态改变的回调
@property (nonatomic, copy) void(^VPBleDFUConnectStateChangeBlock)(VPDeviceConnectState deviceConnectState);

//连接状态,发送指令前确保连接
@property (nonatomic, assign) BOOL isConnected;


/**
 是否自动连接，默认是YES
 */
@property (nonatomic, assign) BOOL automaticConnection;

//创建实例
+ (instancetype)sharedBleManager;

//开始扫描设备
- (void)veepooSDKStartScanDeviceAndReceiveScanningDevice:(ReceiveScanningDevice)scanningDevice;

//停止扫描
- (void)veepooSDKStopScanDevice;

//开始连接设备
- (void)veepooSDKConnectDevice:(VPPeripheralModel *)peripheralModel deviceConnectBlock:(DeviceConnectBlock)connectBlock;

//断开连接，不再自动连接，人为断开连接SDK不再负责帮助自动重连
- (void)veepooSDKDisconnectDevice;

@end




