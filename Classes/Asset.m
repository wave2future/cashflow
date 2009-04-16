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
#import "DataModelV1.h"

@implementation Asset

@synthesize pkey, type, name, sorder;
@synthesize initialBalance;

- (id)init
{
    [super init];

    pkey = 1; // とりあえず
    dirty = YES;

    initialBalance = 0.0;
    transactions = [[NSMutableArray alloc] init];
    type = ASSET_CASH;
    self.name = @"";
	
    return self;
}

- (void)dealloc 
{
    [transactions release];
    [name release];

    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////
// Load / Save DB


//
// 仕訳帳(journal)から転記しなおす
//
- (void)rebuild
{
    if (entries != nil) {
        [entries release];
    }

    entries = [[NSMutableArray alloc] init];

    AssetEntry *e;
    for (Transaction *t in [DataModel journal]) {
        if (t.asset == self.pkey || t.dst_asset == self.pkey) {
            e = [[AssetEntry alloc] init];
            [e setAsset:self transaction:t];

            [entries addObject:e];
            [e release];
        }
    }
    [self recalcBalanceInitial];
}

- (void)updateInitialBalance
{
    DBStatement *stmt = [[Database instance] prepare:"UPDATE Assets SET initialBalance=? WHERE key=?;"];
    [stmt bindDouble:0 val:initialBalance];
    [stmt bindInt:1 val:pkey];
    [stmt step];
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
    [DataModel rebuild];
}

- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)e
{
    AssetEntry *orig = [self entryAt:index];

    [[DataModel journal] replaceTransaction:orig.transaction withObject:e.transaction];
    [DataModel rebuild];
}

- (void)_deleteEntryAt:(int)index
{
    // 初期残高変更
    if (index == 0) {
        initialBalance = [[self entryAt:0] balance];
        [self updateInitialBalance];
    }

    AssetEntry *e = [self entryAt:index];
    [[DataModel journal] deleteTransaction:e.transaction];
}

- (void)deleteEntryAt:(int)index
{
    [self _deleteEntryAt:index];
    [DataModel rebuild];
}

- (void)deleteOldTransactionsBefore:(NSDate*)date
{
    Database *db = [Database instance];

    [db beginTransaction];
    while (entries.count > 0) {
        AssetEntry *e = [entries objectAtIndex:0];
        if ([e.transaction.date compare:date] != NSOrderedAscending) {
            break;
        }

        [self _deleteEntryAt:0];
    }
    [db commitTransaction];
    [DataModel rebuild];
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

// balance 値がない状態で、balance を計算する
- (void)recalcBalanceInitial
{
    [self recalcBalanceSub:YES];
}

- (void)recalcBalance
{
    [self recalcBalanceSub:NO];
}

- (void)recalcBalanceSub:(BOOL)isInitial
{
    double bal;

    Database *db = [Database instance];
    [db beginTransaction];
    bal = initialBalance;

    for (AssetEntry *e in entries) {
        if (e.transaction.type == TYPE_ADJ && !isInitial) {
            // 残高調整取引: 金額のほうを変更する
            e.value = e.balance - bal;
            e.transaction.value = e.value;

            // DB を更新
            [e.transaction updateDb];
        } 
        else {
            bal = bal + e.value;
            e.balance = bal;
        }
    }

    [db commitTransaction];
}

- (double)lastBalance
{
    int max = [transactions count];
    if (max == 0) {
        return initialBalance;
    }
    return [[transactions objectAtIndex:max - 1] balance];
}

//
// Database operations
//
+ (void)createTable
{
    Database *db = [Database instance];

    [db execSql:"CREATE TABLE Assets ("
        "key INTEGER PRIMARY KEY,"
        "name TEXT,"
        "type INTEGER,"
        "initialBalance REAL,"
        "sorder INTEGER);"];

    char sql[256];
    sqlite3_snprintf(sizeof(sql), sql,
                     "INSERT INTO Assets VALUES(1, %Q, 0, 0.0, 0);", 
                     [NSLocalizedString(@"Cash", @"") UTF8String]);
    [db execSql:sql];
}


@end

////////////////////////////////////////////////////////////////////////////
// AssetEntry

@implementation AssetEntry

@synthesize asset, transaction, balance;

- (id)init
{
    self = [super init];

    transaction = nil;
    asset = -1;
    value = 0.0;
    balance = 0.0;

    return self;
}

- (void)dealloc
{
    [release transaction];
    [super dealloc];
}

- (void)setAsset:(Asset *)asset transaction:(Transaction *)t
{
    asset = asset.pkey;
    if (t != transaction) {
        [transaction release];
        transaction = [t retain];
    }
    
    if (t == nil) {
        transaction = [[Transaction alloc] init];
        transaction.asset = asset;
    }
    
    if (asset == t.asset) {
        // normal
        value = t.value;
    } else {
        value = -t.value;
    }
}

- (double)value
{
    return value;
}

- (void)setValue:(double)v
{
    value = v;

    if (asset == transaction.asset) {
        // normal
        transaction.value = value;
    } else {
        transaction.value = -value;
    }
}    

// 編集値を返す
- (double)evalue
{
    double ret;

    switch (type) {
    case TYPE_INCOME:
        ret = value;
        break;
    case TYPE_OUTGO:
        ret = -value;
        break;
    case TYPE_ADJ:
        ret = balance;
        break;
    case TYPE_TRANSFER:
        ret = value;
        break;
    }
	
    if (ret == 0.0) {
        ret = 0.0;	// avoid '-0'
    }
    return ret;
}

- (void)setEvalue:(double)v
{
    switch (type) {
    case TYPE_INCOME:
        self.value = v;
        break;
    case TYPE_OUTGO:
        self.value = -v;
        break;
    case TYPE_ADJ:
        balance = v;
        break;
    case TYPE_TRANSFER:
        self.value = v;
        break;
    }
}

// 転送先資産キーを返す
- (int)dstAsset
{
    if (transaction.type != TYPE_TRANSFER) {
        return -1;
    }

    if (transaction.asset == asset) {
        return transaction.dst_asset;
    }
    return transaction.asset;
}

- (void)setDstAsset:as
{
    if (transaction.type != TYPE_TRANSFER) {
        // ###
        return;
    }

    if (transaction.asset == asset) {
        transaction.dst_asset = as;
    }
    transaction.asset = as;
}

- (id)copyWithZone:(NSZone *)zone
{
    AssetEntry *e = [[AssetEntry alloc] init];
    e.asset = self.asset;
    e.value = self.value;
    e.balance = self.balance;
    e.transaction = [self.transaction copy];
}

@end
