// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatVC.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface CatReportViewController : UITableViewController
{
    ReportEntry *mReportEntry;
}

@property(nonatomic,retain) ReportEntry *reportEntry;

- (void)doneAction:(id)sender;

@end
