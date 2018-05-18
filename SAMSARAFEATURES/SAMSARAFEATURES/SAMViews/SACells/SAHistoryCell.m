//
//  SAHistoryCell.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/11/2.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "SAHistoryCell.h"

@implementation SAHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.locationBtn addTarget:self action:@selector(locationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setRecordModel:(SAOpenRecordModel *)recordModel {
    _recordModel = recordModel;
    if (recordModel.type == 0) {//开
        self.locationBtn.hidden = YES;
        self.topLabel.text = @"Samsara opened:";
        //时间
        NSString *timeDes = @"";
        NSInteger agoSecond = [recordModel beforeCurrentTimeSecond];//距离现在有多少秒
        if (agoSecond < 0) {
            agoSecond = 0;
        }
        if (agoSecond < 60) {
            timeDes = @"just";
        }else if (agoSecond < 3600) {
            timeDes = [NSString stringWithFormat:@"%ld mins ago",(long)(agoSecond/60)];
        }else if (agoSecond < 3600 * 24) {
            timeDes = [NSString stringWithFormat:@"%ld hour %ld mins ago",(long)(agoSecond/3600),(long)((agoSecond%3600)/60)];
        }else {
            timeDes = [NSString stringWithFormat:@"%ld day ago",(long)(agoSecond/(3600*24))];
        }
//        self.bellowLabel.text = [NSString stringWithFormat:@"%@, %@",recordModel.showTime,timeDes];
        self.bellowLabel.text = [NSString stringWithFormat:@"%@",recordModel.showTime];
    }else {//丢
        self.topLabel.text = @"Out of range";
        self.bellowLabel.text = recordModel.showTime;
        if ([recordModel.latitude integerValue] == 0 && [recordModel.longitude integerValue] == 0) {//没有有定位
            self.locationBtn.hidden = YES;
        }else {
            self.locationBtn.hidden = NO;
        }
    }
}

- (void)locationBtnAction:(UIButton *)sender {
    if (self.locationBtnBlock) {
        self.locationBtnBlock();
    }
}

@end
