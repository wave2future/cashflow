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


#import "AssetVC.h"
#import "AppDelegate.h"
#import "GenEditTextVC.h"
#import "GenEditTypeVC.h"

@implementation AssetViewController

@synthesize asset;

#define ROW_NAME  0
#define ROW_TYPE  1

- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"Account", @"");
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
												  target:self
												  action:@selector(saveAction)] autorelease];

	// ボタン生成
	UIButton *b;
	UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
				
	b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[b setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	[b setBackgroundImage:bg forState:UIControlStateNormal];
		
	[b setFrame:CGRectMake(10, 280, 300, 44)];
	[b setTitle:NSLocalizedString(@"Delete account", @"") forState:UIControlStateNormal];
	[b addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	delButton = [b retain];
}

- (void)dealloc
{
	[delButton release];
	
	[super dealloc];
}

// 処理するトランザクションをロードしておく
- (void)setAssetIndex:(int)n
{
	assetIndex = n;

	if (asset != nil) {
		[asset release];
	}
	if (assetIndex < 0) {
		// 新規
		asset = [[Asset alloc] init];
		asset.sorder = 99999;
	} else {
		// 変更
		asset = [theDataModel assetAtIndex:assetIndex];
	}
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (assetIndex >= 0) {
		[self.view addSubview:delButton];
	}
		
	[[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[[self tableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if (assetIndex >= 0) {
		[delButton removeFromSuperview];
	}
}

/////////////////////////////////////////////////////////////////////////////////
// TableView 表示処理

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 2;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"assetViewCells";
	UILabel *name, *value;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		name = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 160, 32)] autorelease];
		name.tag = 1;
		name.font = [UIFont systemFontOfSize: 14.0];
		name.textColor = [UIColor blueColor];
		name.textAlignment = UITextAlignmentRight;
		name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:name];

		value = [[[UILabel alloc] initWithFrame:CGRectMake(130, 6, 160, 32)] autorelease];
		value.tag = 2;
		value.font = [UIFont systemFontOfSize: 16.0];
		value.textColor = [UIColor blackColor];
		value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:value];

	} else {
		name  = (UILabel *)[cell.contentView viewWithTag:1];
		value = (UILabel *)[cell.contentView viewWithTag:2];
	}
		
	switch (indexPath.row) {
		case ROW_NAME:
			name.text = NSLocalizedString(@"Account Name", @"");
			value.text = asset.name;
			break;

		case ROW_TYPE:
			name.text = NSLocalizedString(@"Account Type", @"");
			switch (asset.type) {
			case ASSET_CASH:
				value.text = NSLocalizedString(@"Cash", @"");
				break;
			case ASSET_BANK:
				value.text = NSLocalizedString(@"Bank Account", @"");
				break;
			case ASSET_CARD:
				value.text = NSLocalizedString(@"Credit Card", @"");
				break;
			}
			break;
	}

	return cell;
}

///////////////////////////////////////////////////////////////////////////////////
// 値変更処理

// セルをクリックしたときの処理
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UINavigationController *nc = self.navigationController;

	// view を表示
	UIViewController *vc = nil;
	GenEditTextViewController *ge;
	GenEditTypeViewController *gt;
	NSArray *typeArray;

	switch (indexPath.row) {
		case ROW_NAME:
			ge = [GenEditTextViewController genEditTextViewController:self title:NSLocalizedString(@"Account Name", @"") identifier:0];
			ge.text = asset.name;
			vc = ge;
			break;

		case ROW_TYPE:
			typeArray = [[[NSArray alloc]initWithObjects:
						  NSLocalizedString(@"Cash", @""),
						  NSLocalizedString(@"Bank Account", @""),
						  NSLocalizedString(@"Credit Card", @""),
						  nil] autorelease];
			gt = [GenEditTypeViewController genEditTypeViewController:self 
																array:typeArray 
																title:NSLocalizedString(@"Account Type", @"")
														   identifier:0];
			gt.type = asset.type;
			vc = gt;
			break;
	}
	
	if (vc != nil) {
		[nc pushViewController:vc animated:YES];
	}
}

// イベントリスナ (下位 ViewController からの変更通知)
- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(int)id
{
	asset.name = vc.text;
}

- (void)genEditTypeViewChanged:(GenEditTypeViewController *)vc identifier:(int)id
{
	asset.type = vc.type;
}


////////////////////////////////////////////////////////////////////////////////
// 削除処理
- (void)delButtonTapped
{
#if 0
	[theDataModel.selAsset deleteTransactionAt:transactionIndex];
	[trans release];
	trans = nil;
#endif
	
	[self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// 保存処理
- (void)saveAction
{
	if (assetIndex < 0) {
		[theDataModel addAsset:asset];
		[asset release];
	} else {
		[theDataModel.db updateAsset:asset];
	}
	asset = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
