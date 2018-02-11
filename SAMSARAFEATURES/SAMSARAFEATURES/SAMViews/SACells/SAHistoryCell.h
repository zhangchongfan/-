//
//  SAHistoryCell.h
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/11/2.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAOpenRecordModel.h"
@interface SAHistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *bellowLabel;
@property (strong, nonatomic) IBOutlet UIButton *locationBtn;

@property (nonatomic, strong) SAOpenRecordModel *recordModel;

@property (nonatomic, copy) void(^locationBtnBlock)();

@end
