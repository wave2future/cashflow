// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
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
    
    Transaction *t = [mCatReport.transactions objectAtIndex:[mCatReport.transactions count] - 1 - indexPath.row];
    double value;
    if (mCatReport.assetKey < 0) {
        // 全資産指定の場合
        value = t.value;
    } else {
        // 資産指定の場合
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

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
