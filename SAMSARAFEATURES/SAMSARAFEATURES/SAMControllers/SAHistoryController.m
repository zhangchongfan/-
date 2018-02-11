//
//  SAHistoryController.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/11/2.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SAHistoryController.h"
#import "MapViewController.h"
#import "SAHistoryCell.h"
#import "SAOpenRecordModel.h"
@interface SAHistoryController ()<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *historyTableView;
@property (nonatomic, strong) NSMutableArray *historyArray;
@end

static NSString *const HistoryCellID = @"historyCellID";

@implementation SAHistoryController

- (NSMutableArray *)historyArray {
    if (!_historyArray) {
        _historyArray = [NSMutableArray array];
    }
    return _historyArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"History";
    NSArray *saveArray = [[DBStoreManager shareStoreManager]getAllItemsFromTable:OpenBox_table withDeviceAddress:[[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey]];
    saveArray = [saveArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DBStoreItem *item1 = obj1;
        DBStoreItem *item2 = obj2;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1= [dateFormatter dateFromString:item1.createdTime];
        NSDate *date2= [dateFormatter dateFromString:item2.createdTime];
        if (date1 == [date1 earlierDate: date2]) {
            return NSOrderedDescending;//降序
        }else if (date1 == [date1 laterDate: date2]) {
            return NSOrderedAscending;//升序
        }else{
            return NSOrderedSame;//相等
        }
    }];
    for (DBStoreItem *item in saveArray) {
        NSDictionary *dict = item.objectValue;
        SAOpenRecordModel *model = [[SAOpenRecordModel alloc]initWithDatabaseDict:dict];
        [self.historyArray addObject:model];
    }
    self.historyTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.historyTableView registerNib:[UINib nibWithNibName:@"SAHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:HistoryCellID];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 0, 30, 30);
    [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    deleteBtn.imageView.contentMode = UIViewContentModeCenter;
    [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deleteBtn];
    
}

- (void)deleteBtnAction:(UIButton *)btn {
    if (self.historyArray.count == 0) {//没有记录
        [MBManager showHUDWarnMessage:@"No data" Model:MBProgressHUDModeText View:[UIApplication sharedApplication].keyWindow];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Prompt" message:@"Delete all the record data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sure", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[DBStoreManager shareStoreManager]deleteAllDataWithTabalName:OpenBox_table];
        [MBManager showHUDWarnMessage:@"Clear success" Model:MBProgressHUDModeText View:[UIApplication sharedApplication].keyWindow];
        [self.historyArray removeAllObjects];
        [self.historyTableView reloadData];
    }
}

- (NSArray *)sortedWithArray:(NSArray *)array Key:(NSString *)key Ascending:(BOOL)ascending{
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    NSArray *descs = [NSArray arrayWithObjects:dateDesc,nil];
    return [array sortedArrayUsingDescriptors:descs];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SAHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryCellID forIndexPath:indexPath];
    SAOpenRecordModel *model = [self.historyArray objectAtIndex:indexPath.row];
    cell.recordModel = model;
    [cell setLocationBtnBlock:^{
        MapViewController *mapController = [[MapViewController alloc]init];
        mapController.lostModel = model;
        [self.navigationController pushViewController:mapController animated:YES];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //移除tableView中的数据
        SAOpenRecordModel *model = [self.historyArray objectAtIndex:indexPath.row];
        [self.historyArray removeObject:model];
        [[DBStoreManager shareStoreManager]deleteObjectByDeviceAddress:[[NSUserDefaults standardUserDefaults]objectForKey:DeviceMacKey] CreateTime:model.saveTime withTable:OpenBox_table];
        [self.historyTableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

@end
