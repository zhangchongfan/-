//
//  SADeviceViewController.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/10/6.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SADeviceViewController.h"
@interface SADeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (strong, nonatomic) IBOutlet UITableView *scanTableView;

@end

@implementation SADeviceViewController

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"My device";
    [self scanDevice];
}

- (void)scanDevice {
    __weak typeof(self) weakSelf = self;
    [[AppDelegate shareDelegate].bleManager veepooSDKStartScanDeviceAndReceiveScanningDevice:^(VPPeripheralModel *peripheralModel) {
        BOOL isHave = NO;
        for (VPPeripheralModel *model in weakSelf.deviceArray) {
            if ([model.deviceAddress isEqualToString:peripheralModel.deviceAddress]) {
                isHave = YES;
            }
        }
        if (!isHave) {
            [weakSelf.deviceArray addObject:peripheralModel];
            [weakSelf.scanTableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellID"];
    }
    VPPeripheralModel *model = self.deviceArray[indexPath.row];
    cell.textLabel.text = model.deviceName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VPPeripheralModel *model = self.deviceArray[indexPath.row];
    if (AppBleManager.isConnected) {
        [AppBleManager veepooSDKDisconnectDevice];
    }
    [AppBleManager veepooSDKConnectDevice:model deviceConnectBlock:^(DeviceConnectState connectState) {
        if (connectState == BleConnectSuccess) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
