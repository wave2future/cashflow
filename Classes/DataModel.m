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

// DataModel V2
// (SQLite ver)

#import <sqlite3.h>
#import "DataModel.h"

@implementation DataModel

@synthesize db, transactions, initialBalance, maxTransactions;

- (id)init
{
	[super init];

	db = nil;
	asset = 1; // とりあえず cash に固定
	maxTransactions = MAX_TRANSACTIONS;

	initialBalance = 0.0;
	transactions = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc 
{
	[db release];
	[transactions release];

	[super dealloc];
}

- (void)loadDB
{
	// Load from DB
	self.db = [[Database alloc] init];
	[db release];

	if ([db openDB]) {
		[self reload];
		return; // OK
	}

	// Backward compatibility
	DataModel1 *dm1 = [DataModel1 allocWithLoad];
	if ([dm1 transactionCount] > 0) {
		// TBD
		self.transactions = dm1.transactions;
		self.initialBalance = dm1.initialBalance;
	}
	[dm1 release];

	// Ok, write back database
	[self save];
	
	[self recalcBalanceInitial];
	
	return dm;
}

// private
- (void)reload
{
	initialBalance = [db loadInitialBalance:asset]; // self.initialBalance にはしない(DB上書きするので）
	self.transactions = [db loadTransactions:asset];
	
	[self recalcBalanceInitial];
}

// private
- (void)save
{
	[db saveTransactions:transactions asset:asset];
	[db saveInitialBalance:initialBalance asset:asset];
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
	if ([transactions count] > maxTransactions) {
		[self deleteTransactionAt:0];
	}

	// DB 追加
	[db insertTransaction:tr asset:asset];
}

- (void)replaceTransactionAtIndex:(int)index withObject:(Transaction*)t
{
	// copy serial
	Transaction *old = [transactions objectAtIndex:index];
	t.serial = old.serial;

	[transactions replaceObjectAtIndex:index withObject:t];
	[self recalcBalance];

	// update DB
	[db updateTransaction:t];
}

- (void)deleteTransactionAt:(int)n
{
	// update DB
	Transaction *t = [transactions objectAtIndex:n];
	[db deleteTransaction:t];

	// special handling for first transaction
	if (n == 0) {
		Transaction *t = [transactions objectAtIndex:0];
		self.initialBalance = t.balance;  // update DB
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

	//[db deleteOldTransactionsBefore:date asset:asset];
	//[self reload];
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
	[super recalcBalanceSub:isInitial];

	if (!isInitial) {
		// 残高照会取引は金額がかわっている可能性があるため、DBを更新する
		Transaction *t;
		int i, max = [transactions count];
	
		[db beginTransaction];
		for (i = 0; i < max; i++) {
			t = [transactions objectAtIndex:i];
			if (t.type == TYPE_ADJ) {
				[db updateTransaction:t];
			}
		}
		[db commitTransaction];
	}
}

- (double)lastBalance
{
	int max = [transactions count];
	if (max == 0) {
		return initialBalance;
	}
	return [[transactions objectAtIndex:max - 1] balance];
}

// override initialBalance property
- (void)setInitialBalance:(double)v
{
	[super setInitialBalance:v];
	[db saveInitialBalance:v asset:asset];
}

////////////////////////////////////////////////////////////////////////////
// Utility
+ (NSString*)currencyString:(double)x
{
	NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
	[f setNumberStyle:NSNumberFormatterCurrencyStyle];
	[f setLocale:[NSLocale currentLocale]];
	NSString *bstr = [f stringFromNumber:[NSNumber numberWithDouble:x]];
	return bstr;
}

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
