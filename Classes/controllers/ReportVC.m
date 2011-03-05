// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

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

@implementation ReportViewController

- (id)init
{
    self = [super initWithNibName:@"ReportView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = NSLocalizedString(@"Report", @"");

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
    if (reports) {
        [reports release];
    }
    [dateFormatter release];
    [super dealloc];
}

- (void)generateReport:(int)type asset:(Asset*)asset
{
    if (reports == nil) {
        reports = [[Report alloc] init];
    }
    [reports generate:type asset:asset];
	
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
	
    switch (type) {
    case REPORT_WEEKLY:
        [dateFormatter setDateFormat:@"yyyy/MM/dd~"];
        break;
    case REPORT_MONTHLY:
        //[dateFormatter setDateFormat:@"yyyy/MM"];
        [dateFormatter setDateFormat:@"~yyyy/MM/dd"];
        break;
    }

    maxAbsValue = 1;
    for (ReporEntry *rep in reports.reportEntries) {
        if (rep.totalIncome > maxAbsValue) maxAbsValue = rep.totalIncome;
        if (-rep.totalOutgo > maxAbsValue) maxAbsValue = -rep.totalOutgo;
    }
}

// レポートのタイトルを得る
- (NSString *)_reportTitle:(ReporEntry *)report
{
    if (reports.type == REPORT_MONTHLY) {
        // 終了日の時刻の１分前の時刻から年月を得る
        //
        // 1) 締め日が月末の場合、endDate は翌月1日0:00を指しているので、
        //    1分前は当月最終日の23:59である。
        // 2) 締め日が任意の日、例えば25日の場合、endDate は当月25日を
        //    指している。そのまま年月を得る。
        NSDate *d = [report.end addTimeInterval:-60];
        return [dateFormatter stringFromDate:d];
    } else {
        return [dateFormatter stringFromDate:report.start];
    }
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%d", tableView.rowHeight);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [reports.reportEntries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [reports.reportEntries count];
    ReporEntry *report = [reports.reportEntries objectAtIndex:count - indexPath.row - 1];
	
    ReportCell *cell = [ReportCell reportCell:tv];
    cell.name = [self _reportTitle:report];
    cell.income = report.totalIncome;
    cell.outgo = report.totalOutgo;
    cell.maxAbsValue = maxAbsValue;

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int count = [reports.reportEntries count];
    ReporEntry *r = [reports.reportEntries objectAtIndex:count - indexPath.row - 1];

    CatReportViewController *vc = [[[CatReportViewController alloc] init] autorelease];
    vc.title = [self _reportTitle:r];
    vc.report = r;
    [self.navigationController pushViewController:vc animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
