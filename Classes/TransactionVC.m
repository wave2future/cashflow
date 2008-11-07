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


#import "TransactionVC.h"
#import "AppDelegate.h"

@implementation TransactionViewController

@synthesize trans;

#define ROW_DATE	0
#define ROW_TYPE  1
#define ROW_VALUE 2
#define ROW_DESC  3
#define ROW_MEMO  4

- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"Transaction", @"");
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
										      initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											  target:self
												  action:@selector(saveAction)] autorelease];

	typeArray = [[NSArray alloc] initWithObjects:
								  NSLocalizedString(@"Payment", @""),
								  NSLocalizedString(@"Deposit", @""),
								  NSLocalizedString(@"Adjustment", @"Balance adjustment"),
								 nil];

	// 下位の ViewController を生成しておく
	editDateVC = [[EditDateViewController alloc]
				  initWithNibName:@"EditDateView"
				  bundle:[NSBundle mainBundle]];
	editDateVC.listener = self;

	editTypeVC = [GenEditTypeViewController
					 genEditTypeViewController:self
					 array:typeArray 
					 title:NSLocalizedString(@"Type", @"")
					 identifier:0];

	editValueVC = [[EditValueViewController alloc]
				   initWithNibName:@"EditValueView"
				   bundle:[NSBundle mainBundle]];
	editValueVC.listener = self;

	editDescVC = [[EditDescViewController alloc]
				  initWithNibName:@"EditDescView"
				  bundle:[NSBundle mainBundle]];
	editDescVC.listener = self;
	
	editMemoVC = [GenEditTextViewController genEditTextViewController:self
				title:NSLocalizedString(@"Memo", @"") identifier:0];
	
	// ボタン生成
	UIButton *b;
	UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
				
	int i;
	for (i = 0; i < 2; i++) {
		b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[b setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
		[b setBackgroundImage:bg forState:UIControlStateNormal];
		
		if (i == 0) {
			[b setFrame:CGRectMake(10, 280, 300, 44)];
			[b setTitle:NSLocalizedString(@"Delete transaction", @"") forState:UIControlStateNormal];
			[b addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
			delButton = [b retain];
		} else {
			[b setFrame:CGRectMake(10, 340, 300, 44)];
			[b setTitle:NSLocalizedString(@"Delete with all past transactions", @"") forState:UIControlStateNormal];
			[b addTarget:self action:@selector(delPastButtonTapped) forControlEvents:UIControlEventTouchUpInside];
			delPastButton = [b retain];
		}
	}
}

- (void)dealloc
{
	[editDateVC release];
	[editTypeVC release];
	[editValueVC release];
	[editDescVC release];
	[editMemoVC release];
	
	[delButton release];
	[delPastButton release];
	
	[super dealloc];
}

// 処理するトランザクションをロードしておく
- (void)setTransactionIndex:(int)n
{
	transactionIndex = n;

	if (trans != nil) {
		[trans release];
	}
	if (transactionIndex < 0) {
		// 新規トランザクション
		trans = [[Transaction alloc] init];
	} else {
		// 変更
		Transaction *t = [theDataModel.selAsset transactionAt:transactionIndex];
		trans = [t copy];
	}
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (transactionIndex >= 0) {
		[self.view addSubview:delButton];
		[self.view addSubview:delPastButton];
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
	
	if (transactionIndex >= 0) {
		[delButton removeFromSuperview];
		[delPastButton removeFromSuperview];
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
	
	return 5; // details
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return [self getCellForField:indexPath tableView:tableView];
}

- (UITableViewCell *)getCellForField:(NSIndexPath*)indexPath tableView:(UITableView *)tableView
{
	static NSString *MyIdentifier = @"transactionViewCells";
	UILabel *name, *value;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		name = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 110, 32)] autorelease];
		name.tag = 1;
		name.font = [UIFont systemFontOfSize: 14.0];
		name.textColor = [UIColor blueColor];
		name.textAlignment = UITextAlignmentRight;
		name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:name];

		value = [[[UILabel alloc] initWithFrame:CGRectMake(90, 6, 210, 32)] autorelease];
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
		case ROW_DATE:
			name.text = NSLocalizedString(@"Date", @"");
			value.text = [theDateFormatter stringFromDate:trans.date];
			break;

		case ROW_TYPE:
			name.text = NSLocalizedString(@"Type", @"Transaction type");
			value.text = [typeArray objectAtIndex:trans.type];
			break;
		
		case ROW_VALUE:
			name.text = NSLocalizedString(@"Amount", @"");
			value.text = [DataModel currencyString:trans.evalue];
			break;
		
		case ROW_DESC:
			name.text = NSLocalizedString(@"Name", @"Description");
			value.text = trans.description;
			break;
			
		case ROW_MEMO:
			name.text = NSLocalizedString(@"Memo", @"");
			value.text = trans.memo;
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
	UIViewController *vc;
	switch (indexPath.row) {
		case ROW_DATE:
			editDateVC.date = trans.date;
			vc = editDateVC;
			break;
		case ROW_TYPE:
			editTypeVC.type = trans.type;
			vc = editTypeVC;
			break;
		case ROW_VALUE:
			editValueVC.value = trans.evalue;
			vc = editValueVC;
			break;
		case ROW_DESC:
			editDescVC.description = trans.description;
			vc = editDescVC;
			break;
		case ROW_MEMO:
			editMemoVC.text = trans.memo;
			vc = editMemoVC;
			break;
	}
	[nc pushViewController:vc animated:YES];
}

// イベントリスナ (下位 ViewController からの変更通知)
- (void)editDateViewChanged:(EditDateViewController *)vc
{
	trans.date = vc.date;
}
- (void)genEditTypeViewChanged:(GenEditTypeViewController*)vc identifier:(int)id
{
	trans.type = vc.type;
	if (trans.type == TYPE_ADJ) {
		trans.description = [typeArray objectAtIndex:TYPE_ADJ];
	}
}
- (void)editValueViewChanged:(EditValueViewController *)vc
{
	trans.evalue = vc.value;
}
- (void)editDescViewChanged:(EditDescViewController *)vc
{
	trans.description = vc.description;
}
- (void)genEditTextViewChanged:(GenEditTextViewController*)vc identifier:(int)id
{
	trans.memo = vc.text;
}

////////////////////////////////////////////////////////////////////////////////
// 削除処理
- (void)delButtonTapped
{
	[theDataModel.selAsset deleteTransactionAt:transactionIndex];
	[trans release];
	trans = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)delPastButtonTapped
{
	UIActionSheet *as = [[UIActionSheet alloc]
						 initWithTitle:nil delegate:self
						 cancelButtonTitle:@"Cancel"
						 destructiveButtonTitle:NSLocalizedString(@"Delete with all past transactions", @"")
						 otherButtonTitles:nil];
	as.actionSheetStyle = UIActionSheetStyleDefault;
	[as showInView:self.view];
	[as release];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 0) {
		//[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
		return; // cancelled;
	}

	Asset *asset = theDataModel.selAsset;
	Transaction *t = [asset transactionAt:transactionIndex];
	
	NSDate *date = t.date;
	[asset deleteOldTransactionsBefore:date];
	
	[trans release];
	trans = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// 保存処理
- (void)saveAction
{
	Asset *asset = theDataModel.selAsset;
	
	if (transactionIndex < 0) {
		//[dm assignSerial:trans];
		[asset insertTransaction:trans];
	} else {
		[asset replaceTransactionAtIndex:transactionIndex withObject:trans];
		[asset sortByDate];
	}
	[trans release];
	trans = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
