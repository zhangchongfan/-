//
//  SADeviceCell.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/11/1.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SADeviceCell.h"

@implementation SADeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.connectBtn.layer.cornerRadius = 3;
    self.connectBtn.layer.borderWidth = 1;
    self.connectBtn.layer.borderColor = SAColor(68, 68, 68, 1).CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
