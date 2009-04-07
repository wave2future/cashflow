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

@synthesize db, pkey, type, name, sorder;
@synthesize initialBalance;

- (id)init
{
    [super init];

    pkey = 1; // とりあえず

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

    [db beginTransaction];

#if 0
    // delete all transactions
    DBStatement *stmt = [db prepare:"DELETE FROM Transactions WHERE asset = ?;"];
    [stmt bindInt:1 val:pkey];
    [stmt step];
#endif

    // write all transactions
    int n = [transactions count];
    int i;
    for (i = 0; i < n; i++) {
        Transaction *t = [transactions objectAtIndex:i];
        [self insertTransactionDb:t];
    }

    [db commitTransaction];

    // reload
    [self reload];
}

- (void)reload
{
    DBStatement *stmt;

    [self clear];

    /* load transactions */
    stmt = [db prepare:"SELECT key, date, type, category, value, description, memo"
               " FROM Transactions WHERE asset = ? ORDER BY date;"];
    [stmt bindInt:1 val:pkey];

    transactions = [[NSMutableArray alloc] init];

    while ([stmt step] == SQLITE_ROW) {
        Transaction *t = [[Transaction alloc] init];
        t.pkey = [stmt colInt:0];
        t.date = [stmt colDate:1];
        t.type = [stmt colInt:2];
        t.category = [stmt colInt:3];
        t.value = [stmt colDouble:4];
        t.description = [stmt colString:5];
        t.memo = [stmt colString:6];

        if (t.date == nil) {
            // fail safe
            NSLog(@"Invalid date: %@", [stmt colString:1]);
            [t release];
            continue;
        }

        [transactions addObject:t];
        [t release];
    }

    // recalc balance
    [self recalcBalanceInitial];
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
    DBStatement *stmt = [db prepare:"UPDATE Assets SET initialBalance=? WHERE key=?;"];
    [stmt bindDouble:1 val:initialBalance];
    [stmt bindInt:2 val:pkey];
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

- (void)insertTransaction:(Transaction*)tr
{
    int i;
    int max = [transactions count];
    Transaction *t = nil;

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
    [self insertTransactionDb:tr];
}

// private
- (void)insertTransactionDb:(Transaction*)t
{
    static DBStatement *stmt = nil;

    if (stmt == nil) {
        const char *s = "INSERT INTO Transactions VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);";
        stmt = [db prepare:s];
        [stmt retain];
    }
    [stmt bindInt:1 val:pkey]; // asset key
    [stmt bindInt:2 val:-1]; // dst asset
    [stmt bindDate:3 val:t.date];
    [stmt bindInt:4 val:t.type];
    [stmt bindInt:5 val:t.category];
    [stmt bindDouble:6 val:t.value];
    [stmt bindString:7 val:t.description];
    [stmt bindString:8 val:t.memo];
    [stmt step];
    [stmt reset];

    // get primary key
    t.pkey = [db lastInsertRowId];
}

- (void)replaceTransactionAtIndex:(int)index withObject:(Transaction*)t
{
    // copy key
    Transaction *old = [transactions objectAtIndex:index];
    t.pkey = old.pkey;

    [transactions replaceObjectAtIndex:index withObject:t];
    [self recalcBalance];

    // update DB
    [self updateTransaction:t];
}

- (void)updateTransaction:(Transaction *)t
{
    static DBStatement *stmt = nil;

    if (stmt == nil) {
        const char *s = "UPDATE Transactions SET date=?, type=?, category=?, value=?, description=?, memo=? WHERE key = ?;";
        stmt = [db prepare:s];
        [stmt retain];
    }
    [stmt bindDate:1 val:t.date];
    [stmt bindInt:2 val:t.type];
    [stmt bindInt:3 val:t.category];
    [stmt bindDouble:4 val:t.value];
    [stmt bindString:5 val:t.description];
    [stmt bindString:6 val:t.memo];
    [stmt bindInt:7 val:t.pkey];
    [stmt step];
    [stmt reset];
}


- (void)deleteTransactionAt:(int)n
{
    // update DB
    Transaction *t = [transactions objectAtIndex:n];

    static DBStatement *stmt = nil;
    if (stmt == nil) {
        const char *s = "DELETE FROM Transactions WHERE key = ?;";
        stmt = [db prepare:s];
        [stmt retain];
    }
    [stmt bindInt:1 val:t.pkey];
    [stmt step];
    [stmt reset];

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
    [db beginTransaction];
    while (transactions.count > 0) {
        Transaction *t = [transactions objectAtIndex:0];
        if ([t.date compare:date] != NSOrderedAscending) {
            break;
        }

        [self deleteTransactionAt:0];
    }
    [db commitTransaction];

#if 0
    sqlite3_snprintf(sizeof(sql), sql,
                     "DELETE FROM Transactions WHERE date < %Q AND asset = %d;",
                     [db cstringFromDate:date], asset);
    [db execSql:sql];
    [self reload];
#endif
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

    [db beginTransaction];

    bal = initialBalance;
    for (i = 0; i < max; i++) {
        double oldval;

        t = [self transactionAt:i];
        oldval = t.value;
        bal = [t fixBalance:bal isInitial:isInitial];

        if (t.value != oldval) {
            // 金額が変更された場合(残高照会取引)、DB を更新
            [self updateTransaction:t];
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

////////////////////////////////////////////////////////////////////////////
// Utility

#define MAX_LRU_SIZE 50

//
// 摘要のヒストリ(LRU)を取り出す
//  category 指定がある場合は、こちらを優先する
//
- (NSMutableArray *)descLRUWithCategory:(NSString *)category
{
    NSMutableArray *descAry = [[[NSMutableArray alloc] init] autorelease];

    if (category >= 0) {
        [self _setDescHistoryList:descAry withCategory:category];
    }
    [self _setDescHistoryList:descAry withCategory:-1];

    return descAry;
}

- (void)_setDescLRU:(NSMutableArray *)descAry withCategory:(int)category
{
    DBStatement *stmt;

    NSString *sql;
    if (category < 0) {
        // 全検索
        stmt = [db prepare:"SELECT description FROM Transactions ORDER BY date DESC;"];
    } else {
        // カテゴリ指定検索
        stmt = [db prepare:"SELECT description FROM Transactions ORDER BY date DESC"
                   " WHERE category = ?;"];
        [db bindInt:0 val:category];
    }

    // 摘要をリストに追加していく
    while ([stmt step] == SQLITE_ROW) {
        const char *cs = [stmt colCString:0];
        if (*cs == '\0') continue;
        NSString *s = [NSString stringWithCString:cs encoding:NSUTF8StringEncoding];
        if (s == nil) continue;

        // 重複チェック
        BOOL match = NO;
        NSString *ss;
        int i, max = [descAry count];
        for (i = 0; i < max; i++) {
            ss = [descAry objectAtIndex:i];
            if ([s isEqualToString:ss]) {
                match = YES;
                break;
            }
        }

        // 追加
        if (!match) {
            [descAry addObject:s];
            if ([descAry count] > MAX_LRU_SIZE) {
                break;
            }
        }
    }
}

// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (int)categoryWithDescription:(NSString *)desc
{
    DBStatement *stmt;
    int category = -1;

    stmt = [db prepare:"SELECT category FROM Transactions WHERE description = ? ORDER BY date DESCle;"];
    [db bindString:0 val:desc];

    if ([stmt step] == SQLITE_ROW) {
        category = [stmt colInt:0];
    }
    return category;
}

@end
