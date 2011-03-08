// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatCell.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@class GraphEntry;

@interface ReportCatGraphCell : UITableViewCell {
    double mTotal;
    NSMutableArray *mCatReports;
}

+ (ReportCatGraphCell *)reportCatGraphCell:(UITableView *)tableView;
- (void)setReport:(ReportEntry *)reportEntry isOutgo:(BOOL)isOutgo;

- (void)drawRect:(CGRect)rect; // override

- (void)_drawCircleGraph:(CGContextRef)context;
- (void)_drawLegend:(CGContextRef)context;
- (UIColor *)_getColor:(int)index;

@end
