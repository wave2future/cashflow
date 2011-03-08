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
#import "ReportCatGraphCell.h"
#import "ReportCatDetailVC.h"

@implementation CatReportViewController

@synthesize reportEntry = mReportEntry;

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
    [mReportEntry release];
    [super dealloc];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = [NSString stringWithFormat:@"%@ : %@",
                     NSLocalizedString(@"Outgo", @""),
                     [CurrencyManager formatCurrency:mReportEntry.totalOutgo]];
            break;
        case 1:
            title = [NSString stringWithFormat:@"%@ : %@",
                     NSLocalizedString(@"Income", @""),
                     [CurrencyManager formatCurrency:mReportEntry.totalIncome]];
            
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = 0;

    switch (section) {
    case 0:
        rows = [mReportEntry.outgoCatReports count];
        break;
    case 1:
        rows = [mReportEntry.incomeCatReports count];
        break;
    }

    if (rows > 0) {
        return 1 + rows; // graph + rows
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [ReportCatGraphCell cellHeight];
    } else {
        return [ReportCatCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        /* graph cell */
        ReportCatGraphCell *cell = [ReportCatGraphCell reportCatGraphCell:tv];
        [cell setReport:mReportEntry isOutgo:(indexPath.section == 0 ? YES : NO)];
        return cell;
    } else {
        ReportCatCell *cell = [ReportCatCell reportCatCell:tv];

        CatReport *cr = nil;
        switch (indexPath.section) {
            case 0:
                cr = [mReportEntry.outgoCatReports objectAtIndex:indexPath.row - 1];
                [cell setValue:cr.sum maxValue:mReportEntry.maxOutgo];
                break;

            case 1:
                cr = [mReportEntry.incomeCatReports objectAtIndex:indexPath.row - 1];
                [cell setValue:cr.sum maxValue:mReportEntry.maxIncome];
                break;
        }
        
        [cell setGraphColor:[ReportCatGraphCell getGraphColor:indexPath.row - 1]];

        if (cr.category >= 0) {
            cell.name = [[DataModel instance].categories categoryStringWithKey:cr.category];
        } else {
            cell.name = NSLocalizedString(@"No category", @"");
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    if (indexPath.row == 0) return; // graph cell
    
    CatReport *cr = nil;
    switch (indexPath.section) {
    case 0:
        cr = [mReportEntry.outgoCatReports objectAtIndex:indexPath.row - 1];
        break;
    case 1:
        cr = [mReportEntry.incomeCatReports objectAtIndex:indexPath.row - 1];
        break;
    }

    CatReportDetailViewController *vc = [[[CatReportDetailViewController alloc] init] autorelease];
    vc.title = [[DataModel instance].categories categoryStringWithKey:cr.category];
    vc.catReport = cr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
