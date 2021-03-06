// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCell.h

#import <UIKit/UIKit.h>

@interface ReportCell : UITableViewCell {
    NSString *mName;
    double mIncome;
    double mOutgo;
    double mMaxAbsValue;

    IBOutlet UILabel *mNameLabel;
    IBOutlet UILabel *mIncomeLabel;
    IBOutlet UILabel *mOutgoLabel;
    IBOutlet UIView *mIncomeGraph;
    IBOutlet UIView *mOutgoGraph;
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,assign) double income;
@property(nonatomic,assign) double outgo;
@property(nonatomic,assign) double maxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView;
+ (CGFloat)cellHeight;

- (void)updateGraph;

@end
