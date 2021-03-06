//
//  HomeCell.h
//  NoteBook
//
//  Created by Lorin on 15/7/13.
//  Copyright (c) 2015年 Lighting-Vista. All rights reserved.
//  首页单元格样式

#import <UIKit/UIKit.h>
#import "NoteTool.h"

@interface HomeCell : UITableViewCell

@property (nonatomic, strong) UILabel *contenLabel;   // 显示内容
@property (nonatomic, strong) UILabel *timeLabel;     // 显示时间
@property (nonatomic, strong) Note *note;


///设置cell内容
- (void)setItem:(Note *)note;

@end
