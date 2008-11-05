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

// SQLite データベース版
// まだ試作中、、、

#import "DataModel2.h"
#import <sqlite3.h>

@implementation DataModel2

@synthesize db;

// Factory : override
+ (DataModel*)allocWithLoad
{
	DataModel2 *dm = [[DataModel2 alloc] init];

	// Load from DB
	Database *db = [[Database alloc] init];
	dm.db = db;
	[db release];

	if ([dm.db openDB]) {
		[dm reload];
		return dm;
	}

	// Backward compatibility
	DataModel *odm = [DataModel allocWithLoad];
	if ([dm getTransactionCount] > 0) {
		// TBD
		dm.transactions = odm.transactions;
		dm.initialBalance = odm.initialBalance;
	}
	[odm release];

	// Ok, write database
	[dm save];

	return dm;
}

// private
- (void)reload
{
	if (transactions) {
		[transactions release];
	}
	self.transactions = [db loadTransactions:asset];
	self.initialBalance = [db loadInitialBalance:asset];
}

// private
- (void)save
{
	[db saveTransactions:transactions asset:asset];
	[db saveInitialBalance:initialBalance asset:asset];
}

- (BOOL)saveToStorage
{
	// do nothing
	return YES;
}

- (id)init
{
	[super init];

	db = nil;
	asset = 1; // とりあえず cash に固定

	return self;
}

- (void)dealloc 
{
	[db release];

	[super dealloc];
}

- (void)insertTransaction:(Transaction*)tr
{
	[super insertTransaction:tr];

	// DB 追加
	[db insertTransactionDB:tr];
}

- (void)replaceTransactionAtIndex:(int)index withObject:(Transaction*)t
{
	[super replaceTransactionAtIndex:index withObject:t];

	// update DB
	[db updateTransaction:t];
}

- (void)deleteTransactionAt:(int)n
{
	Transaction *t = [transactions objectAtIndex:n];
	[db deleteTransaction:t];

	[super deleteTransactionAt:n];
}

- (void)deleteOldTransactionsBefore:(NSDate*)date
{
	// override
	[db deleteOldTransactionsBefore:date];
	[self reload];
}

// sort
- (void)sortByDate
{
	[super sortByDate];
	// rewrite???
}

- (void)recalcBalance
{
	// override
	Transaction *t;
	double bal;
	int max = [transactions count];
	int i;

	if (max == 0) return;

	bal = initialBalance;

	[db beginTransaction];

	// Recalculate balances
	for (i = 0; i < max; i++) {
		t = [transactions objectAtIndex:i];
		bal = [t fixBalance:bal];
		[db updateTransaction:t];
	}

	[db commitTransaction];
}

@end
