// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatVC.h
//

#import <UIKit/UIKit.h>
#import "ReporEntry.h"

@interface CatReportViewController : UITableViewController
{
    ReporEntry *report;
    double maxAbsValue;
}

@property(nonatomic,retain) ReporEntry *report;

@end
