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
#import "AssetListVC.h"
#import "Asset.h"
#import "AssetVC.h"
#import "TransactionListVC.h"
#import "CategoryListVC.h"
#import "ReportVC.h"
#import "InfoVC.h"
#import "BackupServer.h"
#import "Pin.h"
#import "ConfigViewController.h"

@implementation AssetListViewController

@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableView.rowHeight = 48;

    ledger = [DataModel ledger];
	
    // title 設定
    self.title = NSLocalizedString(@"Assets", @"");
	
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
    ASSERT(icon1 != nil);
	
    imagePath = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"png"];
    UIImage *icon2 = [UIImage imageWithContentsOfFile:imagePath];
    ASSERT(icon2 != nil);
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"card" ofType:@"png"];
    UIImage *icon3 = [UIImage imageWithContentsOfFile:imagePath];
    ASSERT(icon3 != nil);
    
    iconArray = [[NSArray alloc] initWithObjects:icon1, icon2, icon3, nil];
	
    // 最後に使った Asset に遷移する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int firstShowAssetIndex = [defaults integerForKey:@"firstShowAssetIndex"];
    if (firstShowAssetIndex >= 0 && [ledger assetCount] > firstShowAssetIndex) {
        Asset *asset = [ledger assetAtIndex:firstShowAssetIndex];
		
        // TransactionListView を表示
        TransactionListViewController *vc = 
            [[[TransactionListViewController alloc] init] autorelease];
        vc.asset = asset;
        [self.navigationController pushViewController:vc animated:NO];
    }

    PinController *pinController = [[[PinController alloc] init] autorelease];
    [pinController firstPinCheck:self];
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
}

- (void)dealloc {
    [tableView release];
    [iconArray release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

    [ledger rebuild]; // ### 必要？？？

    [tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 最初に起動する画面を資産一覧画面にする
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:-1 forKey:@"firstShowAssetIndex"];
    [defaults synchronize];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    if (tv.editing) 
        return 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [ledger assetCount];

        case 1:
            return 1;
    }
    // NOT REACH HERE
    return 0;
}

- (int)_assetIndex:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row;
    }
    return -1;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tv.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSString *cellid = @"assetCell";
    cell = [tv dequeueReusableCellWithIdentifier:cellid];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }

    // 資産
    double value;
    NSString *label = nil;

    if (indexPath.section == 0) {
        Asset *asset = [ledger assetAtIndex:[self _assetIndex:indexPath]];
    
        label = asset.name;
        value = [asset lastBalance];

        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.imageView.image = [iconArray objectAtIndex:asset.type];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // 合計欄
            value = 0.0;
            int i;
            for (i = 0; i < [ledger assetCount]; i++) {
                value += [[ledger assetAtIndex:i] lastBalance];
            }
            label = [NSString stringWithFormat:@"            %@", NSLocalizedString(@"Total", @"")];

            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
        }
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", label,
                          [DataModel currencyString:value]];
    if (value >= 0) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }
	
    return cell;
}

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex < 0) return;

    // save preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:assetIndex forKey:@"firstShowAssetIndex"];
    [defaults synchronize];
	
    Asset *asset = [ledger assetAtIndex:assetIndex];

    // TransactionListView を表示
    TransactionListViewController *vc = 
        [[[TransactionListViewController alloc] init] autorelease];
    vc.asset = asset;

    [self.navigationController pushViewController:vc animated:YES];
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    AssetViewController *vc = [[[AssetViewController alloc] init] autorelease];
    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex >= 0) {
        [vc setAssetIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 新規アセット追加
- (void)addAsset
{
    AssetViewController *vc = [[[AssetViewController alloc] init] autorelease];
    [vc setAssetIndex:-1];
    [self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [self.tableView setEditing:editing animated:editing];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)tableView:(UITableView*)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0)
        return NO;
    return YES;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        int assetIndex = [self _assetIndex:indexPath];
        assetToBeDelete = [ledger assetAtIndex:assetIndex];

        asDelete =
            [[UIActionSheet alloc]
                initWithTitle:NSLocalizedString(@"ReallyDeleteAsset", @"")
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:NSLocalizedString(@"Delete Asset", @"")
                otherButtonTitles:nil];
        asDelete.actionSheetStyle = UIActionSheetStyleDefault;
        [asDelete showInView:self.view];
        [asDelete release];
    }
}

- (void)_actionDelete:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    [ledger deleteAsset:assetToBeDelete];
    [self.tableView reloadData];
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tv
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    // 合計額(section:1)には移動させない
    NSIndexPath *idx = [NSIndexPath indexPathForRow:proposedIndexPath.row inSection:0];
    return idx;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    int fromIndex = [self _assetIndex:from];
    int toIndex = [self _assetIndex:to];
    if (fromIndex < 0 || toIndex < 0) return;

    [[DataModel ledger] reorderAsset:fromIndex to:toIndex];
}

//////////////////////////////////////////////////////////////////////////////////////////
// Action Sheet 処理

- (void)doAction:(id)sender
{
    asReport = 
        [[UIActionSheet alloc]
            initWithTitle:@"" delegate:self 
            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
            destructiveButtonTitle:nil
            otherButtonTitles:NSLocalizedString(@"Weekly Report", @""),
            NSLocalizedString(@"Monthly Report", @""),
            nil];
    [asReport showInView:[self view]];
    [asReport release];
}

- (void)_actionReport:(NSInteger)buttonIndex
{
    ReportViewController *reportVC;

    switch (buttonIndex) {
    case 0:
    case 1:
        reportVC = [[[ReportViewController alloc] init] autorelease];
        if (buttonIndex == 0) {
            reportVC.title = NSLocalizedString(@"Weekly Report", @"");
            [reportVC generateReport:REPORT_WEEKLY asset:nil];
        } else {
            reportVC.title = NSLocalizedString(@"Monthly Report", @"");
            [reportVC generateReport:REPORT_MONTHLY asset:nil];
        }
        [self.navigationController pushViewController:reportVC animated:YES];
        break;
    }
}

- (void)doConfig:(id)sender
{
    asConfig = 
        [[UIActionSheet alloc]
            initWithTitle:@"" delegate:self 
            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
            destructiveButtonTitle:nil
            otherButtonTitles:NSLocalizedString(@"Edit Categories", @""),
            NSLocalizedString(@"Backup", @""),
//#ifndef FREE_VERSION
            NSLocalizedString(@"Set PIN Code", @""),
//#endif
            NSLocalizedString(@"Config", @""),
            nil];
    [asConfig showInView:[self view]];
    [asConfig release];
}

- (void)_actionConfig:(NSInteger)buttonIndex
{
    CategoryListViewController *categoryVC;
    PinController *pinController;
    ConfigViewController *configVC;

    switch (buttonIndex) {
    case 0:
        categoryVC = [[[CategoryListViewController alloc] init] autorelease];
        categoryVC.isSelectMode = NO;
        [self.navigationController pushViewController:categoryVC animated:YES];
        break;

    case 1:
        [self doBackup];
        break;

    case 2:
        pinController = [[[PinController alloc] init] autorelease];
        [pinController modifyPin:self];
        break;
            
    case 3:
        configVC = [[[ConfigViewController alloc] init] autorelease];
        [self.navigationController pushViewController:configVC animated:YES];
        break;
    }
}

// actionSheet ハンドラ
- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as == asReport) {
        asReport = nil;
        [self _actionReport:buttonIndex];
    }
    else if (as == asConfig) {
        asConfig = nil;
        [self _actionConfig:buttonIndex];
    }
    else if (as == asDelete) {
        asDelete = nil;
        [self _actionDelete:buttonIndex];
    }
    else {
        ASSERT(NO);
    }
}

- (IBAction)showHelp:(id)sender
{
    InfoVC *v = [[[InfoVC alloc] init] autorelease];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)doBackup
{
    BOOL result = NO;
    NSString *message = nil;

    backupServer = [[BackupServer alloc] init];
    NSString *url = [backupServer serverUrl];
    if (url != nil) {
        result = [backupServer startServer];
    } else {
        message = NSLocalizedString(@"Network is unreachable.", @"");
    }
    
    UIAlertView *v;
    if (!result) {
        if (message == nil) {
            message = NSLocalizedString(@"Cannot start web server.", @"");
        }

        [backupServer release];
        v = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:message
             delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
             otherButtonTitles:nil];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"BackupNotation", @""), url];
        
        v = [[UIAlertView alloc]
             initWithTitle:NSLocalizedString(@"Backup and restore", @"")
             message:message
             delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
             otherButtonTitles:nil];
    }
    [v show];
    [v release];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [backupServer stopServer];
    [backupServer release];
    backupServer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
