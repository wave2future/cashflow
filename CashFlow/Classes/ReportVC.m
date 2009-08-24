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
        reports = [[Reports alloc] init];
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
        [dateFormatter setDateFormat:@"yyyy/MM"];
        break;
    }

    maxAbsValue = 1;
    for (Report *rep in reports.reports) {
        if (rep.totalIncome > maxAbsValue) maxAbsValue = rep.totalIncome;
        if (-rep.totalOutgo > maxAbsValue) maxAbsValue = -rep.totalOutgo;
    }
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%d", tableView.rowHeight);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [reports.reports count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [reports.reports count];
    Report *report = [reports.reports objectAtIndex:count - indexPath.row - 1];
	
    //UITableViewCell *cell = [self reportCell:report];
    ReportCell *cell = [ReportCell reportCell:tv];
    cell.name = [dateFormatter stringFromDate:report.date];
    cell.income = report.totalIncome;
    cell.outgo = report.totalOutgo;
    cell.maxAbsValue = maxAbsValue;

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int count = [reports.reports count];
    Report *r = [reports.reports objectAtIndex:count - indexPath.row - 1];

    CatReportViewController *vc = [[[CatReportViewController alloc] init] autorelease];
    vc.title = [dateFormatter stringFromDate:r.date];
    vc.report = r;
    [self.navigationController pushViewController:vc animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
