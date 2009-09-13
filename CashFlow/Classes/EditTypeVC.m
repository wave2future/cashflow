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

/**
   取引種類指定 View

   Note: 本Viewは、自動で popViewController しない
   理由は、別の View を上に乗せており、利用する側のクラスで
   popToViewController するため。
*/

#import "AppDelegate.h"
#import "EditTypeVC.h"
#import "Transaction.h"

@implementation EditTypeViewController

@synthesize delegate, type, dst_asset;

- (id)init
{
    self = [super initWithNibName:@"EditTypeView" bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Type", @"");
        dst_asset = -1;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#if FREE_VERSION
/    return 3;   // Free版は資産間移動なし
//#else
    return 4;
//#endif
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"editTypeViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
    }
    if (indexPath.row == self.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
		
    NSString *t;
    switch (indexPath.row) {
    case 0:
        t = @"Payment";
        break;
    case 1:
        t = @"Deposit";
        break;
    case 2:
        t = @"Adjustment";
        break;
    case 3:
        t = @"Transfer";
        break;
    }
    cell.text = NSLocalizedString(t, @"");

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.type = indexPath.row;

    if (self.type != TYPE_TRANSFER) {
        // pop しない
        [delegate editTypeViewChanged:self];
        return;
    }

    // 資産間移動
    Ledger *ledger = [DataModel ledger];
    int assetCount = [ledger assetCount];
    NSMutableArray *assetNames = [[[NSMutableArray alloc] initWithCapacity:assetCount] autorelease];
    for (int i = 0; i < assetCount; i++) {
        Asset *asset = [ledger assetAtIndex:i];
        [assetNames addObject:asset.name];
    }
    
    GenSelectListViewController *vc;
    vc = [GenSelectListViewController genSelectListViewController:self
                                    items:assetNames
                                    title:NSLocalizedString(@"Asset", @"")
                                    identifier:0];
    vc.selectedIndex = [ledger assetIndexWithKey:dst_asset];

    [self.navigationController pushViewController:vc animated:YES];
}

// 資産選択
- (BOOL)genSelectListViewChanged:(GenSelectListViewController*)vc identifier:(int)id
{
    Asset *as = [[DataModel ledger] assetAtIndex:vc.selectedIndex];
    dst_asset = as.pkey;

    [delegate editTypeViewChanged:self];

    return NO; // pop しない
}

@end
