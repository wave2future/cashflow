// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatCell.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@class GraphEntry;

@interface ReportCatGraphCell : UITableViewCell {
    NSMutableArray *mGraphEntries;
}

+ (ReportCatGraphCell *)reportCatGraphCell:(UITableView *)tableView;
- (void)drawRect:(CGRect)rect; // override

- (void)setReport:(ReportEntry *)reportEntry isOutgo:(BOOL)isOutgo


// internal use
@interface GraphEntry : NSObject
{
    double mValue;
    NSString *mTitle;
}

@property(nonatomic,assign) double value;
@property(nonatomic,assign) NSString *title;
@end

@end
