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

#import "Database.h"

@implementation Database

static char sql[4096];	// SQL buffer

- (void)init
{
	db = 0;

	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
}

- (void)dealloc
{
	if (db != nil) {
		sqlite3_close(db);
	}
}

- (void)execSql:(const char *)sql
{
	sqlite3_exec(db, sql, 0, 0);
}

// データベースを開く
//   データベースがあったときは YES を返す。
//   なかったときは新規作成して NO を返す
- (BOOL)openDB
{
	// Load from DB
	NSString *dbPath = [CashFlowAppDelegate pathOfDataFile:@"CashFlow.db"];
	if (sqlite3_open([dbPath UTF8String], &db) == 0) {
		return YES; // OK
	}

	// Ok, create new database
	sqlite3_open_v2([dbPath UTF8String], &db, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);

	// テーブル作成＆初期データ作成
	[self execSql:"CREATE TABLE Transactions ("
		  "key INTEGER PRIMARY KEY, asset INTEGER, date DATE, type INTEGER, category INTEGER,"
		  "value REAL, description TEXT, memo TEXT);"];

	[self execSql:"CREATE TABLE Assets (key INTEGER PRIMARY KEY, name TEXT, type INTEGER, initialBalance REAL, order INTEGER);"];

	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(1, %Q, 0, 0.0, 0);", 
					 [NSLocalizedString(@"Cash", @"") UTF8String]);
	[self execSql:sql];


	// 以下は将来使うため
	[self execSql:"CREATE TABLE Categories (key INTEGER PRIMARY KEY, name TEXT, order INTEGER);"];

	return NO; // re-created
}

- (void)beginTransactionDB
{
	[self execSql:"BEGIN;"];
}

- (void)commitTransactionDB
{
	[self execSql:"COMMIT;"];
}

///////////////////////////////////////////////////////////////////////////////
// Asset 処理

#if 0
- (NSMutableArray*)loadAssets
{
}

- (int)insertAsset:(Asset*)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(NULL, %Q, %d, 0.0, 9999);",
					 [name UTF8String], type);
	[self execSql:sql];

	return sqlite3_last_insert_rowid(db);
}

- (void)updateAsset:(Asset*)asset
{
	// TBD
}

- (void)deleteAsset:(Asset*)asset
{
	// TBD
}
#endif


- (double)loadInitialBalance:(int)asset
{
	/* get initial balance */
	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT initialBalance FROM Assets WHERE key = %d;", asset);
	sqlite3_prepare_v2(db, sql, strlen(sql), &stmt, NULL);
	double initialBalance = sqlite3_column_int(stmt, 0);

	return initialBalance;
}

- (void)saveInitialBalance:(double)initialBalance asset:(int)asset
{
	/* get initial balance */
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE initialBalance SET initialBalance=%d WHERE key = %d;",
					 initialBalance, asset);
	[self execSql:sql];
}

///////////////////////////////////////////////////////////////////////////////
// Transaction 処理

- (NSMutableArray *)loadTransactions:(int)asset
{
	sqlite3_stmt *stmt;

	/* get transactions */
	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT key, date, type, value, balance, description, memo"
					 " FROM Transactions ORDER BY date WHERE asset = %d;", 
					 asset);
	sqlite3_prepare_v2(db, sql, strlen(sql), &stmt, NULL);

	NSMutableArray *transactions = [[NSMutableArray alloc] init];

	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Transaction *t = [[Transaction alloc] init];
		t.serial = sqlite3_column_int(stmt, 0);
		char *date = sqlite3_column_text(stmt, 1);
		t.type = sqlite3_column_int(stmt, 2);
		t.value = sqlite3_column_double(stmt, 3);
		t.balance = sqlite3_column_double(stmt, 4);
		char *desc = sqlite3_column_text(stmt, 5);
		char *memo = sqlite3_column_text(stmt, 6);

		t.date = [dateFormatter dateFromString:
						[NSString stringWithCString:date encoding:NSUTF8StringEncoding]];
		t.description = [NSString stringWithCString:desc encoding:NSUTF8StringEncoding];
		t.memo = [NSString stringWithCString:memo encoding:NSUTF8StringEncoding];

		[transactions insertObject:t];
		[t release];
	}
	sqlite3_finalize(stmt);

	return transactions;
}

- (void)saveTransactions:(Transactions*)transactions asset:(int)asset
{
	[self beginTransactionDB];

	// delete all transactions
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE * FROM Transactions WHERE asset = %d;", asset);
	[self execSql:sql];

	// write all transactions
	int n = [transactions count];
	int i;

	for (i = 0; i < n; i++) {
		Transaction *t = [transactions objectAtIndex:i];
		[self insertTransaction:t asset:asset];
	}

	[self commitTransactionDB];
}

- (void)insertTransaction:(Transaction*)t asset:(int)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Transactions VALUES(NULL, %d, %Q, %d, %d, %f, %Q, %Q);",
					 asset,
					 [[dateFormatter stringFromDate:t.date] UTF8String],
					 t.type,
					 0, /* category */
					 t.value,
					 [t.description UTF8String],
					 [t.memo UTF8String]);
	[self execSql:sql];

	// get primary key
	t.serial = sqlite3_last_insert_rowid(db);
}

- (void)updateTransaction:(Transaction *)t
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Transactions SET date=%Q, type=%d, category=%d, value=%f, description=%Q, memo=%Q WHERE key = %d;",
					 [[dateFormatter stringFromDate:t.date] UTF8String],
					 t.type,
					 0, /* category */
					 t.value,
					 [t.description UTF8String],
					 [t.memo UTF8String],
					 t.serial);
	[self execSql:sql];
}

- (void)deleteTransaction:(Transaction *)t
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE key = %d;", 
					 t.serial);
	[self execSql:sql];
}

- (void)deleteOldTransactionsBefore:(NSDate*)date asset:(int)asset
{
	// TBD : date は比較不能(?)

	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE date < %Q AND asset = %d;",
					 [[dateFormatter stringFromDate:t.date] UTF8String], asset);
	[self execSql:sql];
}

- (void)beginTransaction
{
	[self execSql:"BEGIN;"];
}

- (void)commitTransaction
{
	[self execSql:"COMMIT;"];
}

@end

