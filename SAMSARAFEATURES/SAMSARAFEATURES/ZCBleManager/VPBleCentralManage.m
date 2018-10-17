//
//  VPBleCentralManage.m
//  VeepooBleSDK
//
//  Created by 张冲 on 17/2/7.
//  Copyright © 2017年 veepoo. All rights reserved.
//

#import "VPBleCentralManage.h"
#import "SAConstantString.h"

@interface VPBleCentralManage (){
    
}
//扫描设备的回调
@property (nonatomic, copy) ReceiveScanningDevice scanningDevice;

//扫描连接的回调
@property (nonatomic, copy) DeviceConnectBlock connectBlock;

//扫描设备的计时器
@property (nonatomic, strong) NSTimer *scanTimer;

@property (nonatomic, strong) NSString *devicePassword;

@property (nonatomic, strong) NSTimer *rssiTimer;

@end

@implementation VPBleCentralManage

#pragma 初始化并创建中心管理者
static VPBleCentralManage *bleCentralManage = nil;

//单例方法
+ (instancetype)sharedBleManager{
    if (bleCentralManage == nil) {
        bleCentralManage = [[VPBleCentralManage alloc]init];
    }
    return bleCentralManage;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.peripheralManage = [VPPeripheralManage shareVPPeripheralManager];
        self.automaticConnection = YES;
        self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startReadRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.rssiTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setPeripheralModel:(VPPeripheralModel *)peripheralModel {
    _peripheralModel = peripheralModel;
    self.peripheralManage.peripheralModel = peripheralModel;
}

- (void)startReadRSSI {//连接后延迟3秒读取RSSI
    NSLog(@".....");
    if (self.isConnected && self.canReadRSSI) {
        [self.peripheralManage readDeviceRSSI];
    }
}

//开始扫描并且返回扫描到的设备
- (void)veepooSDKStartScanDeviceAndReceiveScanningDevice:(ReceiveScanningDevice)scanningDevice{
    //下边主要是为了提示蓝牙没有开启
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    CBCentralManager *cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:nil queue:nil options:options];
    cbCentralMgr = nil;
    self.scanningDevice = scanningDevice;
    [self startScanDevice];
}

- (void)startScanDevice {
    if (self.centralManager.state == CBManagerStatePoweredOn) {//如果手机蓝牙是打开的则开始扫描
        if (!_scanTimer) {
            _scanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startScanDevice) userInfo:nil repeats:YES];
        }
        /**
         *  Services后边为nil则代表搜索所有设备，如果不为nil则代表搜索含有这个Services的设备
         */
        CBUUID *uuid1 = [CBUUID UUIDWithString:@"FFF0"];
        [self.centralManager scanForPeripheralsWithServices:@[uuid1] options:nil];
//        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

//停止扫描
- (void)veepooSDKStopScanDevice {
    self.scanningDevice = nil;
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self.centralManager stopScan];
    }
    [_scanTimer invalidate];
    _scanTimer = nil;
}

//开始连接设备
- (void)veepooSDKConnectDevice:(VPPeripheralModel *)peripheralModel deviceConnectBlock:(DeviceConnectBlock)connectBlock {
    if (self.centralManager.state != CBManagerStatePoweredOn) {
        if (connectBlock) {
            connectBlock(BlePoweredOff);
        }
        return;
    }
    self.connectBlock = connectBlock;
    if (self.connectBlock) {
        self.connectBlock(BleConnecting);
    }
    self.peripheralModel = peripheralModel;
    [self.centralManager connectPeripheral:self.peripheralModel.peripheral options:nil];
}

//断开连接
- (void)veepooSDKDisconnectDevice {
    if (self.isConnected) {
        self.isConnected = NO;
        //手动断开不再自动重连
        [VPBleHelper deleteLastConnectDeviceMessage];//清除记录的蓝牙信息
        [self.centralManager cancelPeripheralConnection:self.peripheralModel.peripheral];
    }
}

#pragma mark -- CBCentralManagerDelegate
//监听系统蓝牙开启或者关闭的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (_VPBleCentralManageChangeBlock) {
        NSUInteger state = central.state;
        _VPBleCentralManageChangeBlock(state);
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        if ([VPBleHelper getLastConnectDeviceMessage] != nil) {//如果有上次连接记录，打开蓝牙就开始扫描
            [self startScanDevice];
        }
    }
}

//发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if (RSSI.integerValue < 0 && RSSI.integerValue >= -125) {
        VPPeripheralModel *model = [[VPPeripheralModel alloc]initWithPeripher:peripheral advertisementData:advertisementData RSSI:RSSI];
        if (self.scanningDevice && model.deviceName) {
            self.scanningDevice(model);
        }
        if ([VPBleHelper justIsLastConnectDeviceWithVPPeripheralModel:model] && !_isConnected && _automaticConnection) {//上次连接的设备
            [self veepooSDKConnectDevice:model deviceConnectBlock:nil];
            return;
        }
    }
}

/**
 *  成功连接设备后调用
 *  @param peripheral 连接成功的蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //连接设备成功后 设置代理 及搜索设备的服务nil代表查找所有的服务 查找到服务后后执行代理方法didDiscoverCharacteristicsForService
    [self veepooSDKStopScanDevice];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

/**
 *  蓝牙连接失败后调用
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.isConnected = NO;
    if (self.connectBlock) {
        self.connectBlock(BleConnectFailed);
    }
}

//蓝牙断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.isConnected = NO;
    if (self.VPBleConnectStateChangeBlock) {
        self.VPBleConnectStateChangeBlock(VPDeviceConnectStateDisConnect);
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:DeviceMessageKey] != nil) {
        [self performSelector:@selector(startScanDevice) withObject:nil afterDelay:0.2];
    }
}

/**
 *  当找到蓝牙设备的服务后调用
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        //蓝牙设备根据指定的服务找到特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/**
 *  通过相应的服务找到服务的所有特征
 *
 *  @param peripheral 蓝牙连接的设备
 *  @param service    通过这个服务可以找到这个服务的所有特征
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if ([VPBleHelper searchCharacteristicsWithService:service]) {//发现了服务才算正式连接成功
        self.isConnected = YES;//只有找到服务特征才算连接成功
        self.canReadRSSI = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.canReadRSSI = YES;
        });
        if (self.connectBlock) {
            self.connectBlock(BleConnectSuccess);
        }
        if (self.VPBleConnectStateChangeBlock) {
            self.VPBleConnectStateChangeBlock(VPDeviceConnectStateConnect);
        }
        [VPBleHelper saveDeviceMessageWithVPPeripheralModel:self.peripheralModel DevicePassword:nil];
        peripheral.delegate = self.peripheralManage;
        [VPBleHelper setNotificationForCharacteristic:peripheral sUUID:Ble_Main_Service cUUID:Ble_Main_Con enable:YES];
    }
}

#define VPLocalLanguageIsChinese [[[NSLocale preferredLanguages]objectAtIndex:0]hasPrefix:@"zh"]


#pragma mark -- 验证密码

//- (NSArray *)obtainIphoneBles{//查看配对设备
//    CBUUID *uuid = [CBUUID UUIDWithString:SetTimeServer];
//    NSArray *iphoneBles = [_centralManager retrieveConnectedPeripheralsWithServices:@[uuid]];
//    return iphoneBles;
//}


@end
