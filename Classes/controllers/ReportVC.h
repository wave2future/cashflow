// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportViewController.h
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "Asset.h"

@interface ReportViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *mTableView;

    int mType;
    Asset mDesignatedAsset;
    Report *mReports;
    double mMaxAbsValue;

    NSDateFormatter *mDateFormatter;
}

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) Asset *designatedAsset;

- (id)initWithAsset:(Asset*)asset withType:(int)type;    // designated initializer
- (id)initWithAsset:(Asset*)asset; 

- (void)doneAction:(id)sender;
//- (void)generateReport:(int)type asset:(Asset*)asset;
- (void)_updateReport;
- (NSString *)_reportTitle:(ReporEntry *)report;

- (IBAction)setReportDaily:(id)sender;
- (IBAction)setReportWeekly:(id)sender;
- (IBAction)setReportMonthly:(id)sender;
- (IBAction)setReportAnnual:(id)sender;

@end
