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

- (void)loadOldFormatData
{
    // Backward compatibility : try to load old format data
    DataModelV1 *dm1 = [DataModelV1 allocWithLoad];
    if (dm1 != nil) {
        [DataModelV1 deleteDataFile];

        initialBalance = dm1.initialBalance;
        transactions = dm1.transactions;
        [transactions retain];

        [dm1 release];
    }

    // Ok, write back database
    [self updateInitialBalance];

    Database *db = [Database instance];
    [db beginTransaction];

    // write all transactions
    int n = [transactions count];
    int i;
    for (i = 0; i < n; i++) {
        Transaction *t = [transactions objectAtIndex:i];
        t.asset = self.pkey;
        [t insertDb];
    }

    [db commitTransaction];

    // reload
    [self reload];
}

- (void)reload
{
    if (dirty) {
        [self clear];

        transactions = [Transaction loadTransactions:self];
        [transactions retain];

        // recalc balance
        [self recalcBalanceInitial];

        dirty = NO;
    }
}

- (void)setDirty
{
    dirty = YES;
}

- (void)resave
{
}

- (void)clear
{
    if (transactions != nil) {
        [transactions release];
    }
    transactions = nil;
}

- (void)updateInitialBalance
{
    DBStatement *stmt = [[Database instance] prepare:"UPDATE Assets SET initialBalance=? WHERE key=?;"];
    [stmt bindDouble:0 val:initialBalance];
    [stmt bindInt:1 val:pkey];
    [stmt step];
}

////////////////////////////////////////////////////////////////////////////
// Transaction operations

- (int)transactionCount
{
    return transactions.count;
}

- (Transaction*)transactionAt:(int)n
{
    return [transactions objectAtIndex:n];
}

// 資産間移動で変更される asset をマークする
- (void)_markAssetForTransfer:(Transaction*tr)
{
    if (tr.type == TYPE_TRANSFER &&
        tr.dst_asset != self.pkey) {
        Asset *asset = [theDataModel assetWithKey:tr.dst_asset];
        if (asset) {
            [asset setDirty];
        }
    }
}

- (void)insertTransaction:(Transaction*)tr
{
    int i;
    int max = [transactions count];
    Transaction *t = nil;

    [self _markAssetForTransfer:tr];

    // 挿入位置を探す
    for (i = 0; i < max; i++) {
        t = [transactions objectAtIndex:i];
        if ([tr.date compare:t.date] == NSOrderedAscending) {
            break;
        }
    }

    // 挿入
    [transactions insertObject:tr atIndex:i];

    // 全残高再計算
    [self recalcBalance];
	
    // 上限チェック
    if ([transactions count] > MAX_TRANSACTIONS) {
        [self deleteTransactionAt:0];
    }

    // DB 追加
    tr.asset = self.pkey;
    [tr insertDb];
}

// private
- (void)replaceTransactionAtIndex:(int)index withObject:(Transaction*)t
{
    [self _markAssetForTransfer:t];

    // copy key
    Transaction *old = [transactions objectAtIndex:index];
    t.pkey = old.pkey;

    [transactions replaceObjectAtIndex:index withObject:t];
    [self recalcBalance];

    // update DB
    [t updateDb];
}

- (void)deleteTransactionAt:(int)n
{
    // update DB
    Transaction *t = [transactions objectAtIndex:n];
    [self _markAssetForTransfer:t];

    [t deleteDb];

    // special handling for first transaction
    if (n == 0) {
        Transaction *t = [transactions objectAtIndex:0];
        initialBalance = t.balance;
        [self updateInitialBalance];
    }
	
    // remove
    [transactions removeObjectAtIndex:n];
    if (n > 0) {
        [self recalcBalance];
    }
}

- (void)deleteOldTransactionsBefore:(NSDate*)date
{
    Database *db = [Database instance];

    [db beginTransaction];
    while (transactions.count > 0) {
        Transaction *t = [transactions objectAtIndex:0];
        if ([t.date compare:date] != NSOrderedAscending) {
            break;
        }

        [self deleteTransactionAt:0];
    }
    [db commitTransaction];
}

- (int)firstTransactionByDate:(NSDate*)date
{
    for (int i = 0; i < transactions.count; i++) {
        Transaction *t = [transactions objectAtIndex:i];
        if ([t.date compare:date] != NSOrderedAscending) {
            return i;
        }
    }
    return -1;
}

// sort
static int compareByDate(Transaction *t1, Transaction *t2, void *context)
{
    return [t1.date compare:t2.date];
}

- (void)sortByDate
{
    [transactions sortUsingFunction:compareByDate context:NULL];
    [self recalcBalance];
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
    Transaction *t;
    double bal;
    int max = [transactions count];
    int i;

    Database *db = [Database instance];
    [db beginTransaction];

    bal = initialBalance;
    for (i = 0; i < max; i++) {
        double oldval;

        t = [self transactionAt:i];
        oldval = t.value;
        bal = [t fixBalance:bal isInitial:isInitial];

        if (t.value != oldval) {
            // 金額が変更された場合(残高照会取引)、DB を更新
            [t updateDb];
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
