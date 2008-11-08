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
#import "AssetListVC.h"
#import "Asset.h"
#import "AssetVC.h"
#import "TransactionListVC.h"
#import "InfoVC.h"

@implementation AssetListViewController

@synthesize tableView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// title 設定
	self.title = NSLocalizedString(@"Accounts", @"");
	
	// "+" ボタンを追加
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addAsset)];
	
	self.navigationItem.rightBarButtonItem = plusButton;
	[plusButton release];
	
	// Edit ボタンを追加
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
	// icon image をロード
	NSString *imagePath;

	imagePath = [[NSBundle mainBundle] pathForResource:@"cash" ofType:@"png"];
    UIImage *icon1 = [UIImage imageWithContentsOfFile:imagePath];
	
	imagePath = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"png"];
    UIImage *icon2 = [UIImage imageWithContentsOfFile:imagePath];
	
	imagePath = [[NSBundle mainBundle] pathForResource:@"card" ofType:@"png"];
    UIImage *icon3 = [UIImage imageWithContentsOfFile:imagePath];
	
	iconArray = [[NSArray alloc] initWithObjects:icon1, icon2, icon3, nil];
	
	// load user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int firstShowAssetIndex = [defaults integerForKey:@"firstShowAssetIndex"];
	if (firstShowAssetIndex >= 0 && [theDataModel assetCount] > firstShowAssetIndex) {
		Asset *asset = [theDataModel assetAtIndex:firstShowAssetIndex];
		[theDataModel changeSelAsset:asset];
		
		// TransactionListView を表示
		TransactionListViewController *vc = [[[TransactionListViewController alloc]
											  initWithNibName:@"TransactionListView"
											  bundle:[NSBundle mainBundle]] autorelease];
		vc.asset = asset;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)dealloc {
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:-1 forKey:@"firstShowAssetIndex"];
	
	[tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [theDataModel assetCount];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellid = @"assetCell";

	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellid];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellid] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}

	Asset *asset = [theDataModel assetAtIndex:indexPath.row];
	cell.text = asset.name;
	cell.image = [iconArray objectAtIndex:asset.type];
	
	return cell;
}

//
// セルをクリックしたときの処理
//
 - (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tv deselectRowAtIndexPath:indexPath animated:NO];

	// save preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:indexPath.row forKey:@"firstShowAssetIndex"];
	
	Asset *asset = [theDataModel assetAtIndex:indexPath.row];
	[theDataModel changeSelAsset:asset];

	// TransactionListView を表示
	TransactionListViewController *vc = [[[TransactionListViewController alloc]
											 initWithNibName:@"TransactionListView"
											 bundle:[NSBundle mainBundle]] autorelease];
	vc.asset = asset;

	[self.navigationController pushViewController:vc animated:YES];
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	AssetViewController *vc = [[[AssetViewController alloc]
								initWithNibName:@"AssetView" bundle:[NSBundle mainBundle]] autorelease];
	[vc setAssetIndex:indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
}

// 新規アセット追加
- (void)addAsset
{
	AssetViewController *vc = [[[AssetViewController alloc]
								initWithNibName:@"AssetView" bundle:[NSBundle mainBundle]] autorelease];
	[vc setAssetIndex:-1];
	[self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	// tableView に通知
	[self.tableView setEditing:editing animated:animated];
	
	if (editing) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
#if 0
	int transactionIndex = [self transactionIndexWithIndexPath:indexPath];

	if (transactionIndex < 0) {
		// initial balance cell : do not delete!
		return;
	}
	
	if (style == UITableViewCellEditingStyleDelete) {
		[asset deleteTransactionAt:transactionIndex];
	
		[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self updateBalance];
		[self.tableView reloadData];
	}
#endif
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
	[theDataModel reorderAsset:from.row to:to.row];
}

- (IBAction)showHelp:(id)sender
{
	InfoVC *v = [[InfoVC alloc] initWithNibName:@"InfoView" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:v animated:YES];
	[v release];
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
