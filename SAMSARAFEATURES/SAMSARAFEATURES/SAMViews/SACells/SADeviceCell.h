//
//  SADeviceCell.h
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/11/1.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPPeripheralModel.h"
@interface SADeviceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) IBOutlet UIButton *connectBtn;

@end
