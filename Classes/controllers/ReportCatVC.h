// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatVC.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface CatReportViewController : UITableViewController
{
    ReporEntry *mReportEntry;
    double mMaxAbsValue;
}

@property(nonatomic,retain) ReporEntry *reportEntry;

@end
