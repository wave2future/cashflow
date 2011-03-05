// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportViewController.h
//

#import <UIKit/UIKit.h>
#import "ReporEntry.h"

@interface ReportViewController : UITableViewController
{
    Report *reports;
    double maxAbsValue;

    NSDateFormatter *dateFormatter;
}

- (void)doneAction:(id)sender;
- (void)generateReport:(int)type asset:(Asset*)asset;
- (NSString *)_reportTitle:(ReporEntry *)report;

@end
