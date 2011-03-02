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


#import <UIKit/UIKit.h>
#import "TransactionVC.h"
#import "ExportVC.h"
#import "DataModel.h"
#import "CalcVC.h"

#if FREE_VERSION
#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"
#endif

@class AssetListViewController;

@interface TransactionListViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate
#if FREE_VERSION
, GADAdViewControllerDelegate
#endif
>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarBalanceLabel;
    IBOutlet UIBarButtonItem *mBarActionButton;
	
    Asset *mAsset;
#if FREE_VERSION
    GADAdViewController *mAdViewController;
#endif
    
    BOOL mAsDisplaying;
    
    // for Split view
    IBOutlet AssetListViewController *splitAssetListViewController;
    UIPopoverController *mPopoverController;
}

//- (UITableView*)tableView;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,assign) Asset *asset;
@property(nonatomic,retain) UIPopoverController *popoverController;

- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath;
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)initialBalanceCell;
- (void)reload;
- (void)updateBalance;
- (void)addTransaction;
- (IBAction)doAction:(id)sender;
- (IBAction)showHelp:(id)sender;

- (UITableViewCell *)_entryCell:(AssetEntry *)e;
- (void)_replaceAd;

@end
