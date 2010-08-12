// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCell.h
//

#import <UIKit/UIKit.h>

@interface ReportCell : UITableViewCell {
    NSString *name;
    double income;
    double outgo;
    double maxAbsValue;

    UILabel *nameLabel;
    UILabel *incomeLabel;
    UILabel *outgoLabel;
    UIView *incomeGraph;
    UIView *outgoGraph;
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,assign) double income;
@property(nonatomic,assign) double outgo;
@property(nonatomic,assign) double maxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView;
- (void)updateGraph;

@end
