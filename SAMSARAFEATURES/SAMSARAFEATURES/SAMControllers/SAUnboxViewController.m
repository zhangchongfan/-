//
//  SAUnboxViewController.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/9/17.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SAUnboxViewController.h"

@interface SAUnboxViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

static NSString *const unboxCellID = @"unboxCellID";

@implementation SAUnboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"开箱记录";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unboxCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:unboxCellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"index_%ld",indexPath.row];
    return cell;
}

@end
