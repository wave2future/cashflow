// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "Database.h"
#import "AssetBase.h"
#import "AssetEntry.h"

// asset types
#define ASSET_CASH  0
#define ASSET_BANK  1
#define	ASSET_CARD  2

#define MAX_TRANSACTIONS	5000

@class Database;

//
// 資産 (総勘定元帳の勘定に相当)
// 
@interface Asset : AssetBase {
    NSMutableArray *mEntries; // AssetEntry の配列
    //double mLastBalance;
}

- (void)rebuild;

- (int)entryCount;
- (AssetEntry *)entryAt:(int)n;
- (void)insertEntry:(AssetEntry *)tr;
- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)t;
- (void)_deleteEntryAt:(int)n;
- (void)deleteEntryAt:(int)n;
- (void)deleteOldEntriesBefore:(NSDate*)date;
- (int)firstEntryByDate:(NSDate*)date;

- (double)lastBalance;
- (void)updateInitialBalance;

@end
