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

@implementation AssetListViewController

@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
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
        [self.navigationController pushViewController:vc animated:NO];
    }

#ifndef FREE_VERSION
    PinController *pinController = [[[PinController alloc] init] autorelease];
    [pinController firstPinCheck:self];
#endif
}

- (void)dealloc {
    [tableView release];
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
		
        cell.font = [UIFont systemFontOfSize:16.0];
    }

    Asset *asset = [theDataModel assetAtIndex:indexPath.row];
    double lastBalance = [asset lastBalance];
    cell.text = [NSString stringWithFormat:@"%@ : %@", asset.name, [DataModel currencyString:lastBalance]];
    if (lastBalance >= 0) {
        cell.textColor = [UIColor blackColor];
    } else {
        cell.textColor = [UIColor redColor];
    }
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
    // return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        assetToBeDelete = [theDataModel assetAtIndex:indexPath.row];

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
	
    [theDataModel deleteAsset:assetToBeDelete];
    [self.tableView reloadData];
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
        reportVC = [[[ReportViewController alloc] initWithNibName:@"ReportView" bundle:[NSBundle mainBundle]] autorelease];
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
#ifndef FREE_VERSION
            NSLocalizedString(@"Set PIN Code", @""),
#endif
            nil];
    [asConfig showInView:[self view]];
    [asConfig release];
}

- (void)_actionConfig:(NSInteger)buttonIndex
{
    CategoryListViewController *categoryVC;
#ifndef FREE_VERSION
    PinController *pinController;
#endif

    switch (buttonIndex) {
    case 0:
        categoryVC = [[[CategoryListViewController alloc] 
                          initWithNibName:@"CategoryListView" 
                          bundle:[NSBundle mainBundle]] autorelease];
        categoryVC.isSelectMode = NO;
        [self.navigationController pushViewController:categoryVC animated:YES];
        break;

    case 1:
        [self doBackup];
        break;

#ifndef FREE_VERSION
    case 2:
        pinController = [[[PinController alloc] init] autorelease];
        [pinController modifyPin:self];
        break;
#endif
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
    InfoVC *v = [[InfoVC alloc] initWithNibName:@"InfoView" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:v animated:YES];
    [v release];
}

- (void)doBackup
{
    BOOL result = NO;
    
    backupServer = [[BackupServer alloc] init];
    NSString *url = [backupServer serverUrl];
    if (url != nil) {
        result = [backupServer startServer];
    }
    
    UIAlertView *v;
    if (!result) {
        [backupServer release];
        v = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:NSLocalizedString(@"Cannot start web server.", @"")
             delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
             otherButtonTitles:nil];
    } else {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"BackupNotation", @""), url];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
