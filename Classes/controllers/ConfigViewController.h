// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "GenSelectListVC.h"

@interface ConfigViewController : UITableViewController <GenSelectListViewDelegate>
{
}

- (void)doneAction:(id)sender;

@end
