// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportViewController.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface ReportViewController : UITableViewController
{
    Report *mReports;
    double mMaxAbsValue;

    NSDateFormatter *mDateFormatter;
}

- (void)doneAction:(id)sender;
- (void)generateReport:(int)type asset:(Asset*)asset;
- (NSString *)_reportTitle:(ReporEntry *)report;

@end
