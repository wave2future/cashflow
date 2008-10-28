// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
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
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
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


#import "RootViewController.h"
#import "CashFlowAppDelegate.h"
#import "Transaction.h"
#import "InfoVC.h"

@implementation RootViewController

@synthesize tableView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
#if 0
	// table title 用の領域を作成
	CGRect titleRect = CGRectMake(0, 0, 320, 30);
    UILabel *tableTitle = [[UILabel alloc] initWithFrame:titleRect];
    tableTitle.textColor = [UIColor whiteColor];
	tableTitle.shadowColor = [UIColor blackColor];
    tableTitle.backgroundColor = [UIColor grayColor];
	tableTitle.highlighted = YES;
    tableTitle.opaque = YES;
    tableTitle.font = [UIFont boldSystemFontOfSize:14];
    tableTitle.text = @"";
	tableTitle.textAlignment = UITextAlignmentCenter;
	tableView.tableHeaderView = tableTitle;
	[tableTitle release];
#endif	

	//
	// NavBar 設定
	//
	
	// title 設定
	self.title = NSLocalizedString(@"Transactions", @"");
	
	// "+" ボタンを追加
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addTransaction)];
	
	self.navigationItem.rightBarButtonItem = plusButton;
	[plusButton release];
	
	// Edit ボタンを追加
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
	// 下位 View を作っておく
	transactionView = [[TransactionViewController alloc]
					   initWithNibName:@"TransactionView"
					   bundle:[NSBundle mainBundle]];
	
	exportVC = [[ExportVC alloc] initWithNibName:@"ExportView" bundle:[NSBundle mainBundle]];	
}

- (void)dealloc {
	[transactionView release];
	[exportVC release];

	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateBalance];
	
	[[self tableView] reloadData]; //### Reload data...
}

- (void)updateBalance
{
	double lastBalance = [theDataModel lastBalance];
	NSString *bstr = [DataModel currencyString:lastBalance];

#if 0
	UILabel *tableTitle = (UILabel *)[[self tableView] tableHeaderView];
	tableTitle.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), bstr];
#endif
	
	balanceLabel.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), bstr];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (IBAction)showHelp:(id)sender
{
	InfoVC *v = [[InfoVC alloc] initWithNibName:@"InfoView" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:v animated:YES];
	[v release];
}


#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [theDataModel getTransactionCount];
}

//
// セルの内容を返す
//
#define TAG_DESC 1
#define TAG_DATE 2
#define TAG_VALUE 3
#define TAG_BALANCE 4

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"rootViewCell";
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:MyIdentifier];
	UILabel *desc, *value, *date, *balance;
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		desc = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
		desc.tag = TAG_DESC;
		desc.font = [UIFont systemFontOfSize: 18.0];
		desc.textColor = [UIColor blackColor];
		desc.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:desc];
		
		value = [[[UILabel alloc] initWithFrame:CGRectMake(180, 0, 130, 24)] autorelease];
		value.tag = TAG_VALUE;
		value.font = [UIFont systemFontOfSize: 18.0];
		value.textAlignment = UITextAlignmentRight;
		value.textColor = [UIColor blueColor];
		value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:value];
		
		date = [[[UILabel alloc] initWithFrame:CGRectMake(5, 24, 160, 20)] autorelease];
		date.tag = TAG_DATE;
		date.font = [UIFont systemFontOfSize: 14.0];
		date.textColor = [UIColor grayColor];
		date.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:date];
		
		balance = [[[UILabel alloc] initWithFrame:CGRectMake(150, 24, 160, 20)] autorelease];
		balance.tag = TAG_BALANCE;
		balance.font = [UIFont systemFontOfSize: 14.0];
		balance.textAlignment = UITextAlignmentRight;
		balance.textColor = [UIColor grayColor];
		balance.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:balance];
	} else {
		desc = (UILabel *)[cell.contentView viewWithTag:TAG_DESC];
		date = (UILabel *)[cell.contentView viewWithTag:TAG_DATE];
		value = (UILabel *)[cell.contentView viewWithTag:TAG_VALUE];
		balance = (UILabel *)[cell.contentView viewWithTag:TAG_BALANCE];
	}
	
	// Set up the cell
	Transaction *t = [theDataModel getTransactionAt:[theDataModel getTransactionCount] - indexPath.row - 1];
	
	desc.text = t.description;
	date.text = [theDateFormatter stringFromDate:t.date];
	
	double v = t.value;
	if (t.type == TYPE_OUTGO) {
		v = -v;
	}
	if (v >= 0) {
		value.textColor = [UIColor blueColor];
	} else {
		v = -v;
		value.textColor = [UIColor redColor];
	}
	value.text = [DataModel currencyString:v];
	balance.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), [DataModel currencyString:t.balance]];

	return cell;
}


//
// セルをクリックしたときの処理
//
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	 //transactionView.transactionIndex = [d getTransactionCount] - indexPath.row - 1;
	 [transactionView setTransactionIndex:([theDataModel getTransactionCount] - indexPath.row - 1)];

	 // view を表示
	 [self.navigationController pushViewController:transactionView animated:YES];
}

// 新規トランザクション追加
- (void)addTransaction
{
	[transactionView setTransactionIndex:-1];

	// view を表示
	[self.navigationController pushViewController:transactionView animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	// tableView に通知
	[tableView setEditing:editing animated:animated];
	
	if (editing) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
	int transactionIndex = [theDataModel getTransactionCount] - indexPath.row - 1;
	
	if (style == UITableViewCellEditingStyleDelete) {
		[theDataModel deleteTransactionAt:transactionIndex];
	
		[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self updateBalance];
	}
}

// action sheet
- (void)doAction:(id)sender
{
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"" delegate:self 
				cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
				destructiveButtonTitle:nil otherButtonTitles:
						 NSLocalizedString(@"Export", @""),
						 //NSLocalizedString(@"Info", @""),
						 //NSLocalizedString(@"Delete Transactions", @""),
						 nil];
	[as showInView:[self view]];
	[as release];
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[self.navigationController pushViewController:exportVC animated:YES];
			break;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

@end

