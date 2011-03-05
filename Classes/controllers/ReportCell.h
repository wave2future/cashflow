// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCell.h
//

#import <UIKit/UIKit.h>

@interface ReportCell : UITableViewCell {
    NSString *mName;
    double mIncome;
    double mOutgo;
    double mMaxAbsValue;

    UILabel *mNameLabel;
    UILabel *mIncomeLabel;
    UILabel *mOutgoLabel;
    UIView *mIncomeGraph;
    UIView *mOutgoGraph;
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,assign) double income;
@property(nonatomic,assign) double outgo;
@property(nonatomic,assign) double maxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView;
- (void)updateGraph;

@end
