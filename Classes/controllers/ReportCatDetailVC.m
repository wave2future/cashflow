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
#import "DataModel.h"
#import "Report.h"
#import "ReportCatDetailVC.h"
#import "TransactionCell.h"

@implementation CatReportDetailViewController

@synthesize catReport = mCatReport;

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
    [mCatReport release];
    [super dealloc];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mCatReport.transactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell = [TransactionCell transactionCell:tv];
    
    Transaction *t = [mCatReport.transactions objectAtIndex:indexPath.row];
    double value;
    if (mCatReport.assetKey < 0) {
        // 全資産指定の場合
        value = t.value;
    } else {
        // 資産指定の場合
        // この場合、CatReportVC 側で資産間移動は計上しないようになっているが、一応
        if (t.asset == mCatReport.assetKey) {
            value = t.value;
        } else {
            value = -t.value;
        }
    }
    [cell setDescriptionLabel:t.description];
    [cell setDateLabel:t.date];
    [cell setValueLabel:value];
    [cell clearBalanceLabel];
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
