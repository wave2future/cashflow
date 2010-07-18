// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatCell.h
//

#import <UIKit/UIKit.h>

@interface ReportCatCell : UITableViewCell {
    NSString *name;
    double value;
    double maxAbsValue;

    UILabel *nameLabel;
    UILabel *valueLabel;
    UIView *graphView;
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,assign) double value;
@property(nonatomic,assign) double maxAbsValue;

+ (ReportCatCell *)reportCatCell:(UITableView *)tableView;
- (void)updateGraph;

@end
