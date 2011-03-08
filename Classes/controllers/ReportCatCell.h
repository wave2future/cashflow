// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatCell.h
//

#import <UIKit/UIKit.h>

@interface ReportCatCell : UITableViewCell {
    NSString *mName;
    double mValue;
    double mMaxAbsValue;

    UILabel *mNameLabel;
    UILabel *mValueLabel;
    UIView *mGraphView;
}

@property(nonatomic,retain) NSString *name;

+ (ReportCatCell *)reportCatCell:(UITableView *)tableView;

- (void)setValue:(double)value maxValue:(double)maxValue;
- (void)updateGraph;

@end
