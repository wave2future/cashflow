// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportViewController.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface ReportViewController : UITableViewController
{
    Reports *reports;
    double maxAbsValue;

    NSDateFormatter *dateFormatter;
}

- (void)generateReport:(int)type asset:(Asset*)asset;
//- (UITableViewCell *)reportCell:(Report*)report;

@end
