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
#import "DataModel.h"
#import "ReportCatVC.h"
#import "ReportCatCell.h"
#import "ReportCatDetailVC.h"

@implementation CatReportViewController

- (id)init
{
    self = [super initWithNibName:@"SimpleTableView" bundle:nil];
    return self;
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
    if (mReportEntry) {
        [mReportEntry release];
    }
    //[dateFormatter release];
    [super dealloc];
}

- (id)reportEntry
{
    return mReportEntry;
}

- (void)setReportEntry:(ReporEntry *)rep
{
    if (mReportEntry != rep) {
        [mReportEntry release];
        mReportEntry = [rep retain];
    }

    // 合計値を計算
    mMaxAbsValue = 0.0;
    for (CatReport *cr in mReportEntry.catReports) {
#if 0
        if (cr.value > maxAbsValue) {
            maxAbsValue = cr.value;
        }
        else if (-cr.value > -maxAbsValue) {
            maxAbsValue = -cr.value;
        }
#endif
        if (cr.sum >= 0.0) {
            mMaxAbsValue += cr.sum;
        } else {
            mMaxAbsValue -= cr.sum;
        }
    }
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mReportEntry.catReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportCatCell *cell = [ReportCatCell reportCatCell:tv];

    CatReport *cr = [mReportEntry.catReports objectAtIndex:indexPath.row];
    if (cr.catkey >= 0) {
        cell.name = [[DataModel instance].categories categoryStringWithKey:cr.catkey];
    } else {
        cell.name = NSLocalizedString(@"No category", @"");
    }

    cell.maxAbsValue = mMaxAbsValue; // TODO: value 設定前に maxAbsValue を設定する必要がある
    cell.value = cr.sum;

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    CatReport *cr = [mReportEntry.catReports objectAtIndex:indexPath.row];

    CatReportDetailViewController *vc = [[[CatReportDetailViewController alloc] init] autorelease];
    vc.title = [[DataModel instance].categories categoryStringWithKey:cr.catkey];
    vc.catReport = cr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
