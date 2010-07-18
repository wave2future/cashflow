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

// Asset

#import "AppDelegate.h"
#import "Asset.h"
#import "DataModel.h"

@implementation Asset

+ (id)allocator
{
    return [[[Asset alloc] init] autorelease];
}

- (id)init
{
    [super init];

    entries = [[NSMutableArray alloc] init];
    type = ASSET_CASH;
	
    return self;
}

- (void)dealloc 
{
    [entries release];
    [super dealloc];
}

//
// 仕訳帳(journal)から転記しなおす
//
- (void)rebuild
{
    if (entries != nil) {
        [entries release];
    }

    entries = [[NSMutableArray alloc] init];

    double balance = initialBalance;

    AssetEntry *e;
    for (Transaction *t in [DataModel journal]) {
        if (t.asset == self.pid || t.dst_asset == self.pid) {
            e = [[AssetEntry alloc] initWithTransaction:t withAsset:self];

            // 残高計算
            if (t.type == TYPE_ADJ && t.hasBalance) {
                // 残高から金額を逆算
                double oldval = t.value;
                t.value = t.balance - balance;
                if (t.value != oldval) {
                    // 金額が変更された場合、DBを更新
                    [t update];
                }
                balance = t.balance;

                e.value = t.value;
                e.balance = balance;
            }
            else {
                balance = balance + e.value;
                e.balance = balance;

                if (t.type == TYPE_ADJ) {
                    t.balance = balance;
                    t.hasBalance = YES;
                }
            }

            [entries addObject:e];
            [e release];
        }
    }
}

- (void)updateInitialBalance
{
    [self update];
}

////////////////////////////////////////////////////////////////////////////
// AssetEntry operations

- (int)entryCount
{
    return entries.count;
}

- (AssetEntry*)entryAt:(int)n
{
    return [entries objectAtIndex:n];
}

- (void)insertEntry:(AssetEntry *)e
{    
    [[DataModel journal] insertTransaction:e.transaction];
    [[DataModel ledger] rebuild];
}

- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)e
{
    AssetEntry *orig = [self entryAt:index];

    [[DataModel journal] replaceTransaction:orig.transaction withObject:e.transaction];
    [[DataModel ledger] rebuild];
}

// エントリ削除
// 注：entries からは削除されない。journal から削除されるだけ
- (void)_deleteEntryAt:(int)index
{
    // 先頭エントリ削除の場合は、初期残高を変更する
    if (index == 0) {
        initialBalance = [[self entryAt:0] balance];
        [self updateInitialBalance];
    }

    // エントリ削除
    AssetEntry *e = [self entryAt:index];
    [[DataModel journal] deleteTransaction:e.transaction withAsset:self];
}

// エントリ削除
- (void)deleteEntryAt:(int)index
{
    [self _deleteEntryAt:index];
    
    // 転記し直す
    [[DataModel ledger] rebuild];
}

// 指定日以前の取引をまとめて削除
- (void)deleteOldEntriesBefore:(NSDate*)date
{
    Database *db = [Database instance];

    [db beginTransaction];
    while (entries.count > 0) {
        AssetEntry *e = [entries objectAtIndex:0];
        if ([e.transaction.date compare:date] != NSOrderedAscending) {
            break;
        }

        [self _deleteEntryAt:0];
        [entries removeObjectAtIndex:0];
    }
    [db commitTransaction];

    [[DataModel ledger] rebuild];
}

- (int)firstEntryByDate:(NSDate*)date
{
    for (int i = 0; i < entries.count; i++) {
        AssetEntry *e = [entries objectAtIndex:i];
        if ([e.transaction.date compare:date] != NSOrderedAscending) {
            return i;
        }
    }
    return -1;
}

////////////////////////////////////////////////////////////////////////////
// Balance operations

- (double)lastBalance
{
    int max = [entries count];
    if (max == 0) {
        return initialBalance;
    }
    return [[entries objectAtIndex:max - 1] balance];
}

//
// Database operations
//
+ (BOOL)migrate
{
    BOOL ret = [super migrate];
    
    if (ret) {
        // newly created...
        Asset *as = [[[Asset alloc] init] autorelease];
        as.name = NSLocalizedString(@"Cash", @"");
        as.type = ASSET_CASH;
        as.initialBalance = 0;
        as.sorder = 0;
        [as insert];
    }
    return ret;
}


@end
