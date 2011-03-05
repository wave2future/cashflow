// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportCatDetailVC.h
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface CatReportDetailViewController : UITableViewController
{
    CatReport *mCatReport;
}

@property(nonatomic,retain) CatReport *catReport;

@end
