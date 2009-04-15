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


#import "EditTypeVC.h"
#import "Transaction.h"

@implementation EditTypeViewController

@synthesize listener, type, dst_asset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = NSLocalizedString(@"Type", @"");

        typeArray = [[NSArray alloc] initWithObjects:
                                         NSLocalizedString(@"Payment", @""),
                                     NSLocalizedString(@"Deposit", @""),
                                     NSLocalizedString(@"Adjustment", @"Balance adjustment"),
                                     NSLocalizedString(@"Transfer", @"");
                                     nil];
        dst_asset = -1;
    }
    return self;
}

- (void)dealloc
{
    [typeArray release];
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
    return [typeArray count];
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
		
    cell.text = [typeArray objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.type = indexPath.row;

    if (self.type != TYPE_TRANSFER) {
        [listener editTypeViewChanged:self identifier:identifier];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // 資産間移動
    int assetCount = [theDataModel assetCount];
    NSMutableArray *assetNames = [[[NSMutableArray alloc] initWithCapacity:assetCount] autorelease];
    for (int i = 0; i < assetCount; i++) {
        Asset *asset = [theDataModel assetAtIndex:i];
        [assetNames addObject:asset.name];
    }
    
    GenEditTypeViewController *vc;
    vc = [GenEditTypeViewController genEditTypeViewController:self
                                    array:assetNames
                                    title:NSLocalizedString(@"Asset", @"")
                                    identifier:0];

    //vc.type = dst_asset;

    [self.navigationController pushViewController:vc animated:YES];
}

// 資産選択
- (void)genEditTypeViewChanged:(GenEditTypeViewController*)vc identifier:(int)id
{
    Asset *as = [theDataModel assetAtIndex:vc.type];
    dst_asset = as.pkey;

    [listener editTypeViewChanged:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
