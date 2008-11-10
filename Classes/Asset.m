// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
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

static char sql[4096];

- (id)init
{
	[super init];

	pkey = 1; // とりあえず

	initialBalance = 0.0;
	transactions = [[NSMutableArray alloc] init];
	type = ASSET_CASH;
	
	return self;
}

- (void)dealloc 
{
	[db release];
	if (transactions != nil) {
		[transactions release];
	}

	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////
// Load / Save DB

- (void)loadOldFormatData
{
	// Backward compatibility : try to load old format data
	DataModelV1 *dm1 = [DataModelV1 allocWithLoad];
	if (dm1 != nil) {
		initialBalance = dm1.initialBalance;
		transactions = dm1.transactions;
		[transactions retain];

		[dm1 release];
	}

	// Ok, write back database
	[self resave];
	[self recalcBalanceInitial];
}

- (void)reload
{
	sqlite3_stmt *stmt;

	[self clear];

	/* load transactions */
	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT key, date, type, category, value, description, memo"
					 " FROM Transactions WHERE asset = %d ORDER BY date;", 
					 pkey);
	sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

	transactions = [[NSMutableArray alloc] init];

	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Transaction *t = [[Transaction alloc] init];
		t.pkey = sqlite3_column_int(stmt, 0);
		const char *date = (const char*)sqlite3_column_text(stmt, 1);
		t.type = sqlite3_column_int(stmt, 2);
		t.category = sqlite3_column_int(stmt, 3);
		t.value = sqlite3_column_double(stmt, 4);
		const char *desc = (const char*)sqlite3_column_text(stmt, 5);
		const char *memo = (const char*)sqlite3_column_text(stmt, 6);

		t.date = [db dateFromCString:date];
		if (t.date == nil) {
			// fail safe
			[t release];
			continue;
		}
		if (desc) {
			t.description = [NSString stringWithCString:desc encoding:NSUTF8StringEncoding];
		}
		if (memo) {
			t.memo = [NSString stringWithCString:memo encoding:NSUTF8StringEncoding];
		}

		[transactions addObject:t];
		[t release];
	}
	sqlite3_finalize(stmt);

	// recalc balance
	[self recalcBalanceInitial];
}

- (void)resave
{
	[self updateInitialBalance];

	[db beginTransaction];

	// delete all transactions
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE asset = %d;", asset);
	[db execSql:sql];

	// write all transactions
	int n = [transactions count];
	int i;
	for (i = 0; i < n; i++) {
		Transaction *t = [transactions objectAtIndex:i];
		[self insertTransactionDb:t];
	}

	[db commitTransaction];
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
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Assets SET initialBalance=%f WHERE key=%d;",
					 initialBalance, pkey);
	[db execSql:sql];
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
	static sqlite3_stmt *stmt = NULL;

	if (stmt == NULL) {
		const char *s = "INSERT INTO Transactions VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);";
		sqlite3_prepare_v2(db.db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_int(stmt, 1, pkey/*asset key*/);
	sqlite3_bind_int(stmt, 2, -1 /*dst asset*/);
	sqlite3_bind_text(stmt, 3, [db cstringFromDate:t.date], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 4, t.type);
	sqlite3_bind_int(stmt, 5, t.category);
	sqlite3_bind_double(stmt, 6, t.value);
	sqlite3_bind_text(stmt, 7, [t.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 8, [t.memo UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);

	// get primary key
	t.pkey = sqlite3_last_insert_rowid(db.db);
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
	static sqlite3_stmt *stmt = NULL;

	if (stmt == NULL) {
		const char *s = "UPDATE Transactions SET date=?, type=?, category=?, value=?, description=?, memo=? WHERE key = ?;";
		sqlite3_prepare_v2(db.db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_text(stmt, 1, [db cstringFromDate:t.date], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 2, t.type);
	sqlite3_bind_int(stmt, 3, t.category);
	sqlite3_bind_double(stmt, 4, t.value);
	sqlite3_bind_text(stmt, 5, [t.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 6, [t.memo UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 7, t.pkey);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);
}


- (void)deleteTransactionAt:(int)n
{
	// update DB
	Transaction *t = [transactions objectAtIndex:n];

	static sqlite3_stmt *stmt = NULL;
	if (stmt == NULL) {
		const char *s = "DELETE FROM Transactions WHERE key = ?;";
		sqlite3_prepare_v2(db.db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_int(stmt, 1, t.pkey);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);

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

- (NSMutableArray *)allocDescList
{
	int i, max;
	max = [transactions count];
	
	NSMutableArray *ary = [[NSMutableArray alloc] init];
	if (max == 0) return ary;

#if 0	
	// Sort type
	for (i = max - 1; i >= 0; i--) {
		[ary addObject:[[transactions objectAtIndex:i] description]];
	}
	
	[ary sortUsingSelector:@selector(compare:)];
	
	// uniq
	NSString *prev = [ary objectAtIndex:0];
	for (i = 1; i < [ary count]; i++) {
		if ([prev isEqualToString:[ary objectAtIndex:i]]) {
			[ary removeObjectAtIndex:i];
			i--;
		} else {
			prev = [ary objectAtIndex:i];
		}
	}
#else

	// LRU type
#define MAX_LRU_SIZE 50

	for (i = max - 1; i >= 0; i--) {
		NSString *s = [[transactions objectAtIndex:i] description];
		
		int j;
		BOOL match = NO;
		for (j = 0; j < [ary count]; j++) {
			if ([s isEqualToString:[ary objectAtIndex:j]]) {
				match = YES;
				break;
			}
		}
		if (!match) {
			[ary addObject:s];
			if ([ary count] > MAX_LRU_SIZE) {
				break;
			}
		}
	}
#endif

	return ary;
}

@end
