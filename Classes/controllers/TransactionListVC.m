// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2009, Takuya Murakami, All rights reserved.

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


#import "TransactionListVC.h"
#import "AppDelegate.h"
#import "Transaction.h"
#import "InfoVC.h"
#import "CalcVC.h"
#import "ReportVC.h"
#import "ConfigViewController.h"
#import "AssetListVC.h"
#import "Backup.h"

#if FREE_VERSION
#import "AdUtil.h"
#endif

@implementation TransactionListViewController

@synthesize tableView;
@synthesize asset;
@synthesize popoverController;

- (id)init
{
    self = [super initWithNibName:@"TransactionListView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"TransactionListViewController:viewDidLoad");

    [super viewDidLoad];
	
    // title 設定
    //self.title = NSLocalizedString(@"Transactions", @"");
    if (asset == nil) {
        self.title = @"";
    } else {
        self.title = asset.name;
    }
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addTransaction)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
    [plusButton release];
	
    // Edit ボタンを追加
    // TBD
    //self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    asDisplaying = NO;

#if FREE_VERSION
    adViewController = nil;
#endif
}

- (void)viewDidUnload
{
    //NSLog(@"TransactionListViewController:viewDidUnload");

#if FREE_VERSION
    [adViewController release];
    adViewController = nil;
#endif
}

#if FREE_VERSION
// GADAdViewControllerDelegate
- (UIViewController *)viewControllerForModalPresentation:(GADAdViewController *)adController
{
    return self.navigationController;
}

- (GADAdClickAction)adControllerActionModelForAdClick:(GADAdViewController *)adController
{
    return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [tableView release];
    [popoverController release];
#if FREE_VERSION
    [adViewController release];
#endif
    
    [super dealloc];
}

- (void)reload
{
    self.title = self.asset.name;
    [self updateBalance];
    [self.tableView reloadData];

    if (popoverController != nil && [popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
    }
}    

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"TransactionListViewController:viewWillAppear");

    [super viewWillAppear:animated];
    [self reload];

#if FREE_VERSION
    if (adViewController == nil) {
        [self _replaceAd];
    }
#endif
}

- (void)_replaceAd
{
#if FREE_VERSION
    // Google Adsense バグ暫定対処
    // AdSense が起動時に正しく表示されずクラッシュする場合があるため、
    // 前回正しく表示できていない場合は初回表示させない
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int n = [defaults integerForKey:@"ShowAds"];
    if (n == 0) {
        [defaults setInteger:1 forKey:@"ShowAds"]; // show next time
        [defaults synchronize];
        return;
    }
    [defaults setInteger:0 forKey:@"ShowAds"];
    [defaults synchronize];
    
    if (adViewController != nil) {
        [adViewController.view removeFromSuperview];
        [adViewController release];
        adViewController = nil;
    }
    
    CGRect frame = tableView.bounds;
    
    // 画面下部固定で広告を作成する
    adViewController= [[GADAdViewController alloc] initWithDelegate:self];
    if (IS_IPAD) {
        //adViewController.adSize = kGADAdSize468x60;
        adViewController.adSize = kGADAdSize320x50;
    } else {
        adViewController.adSize = kGADAdSize320x50;
    }
    adViewController.autoRefreshSeconds = 180;
    
    NSDictionary *attributes = [AdUtil adAttributes];
    
    @try {
        [adViewController loadGoogleAd:attributes];
    }
    @catch (NSException * e) {
        NSLog(@"loadGoogleAd: exception: %@", [e description]);
    }
    
    UIView *adView = adViewController.view;
    float adViewWidth = [adView bounds].size.width;
    float adViewHeight = [adView bounds].size.height;
    
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adViewWidth) / 2;
    aframe.origin.y = frame.size.height - adViewHeight;
    aframe.size.height = adViewHeight;
    aframe.size.width = adViewWidth;
    adView.frame = aframe;
    adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:adView];
    
    // 広告領域分だけ、tableView の下部をあける
    CGRect tframe = frame;
    tframe.size.height -= adViewHeight;
    tableView.frame = tframe;
    
    [defaults setInteger:1 forKey:@"ShowAds"];
    [defaults synchronize];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"TransactionListViewController:viewDidAppear");

    [super viewDidAppear:animated];
}

- (void)updateBalance
{
    double lastBalance = [asset lastBalance];
    NSString *bstr = [CurrencyManager formatCurrency:lastBalance];

#if 0
    UILabel *tableTitle = (UILabel *)[self.tableView tableHeaderView];
    tableTitle.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), bstr];
#endif
	
    barBalanceLabel.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), bstr];
    
    if (IS_IPAD) {
        [splitAssetListViewController reload];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (IBAction)showHelp:(id)sender
{
    InfoVC *v = [[[InfoVC alloc] init] autorelease];
    //[self.navigationController pushViewController:v animated:YES];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:v];
    if (IS_IPAD) {
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:nc animated:YES];
    [nc release];
}


#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (asset == nil) return 0;
    
    int n = [asset entryCount] + 1;
    return n;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

// 指定セル位置に該当する entry Index を返す
- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath
{
    int idx = ([asset entryCount] - 1) - indexPath.row;
    return idx;
}

// 指定セル位置の Entry を返す
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath
{
    int idx = [self entryIndexWithIndexPath:indexPath];

    if (idx < 0) {
        return nil;  // initial balance
    } 
    AssetEntry *e = [asset entryAt:idx];
    return e;
}

//
// セルの内容を返す
//
#define TAG_DESC 1
#define TAG_DATE 2
#define TAG_VALUE 3
#define TAG_BALANCE 4

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	
    AssetEntry *e = [self entryWithIndexPath:indexPath];
    if (e) {
        cell = [self _entryCell:e];
    }
    else {
        cell = [self initialBalanceCell];
    }

    return cell;
}

// Entry セルの生成 (private)
- (UITableViewCell *)_entryCell:(AssetEntry *)e
{
    NSString *cellid = @"transactionCell";

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    UILabel *descLabel, *dateLabel, *valueLabel, *balanceLabel;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 220, 24)] autorelease];
        descLabel.tag = TAG_DESC;
        descLabel.font = [UIFont systemFontOfSize: 18.0];
        descLabel.textColor = [UIColor blackColor];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:descLabel];
		
        valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(190, 0, 120, 24)] autorelease];
        valueLabel.tag = TAG_VALUE;
        valueLabel.font = [UIFont systemFontOfSize: 18.0];
        valueLabel.textAlignment = UITextAlignmentRight;
        valueLabel.textColor = [UIColor blueColor];
        valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:valueLabel];
		
        dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 24, 160, 20)] autorelease];
        dateLabel.tag = TAG_DATE;
        dateLabel.font = [UIFont systemFontOfSize: 14.0];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:dateLabel];
		
        balanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150, 24, 160, 20)] autorelease];
        balanceLabel.tag = TAG_BALANCE;
        balanceLabel.font = [UIFont systemFontOfSize: 14.0];
        balanceLabel.textAlignment = UITextAlignmentRight;
        balanceLabel.textColor = [UIColor grayColor];
        balanceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:balanceLabel];
    } else {
        descLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DESC];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DATE];
        valueLabel = (UILabel *)[cell.contentView viewWithTag:TAG_VALUE];
        balanceLabel = (UILabel *)[cell.contentView viewWithTag:TAG_BALANCE];
    }

    descLabel.text = e.transaction.description;
    dateLabel.text = [[DataModel dateFormatter] stringFromDate:e.transaction.date];
	
    double v = e.value;
    if (v >= 0) {
        valueLabel.textColor = [UIColor blueColor];
    } else {
        v = -v;
        valueLabel.textColor = [UIColor redColor];
    }
    valueLabel.text = [CurrencyManager formatCurrency:v];
    balanceLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), 
                         [CurrencyManager formatCurrency:e.balance]];
	
    return cell;
}

// 初期残高セルの生成 (private)
- (UITableViewCell *)initialBalanceCell
{
    NSString *cellid = @"initialBalanceCell";

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    UILabel *descLabel, *balanceLabel;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
        descLabel.font = [UIFont systemFontOfSize: 18.0];
        descLabel.textColor = [UIColor blackColor];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        descLabel.text = NSLocalizedString(@"Initial Balance", @"");
        [cell.contentView addSubview:descLabel];

        balanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150, 24, 160, 20)] autorelease];
        balanceLabel.tag = TAG_BALANCE;
        balanceLabel.font = [UIFont systemFontOfSize: 14.0];
        balanceLabel.textAlignment = UITextAlignmentRight;
        balanceLabel.textColor = [UIColor grayColor];
        balanceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:balanceLabel];
    } else {
        balanceLabel = (UILabel *)[cell.contentView viewWithTag:TAG_BALANCE];
    }

    balanceLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), 
                                  [CurrencyManager formatCurrency:asset.initialBalance]];

    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int idx = [self entryIndexWithIndexPath:indexPath];
    if (idx == -1) {
        // initial balance cell
        CalculatorViewController *v = [[[CalculatorViewController alloc] init] autorelease];
        v.delegate = self;
        v.value = asset.initialBalance;

        UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:v] autorelease];
        
        if (!IS_IPAD) {
            [self presentModalViewController:nv animated:YES];
        } else {
            if (self.popoverController) {
                [self.popoverController dismissPopoverAnimated:YES];
            }
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:nv] autorelease];
            [self.popoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (idx >= 0) {
        // transaction view を表示
        TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
        vc.asset = self.asset;
        [vc setTransactionIndex:idx];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 初期残高変更処理
- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    asset.initialBalance = vc.value;
    [asset updateInitialBalance];
    [asset rebuild];
    [self reload];
}

// 新規トランザクション追加
- (void)addTransaction
{
    if (asset == nil) return;
    
    TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
    vc.asset = self.asset;
    [vc setTransactionIndex:-1];
    [self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (asset == nil) return;
    
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [tableView setEditing:editing animated:animated];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath];
    if (entryIndex < 0) {
        return UITableViewCellEditingStyleNone;
    } 
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath];

    if (entryIndex < 0) {
        // initial balance cell : do not delete!
        return;
    }
	
    if (style == UITableViewCellEditingStyleDelete) {
        [asset deleteEntryAt:entryIndex];
	
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateBalance];
        [self.tableView reloadData];
    }

    if (IS_IPAD) {
        [splitAssetListViewController reload];
    }
}

#pragma mark Action sheet handling

// action sheet
- (void)doAction:(id)sender
{
    if (asDisplaying) return;
    asDisplaying = YES;
    
    UIActionSheet *as = 
        [[UIActionSheet alloc]
         initWithTitle:@"" 
         delegate:self 
         cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
         destructiveButtonTitle:nil otherButtonTitles:
         NSLocalizedString(@"Weekly Report", @""),
         NSLocalizedString(@"Monthly Report", @""),
         NSLocalizedString(@"Export", @""),
         NSLocalizedString(@"Backup", @""),
         NSLocalizedString(@"Config", @""),
         nil];
    if (IS_IPAD) {
        [as showFromBarButtonItem:barActionButton animated:YES];
    } else {
        [as showInView:[self view]];
    }
    [as release];
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ReportViewController *reportVC;
    ExportVC *exportVC;
    ConfigViewController *configVC;
    Backup *backup;
    
    UIViewController *vc;
    UIModalPresentationStyle modalPresentationStyle = UIModalPresentationPageSheet;
    
    asDisplaying = NO;
    
    switch (buttonIndex) {
        case 0:
        case 1:
            reportVC = [[[ReportViewController alloc] init] autorelease];
            if (buttonIndex == 0) {
                reportVC.title = NSLocalizedString(@"Weekly Report", @"");
                [reportVC generateReport:REPORT_WEEKLY asset:asset];
            } else {
                reportVC.title = NSLocalizedString(@"Monthly Report", @"");
                [reportVC generateReport:REPORT_MONTHLY asset:asset];
            }
            vc = reportVC;
            break;
			
        case 2:
            exportVC = [[[ExportVC alloc] initWithAsset:asset] autorelease];
            vc = exportVC;
            modalPresentationStyle = UIModalPresentationFormSheet;
            break;
            
        case 3:
            backup = [[Backup alloc] init];
            [backup execute];
            return; // do not release back instance here!
            
        case 4:
            configVC = [[[ConfigViewController alloc] init] autorelease];
            vc = configVC;
            modalPresentationStyle = UIModalPresentationFormSheet;
            break;
            
        default:
            return;
    }

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if (IS_IPAD) {
        nv.modalPresentationStyle = modalPresentationStyle;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentModalViewController:nv animated:YES];
    [nv release];
}

#pragma mark Split View Delegate

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    barButtonItem.title = NSLocalizedString(@"Assets", @"");
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    self.popoverController = nil;
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
