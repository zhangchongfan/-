//
//  SARootViewController.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/9/14.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SARootViewController.h"
#import "SAUnboxViewController.h"
#import "SALostViewController.h"
#import "SADeviceViewController.h"
#import "SAHistoryController.h"
#import "LocalNotiFile.h"
#import "SADeviceCell.h"
#import "SAOpenRecordModel.h"

@interface SARootViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIAlertViewDelegate>{
    UIView *rightBackSideView;
    UIView *rightSideView;
    NSArray *titleArray;
    NSArray *detailArray;
    BOOL tableViewShow;
    BOOL outOfRange;
    MBProgressHUD *hud;
    UIView *batteryTopView;
    UIView *batteryLevelView;
    BOOL lostAlarm;
    BOOL openAlarm;
}
@property (nonatomic, strong) UILabel *leftBottomLabel;
@property (nonatomic, strong) UITableView *sideTableView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *backViews;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;



@property (nonatomic, strong) UISwitch *activeSwitch;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@end

static NSString *const DeviceCellID = @"DeviceCellID";

@implementation SARootViewController

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    
//    openAlarm = NO;
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"SABOXOPEN" object:nil];
//    
//}

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    outOfRange = NO;
    openAlarm = NO;
//    titleArray = @[@"Activate application",@"Distance alarm",@"Log history",@"Samsara App manual", @"Firmware version", @"Clear data"];
    titleArray = @[@"Activate Application",@"Distance Alarm",@"Log History",@"Samsara App Manual", @"Firmware Version"];
    [self setRootViewControllerUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveRSSIValue:) name:RSSINoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWhenYouWereAway) name:@"SABOXOPEN" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterHistoryController) name:@"DisconnectOpenBoxNoti" object:nil];
    
    [AppBleManager setVPBleCentralManageChangeBlock:^(VPCentralManagerState BleState){
        if (BleState == VPCentralManagerStatePoweredOn) {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:ActiveStateKey]) {
                [self startScanDevice];
            }
        }
    }];
    [AppBleManager setVPBleConnectStateChangeBlock:^(VPDeviceConnectState deviceConnectState){
        if (deviceConnectState == VPDeviceConnectStateDisConnect) {//断开链接
            [self didDisconnectDevice];
        }else if (deviceConnectState == VPDeviceConnectStateConnect) {//已经连接上
            [self didConnectDevice];
        }
        [self.sideTableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setImageViewUI];
}

- (void)setRootViewControllerUI {
    self.navigationController.navigationBar.translucent = NO;
    UIView *naviLeftItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 60)];
    UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (System_version >= 11.0) ? 5 : 10, 40, 40)];
    leftImageView.image = [UIImage imageNamed:@"navi_left_icon"];
    UILabel *leftTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftImageView.right, leftImageView.top, naviLeftItemView.width - leftImageView.width, 20)];
    leftTopLabel.text = @"S A M S A R A";
    leftTopLabel.font = [UIFont systemFontOfSize:18];
    
    _leftBottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftTopLabel.left, leftTopLabel.bottom, naviLeftItemView.width - leftImageView.width, 15)];
    _leftBottomLabel.text = @"Disconnected";
    _leftBottomLabel.font = [UIFont systemFontOfSize:15];
    
    [naviLeftItemView addSubview:leftImageView];
    [naviLeftItemView addSubview:leftTopLabel];
    [naviLeftItemView addSubview:_leftBottomLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:naviLeftItemView];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 30, 30);
    [rightBtn setImage:[UIImage imageNamed:@"navi_right_icon"] forState:UIControlStateNormal];
//    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    rightBtn.imageView.contentMode = UIViewContentModeCenter;
    [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    //右边栏的View
    rightBackSideView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    rightBackSideView.left = ScreenWidth;
    rightBackSideView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:rightBackSideView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideRightSideView)];
    [rightBackSideView addGestureRecognizer:tapGesture];
    
    rightSideView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth * 0.7, ScreenHeight)];
    rightSideView.layer.borderWidth = 1;
    rightSideView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    [[UIApplication sharedApplication].keyWindow addSubview:rightSideView];
    
    _sideTableView = [[UITableView alloc]initWithFrame:rightSideView.bounds style:UITableViewStyleGrouped];
    _sideTableView.backgroundColor = [UIColor whiteColor];
    _sideTableView.delegate = self;
    _sideTableView.dataSource = self;
    _sideTableView.scrollEnabled = NO;
    [rightSideView addSubview:_sideTableView];
    _sideTableView.tableFooterView = [[UIView alloc]init];
    for (UIView *backView in self.backViews) {//增加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [backView addGestureRecognizer:tap];
    }
    [self.sideTableView registerNib:[UINib nibWithNibName:@"SADeviceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:DeviceCellID];
}

- (void)setImageViewUI {
    batteryTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 17, 7)];
    batteryTopView.centerX = self.batteryImageView.width/2;
    batteryTopView.y = self.batteryImageView.height/2 - 36;
    batteryTopView.backgroundColor = [UIColor clearColor];
    [self.batteryImageView addSubview:batteryTopView];
    
    //0-65
    batteryLevelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 36.5, 65)];
    batteryLevelView.centerX = self.batteryImageView.width/2;
    batteryLevelView.bottom = self.batteryImageView.height/2 + 36;
    batteryLevelView.backgroundColor = [UIColor clearColor];
    [self.batteryImageView addSubview:batteryLevelView];
}

- (void)updateBatteryImageViewWithBatteryLevel:(NSInteger)batteryLevel {
    if (batteryLevel > 100) {
        batteryLevel = 100;
    }
    if (batteryLevel == -1) {//断开连接
        batteryTopView.backgroundColor = SAColor(150, 150, 150, 1);
        batteryLevelView.backgroundColor = SAColor(150, 150, 150, 1);
        return;
    }
    batteryTopView.hidden = batteryLevel < 100;
    batteryTopView.backgroundColor = batteryLevelView.backgroundColor = AppColor;
    CGFloat bottom = batteryLevelView.bottom;
    batteryLevelView.height = 65.0/99 * batteryLevel;
    batteryLevelView.bottom = bottom;
}

- (void)setBackView {//更新主界面背景颜色
    Byte byte[3] = {AppBleManager.peripheralModel.lostAlarmType,AppBleManager.peripheralModel.openBoxType,AppBleManager.peripheralModel.openLightType};
    for (int i = 0; i < self.backViews.count; i++) {
        UIView *backView = self.backViews[i];
        if (backView.tag != 3) {//如果为0或者断开链接为白色底
            backView.backgroundColor = (byte[backView.tag] == 0 || !AppBleManager.isConnected) ? [UIColor whiteColor] : AppColor;
        }
    }
}

- (void)enterHistoryController {
    NSArray *openBoxRecords = [[DBStoreManager shareStoreManager] getAllItemsFromTable:OpenBox_table withDeviceAddress:[[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey]];
    if (openBoxRecords.count == 0) {//没有记录
        [MBManager showHUDWarnMessage:@"No history data" Model:MBProgressHUDModeText View:[UIApplication sharedApplication].keyWindow];
        return;
    }
    [self hideRightSideView];
    SAHistoryController *historyController = [[SAHistoryController alloc]initWithNibName:@"SAHistoryController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:historyController animated:YES];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    UIView *tapView = tap.view;
    
    if (tapView.tag == 3) {
        return;
    }
    if (self.activeSwitch.on == false) {
        [MBManager showHUDWarnMessage:@"Not active" Model:MBProgressHUDModeText View:self.view];
        return;
    }
    if (!AppBleManager.isConnected) {
        [MBManager showHUDWarnMessage:@"Device disconnected" Model:MBProgressHUDModeText View:self.view];
        return;
    }
    Byte byte[20] = {0xA1,0x01,AppBleManager.peripheralModel.lostAlarmType,AppBleManager.peripheralModel.openBoxType,AppBleManager.peripheralModel.openLightType,AppBleManager.peripheralModel.alarmDistanceType};
    byte[tapView.tag + 2] = byte[tapView.tag + 2] == 0 ? 1 : 0;
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [AppBleManager.peripheralManage settingDeviceMainMessageWithData:commandData result:^(NSData *messageData) {//设置成功
        const uint8_t *tbyte = messageData.bytes;
        lostAlarm = tbyte[2];
        [self setBackView];
    }];
}

- (void)didDisconnectDevice {//断开连接
    openAlarm = NO;
    [MBManager showHUDWarnMessage:@"Disconnected" Model:MBProgressHUDModeText View:SAApp.window];
    [self hideRightSideView];
    self.leftBottomLabel.text = @"Disconnected";
    [self deviceLostWithDisconnect:YES];
    [self updateBatteryImageViewWithBatteryLevel:-1];
    [self.sideTableView reloadData];
    [self setBackView];
}

- (void)didConnectDevice {//连接成功
    outOfRange = NO;
    hud.labelText = @"Connected";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
    [self hideRightSideView];
    self.leftBottomLabel.text = @"Connected";
    [AppBleManager.peripheralManage synchronizationLocalTimeToDevice];//同步设备时间
    Byte byte[20] = {0xA1,0x02};
    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
    [AppBleManager.peripheralManage settingDeviceMainMessageWithData:commandData result:^(NSData *messageData) {//读取基本信息
        const uint8_t *tbyte = messageData.bytes;
        lostAlarm = tbyte[2];
        [self setBackView];
        [self.sideTableView reloadData];
    }];
    [AppBleManager.peripheralManage readDeviceFirmVersion:^(NSString *deviceVersion) {
        [self.sideTableView reloadData];
    }];
    [AppBleManager.peripheralManage readDeviceBatteryLevel:^(NSInteger batteryLevel) {//读取电池电量
        [self updateBatteryImageViewWithBatteryLevel:batteryLevel];
        self.batteryLabel.text = [NSString stringWithFormat:@"BATTERY %ld%%",(long)batteryLevel];
        [AppBleManager.peripheralManage readDeviceOpenHistory];//读取设备记录
    }];
}

- (void)rightBtnAction:(UIButton *)sender {
    tableViewShow = YES;
    rightBackSideView.left = 0;
    [UIView animateWithDuration:.35 animations:^{
        rightSideView.left = ScreenWidth - ScreenWidth * 0.7;
    }];
}

- (void)activeSwitchAction:(UISwitch *)sender {//激活
    [[NSUserDefaults standardUserDefaults]setBool:sender.on forKey:ActiveStateKey];//保存激活状态
    if (sender.on) {
        [self startScanDevice];
    }else {
        [AppBleManager veepooSDKDisconnectDevice];
        [self setBackView];
    }
    [self.sideTableView reloadData];
}

- (void)rangeSegControlAction:(UISegmentedControl *)sender {//距离设置
    [[NSUserDefaults standardUserDefaults]setInteger:sender.selectedSegmentIndex forKey:DistantRangeStateKey];
//    if (!AppBleManager.isConnected) {
//        return;
//    }
//    Byte byte[20] = {0xA1,0x01,AppBleManager.peripheralModel.lostAlarmType,AppBleManager.peripheralModel.openBoxType,AppBleManager.peripheralModel.openLightType,sender.selectedSegmentIndex};
//    NSData *commandData = [NSData dataWithBytes:&byte length:sizeof(byte)];
//    [AppBleManager.peripheralManage settingDeviceMainMessageWithData:commandData result:^(NSData *messageData) {//设置成功
//        [MBManager showHUDWarnMessage:@"Setting success" Model:MBProgressHUDModeText View:self.view];
//    }];
}

- (void)refreshDeviceList:(UIButton *)sender {
    if (AppBleManager.isConnected) {
        [MBManager showHUDWarnMessage:@"Bluetooth is connected" Model:MBProgressHUDModeText View:SAApp.window];
        return;
    }
    [AppBleManager veepooSDKStopScanDevice];
    [self.deviceArray removeAllObjects];
    [self.sideTableView reloadData];
    [self startScanDevice];
}

- (void)connectOrDisconnectAction:(UIButton *)sender {
    if (sender.selected) {
        [AppBleManager veepooSDKDisconnectDevice];
    }else {
        hud = [MBManager addIndeterminateHUDToView:SAApp.window];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
        VPPeripheralModel *deviceModel = [self.deviceArray objectAtIndex:sender.tag];
        [AppBleManager veepooSDKConnectDevice:deviceModel deviceConnectBlock:^(DeviceConnectState connectState) {
            
        }];
    }
}

- (void)hideRightSideView {
    tableViewShow = NO;
    [UIView animateWithDuration:.35 animations:^{
        rightSideView.left = ScreenWidth;
    } completion:^(BOOL finished) {
        rightBackSideView.left = ScreenWidth;
    }];
}

- (IBAction)SASendEmailAction:(UIButton *)sender {//发送邮件
    //info@samsaraluggage.com
    NSURL *emailUrl = [NSURL URLWithString:@"mailto://info@samsaraluggage.com"];
    [[UIApplication sharedApplication] openURL:emailUrl];
}

- (void)receiveRSSIValue:(NSNotification *)noti {
    if (!AppBleManager.isConnected) {
        return;
    }
    if (!AppBleManager.canReadRSSI) {
        return;
    }
    NSNumber *rssiValue = noti.object;
    NSLog(@"rssiValue:%@",rssiValue);
    if ([rssiValue integerValue] <= AppBleManager.peripheralModel.rssiAlarmValue) {
        [self deviceLostWithDisconnect:NO];
    }
    if ([rssiValue integerValue] >= (AppBleManager.peripheralModel.rssiAlarmValue + 12)) {
        outOfRange = NO;
    }
}

- (void)startScanDevice {//开始扫描设备
    [[AppDelegate shareDelegate].bleManager veepooSDKStartScanDeviceAndReceiveScanningDevice:^(VPPeripheralModel *peripheralModel) {
        if (!tableViewShow) {
            return;
        }
        if (self.deviceArray.count >= 5) {
            return;
        }
        BOOL isHave = NO;
        for (VPPeripheralModel *model in self.deviceArray) {
            if ([model.deviceAddress isEqualToString:peripheralModel.deviceAddress]) {
                isHave = YES;
            }
        }
        if (!isHave) {
            [self.deviceArray addObject:peripheralModel];
            [self.sideTableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:ActiveStateKey]) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return titleArray.count;
    }
    if (AppBleManager.isConnected) {
        return 1;
    }
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {//设备列表
        VPPeripheralModel *deviceModel;
        if (AppBleManager.isConnected) {
            deviceModel = AppBleManager.peripheralModel;
        }else {
            deviceModel = [self.deviceArray objectAtIndex:indexPath.row];
        }
        SADeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:DeviceCellID forIndexPath:indexPath];
        deviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
        deviceCell.textLabel.text = deviceModel.deviceName;
        deviceCell.connectBtn.selected = AppBleManager.isConnected;
        [deviceCell.connectBtn addTarget:self action:@selector(connectOrDisconnectAction:) forControlEvents:UIControlEventTouchUpInside];
        deviceCell.connectBtn.tag = indexPath.row;
        deviceCell.textLabel.width = 80;
        return deviceCell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellID"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {//是否激活
        if (self.activeSwitch == nil) {
            self.activeSwitch = [[UISwitch alloc]init];
            [self.activeSwitch addTarget:self action:@selector(activeSwitchAction:) forControlEvents:UIControlEventValueChanged];
            self.activeSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:ActiveStateKey];
        }
        cell.accessoryView = self.activeSwitch;
    }else if (indexPath.row == 1) {//距离
        UISegmentedControl *segControl = [[UISegmentedControl alloc]initWithItems:@[@"Short",@"Long"]];
        [segControl addTarget:self action:@selector(rangeSegControlAction:) forControlEvents:UIControlEventValueChanged];
        segControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:DistantRangeStateKey];
        cell.accessoryView = segControl;
    }else if (indexPath.row == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 4) {
        cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"SADeviceVersion"];
    }else if (indexPath.row == 5) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [self enterHistoryController];
    }else if (indexPath.row == 3) {//客户界面
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://www.samsaraluggage.com/smart-unit/"]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[DBStoreManager shareStoreManager]deleteAllDataWithTabalName:OpenBox_table];
        [self hideRightSideView];
        [MBManager showHUDWarnMessage:@"Clear success" Model:MBProgressHUDModeText View:[UIApplication sharedApplication].keyWindow];
    }
}

#define SectionHeaderHeight 60
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *headerTitles = @[@"Settings",@"Device List"];
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, SectionHeaderHeight)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, SectionHeaderHeight - 40, tableView.width/2, 40)];
    titleLabel.text = headerTitles[section];
    [sectionHeaderView addSubview:titleLabel];
    
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(tableView.width - 60, titleLabel.top, 50, titleLabel.height);
    [refreshBtn setImage:[UIImage imageNamed:@"device_list_refresh"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshDeviceList:) forControlEvents:UIControlEventTouchUpInside];
    [sectionHeaderView addSubview:refreshBtn];
    if (section == 0) {
        refreshBtn.hidden = YES;
    }
    return sectionHeaderView;
}

#pragma mark --- 存储操作
- (void)deviceLostWithDisconnect:(BOOL)disconnect {
    if (disconnect && [[NSUserDefaults standardUserDefaults]objectForKey:DeviceMessageKey] == nil) {//设备正常断开连接
        return;
    }
    if (!lostAlarm) {//如果丢失报警功能关闭
        return;
    }
    if (outOfRange) {//如果在超出范围之外没有重新进入正常范围后
        return;
    }
    outOfRange = YES;
    if (AppBleManager.peripheralModel != nil) {
        if (AppBleManager.peripheralModel.lostAlarmType) {
            [LocalNotiFile registImmediatelyNoticeWithContent:@"Samsara out of range"];
        }
    }
    NSString *currentTime = [DateHandle getYearMonthDayHourMinuteSecondTime];
    SAOpenRecordModel *lostModel = [[SAOpenRecordModel alloc]initWithSaveTime:currentTime];
    [[DBStoreManager shareStoreManager]putObject:[lostModel changeLostDict] DeviceAddress:[[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey] withTime:lostModel.saveTime intoTable:OpenBox_table withDataVession:@"0"];
    [SAApp getCurrentLocation:^(NSString *latitude, NSString *longitude) {
        lostModel.latitude = latitude;
        lostModel.longitude = longitude;
        [[DBStoreManager shareStoreManager]putObject:[lostModel changeLostDict] DeviceAddress:[[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey] withTime:lostModel.saveTime intoTable:OpenBox_table withDataVession:@"0"];
    }];
}

//断开后箱子有打开的信息
- (void)openWhenYouWereAway {
    if (openAlarm) {
        return;
    }
    [LocalNotiFile registImmediatelyNoticeWithContent:@"Samsara opened while you were away, open \"log history\" for details."];
    openAlarm = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end




