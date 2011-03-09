// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2011, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" ANDY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppDelegate.h"
#import "ReportVC.h"
#import "ReportCatVC.h"
#import "ReportCell.h"
#import "Config.h"

@implementation ReportViewController

@synthesize tableView = mTableView;
@synthesize designatedAsset = mDesignatedAsset;

- (id)initWithAsset:(Asset*)asset type:(int)type
{
    self = [super initWithNibName:@"ReportView" bundle:nil];
    if (self != nil) {
        self.designatedAsset = asset;

        mType = type;

        mDateFormatter = [[NSDateFormatter alloc] init];
        [self _updateReport];
    }
    return self;
}

- (id)initWithAsset:(Asset*)asset
{
    return [self initWithAsset:asset type:-1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [mDesignatedAsset release];
    [mReports release];
    [mDateFormatter release];
    [super dealloc];
}

/**
   レポート(再)生成
*/
- (void)_updateReport
{
    // レポート種別を設定から読み込む
    Config *config = [Config instance];
    if (mType < 0) {
        mType = config.lastReportType;
    }

    switch (mType) {
        default:
            mType = REPORT_DAILY;
            // FALLTHROUGH
        case REPORT_DAILY:
            self.title = NSLocalizedString(@"Daily Report", @"");
            [mDateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;

        case REPORT_WEEKLY:
            self.title = NSLocalizedString(@"Weekly Report", @"");
            [mDateFormatter setDateFormat:@"yyyy/MM/dd~"];
            break;

        case REPORT_MONTHLY:
            self.title = NSLocalizedString(@"Monthly Report", @"");
            //[dateFormatter setDateFormat:@"yyyy/MM"];
            [mDateFormatter setDateFormat:@"~yyyy/MM/dd"];
            break;

        case REPORT_ANNUAL:
            self.title = NSLocalizedString(@"Annual Report", @"");
            [mDateFormatter setDateFormat:@"yyyy"];
            break;
    }

    // 設定保存
    config.lastReportType = mType;
    [config save];

    // レポート生成
    if (mReports == nil) {
        mReports = [[Report alloc] init];
    }
    [mReports generate:mType asset:mDesignatedAsset];
    mMaxAbsValue = [mReports getMaxAbsValue];

    [self.tableView reloadData];
}

// レポートのタイトルを得る
- (NSString *)_reportTitle:(ReportEntry *)report
{
    if (mReports.type == REPORT_MONTHLY) {
        // 終了日の時刻の１分前の時刻から年月を得る
        //
        // 1) 締め日が月末の場合、endDate は翌月1日0:00を指しているので、
        //    1分前は当月最終日の23:59である。
        // 2) 締め日が任意の日、例えば25日の場合、endDate は当月25日を
        //    指している。そのまま年月を得る。
        NSDate *d = [report.end addTimeInterval:-60];
        return [mDateFormatter stringFromDate:d];
    } else {
        return [mDateFormatter stringFromDate:report.start];
    }
}

#pragma mark Event Handlers

- (IBAction)setReportDaily:(id)sender
{
    mType = REPORT_DAILY;
    [self _updateReport];
}

- (IBAction)setReportWeekly:(id)sender;
{
    mType = REPORT_WEEKLY;
    [self _updateReport];
}

- (IBAction)setReportMonthly:(id)sender;
{
    mType = REPORT_MONTHLY;
    [self _updateReport];
}

- (IBAction)setReportAnnual:(id)sender;
{
    mType = REPORT_ANNUAL;
    [self _updateReport];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mReports.reportEntries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ReportCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [mReports.reportEntries count];
    ReportEntry *report = [mReports.reportEntries objectAtIndex:count - indexPath.row - 1];
	
    ReportCell *cell = [ReportCell reportCell:tv];
    cell.name = [self _reportTitle:report];
    cell.income = report.totalIncome;
    cell.outgo = report.totalOutgo;
    cell.maxAbsValue = mMaxAbsValue;
    [cell updateGraph];

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int count = [mReports.reportEntries count];
    ReportEntry *re = [mReports.reportEntries objectAtIndex:count - indexPath.row - 1];

    CatReportViewController *vc = [[[CatReportViewController alloc] init] autorelease];
    vc.title = [self _reportTitle:re];
    vc.reportEntry = re;
    [self.navigationController pushViewController:vc animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
