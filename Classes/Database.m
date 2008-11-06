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
#import "AppDelegate.h"

@implementation Database

static char sql[4096];	// SQL buffer

- (id)init
{
	self = [super init];
	if (self != nil) {
		db = 0;

		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateFormat: @"yyyyMMddHHmm"];
	}
	
	return self;
}

- (void)dealloc
{
	if (db != nil) {
		sqlite3_close(db);
	}
	[super dealloc];
}

- (void)execSql:(const char *)sql
{
	int result = sqlite3_exec(db, sql, NULL, NULL, NULL);
	if (result != SQLITE_OK) {
		NSLog(@"sqlite3: %s", sqlite3_errmsg(db));
	}
}

// データベースを開く
//   データベースがあったときは YES を返す。
//   なかったときは新規作成して NO を返す
- (BOOL)openDB
{
	// Load from DB
	NSString *dbPath = [AppDelegate pathOfDataFile:@"CashFlow.db"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isExistedDb = [fileManager fileExistsAtPath:dbPath];
	
	if (sqlite3_open([dbPath UTF8String], &db) != 0) {
		// ouch!
	}
	return isExistedDb;
}

- (void)initializeDB
{
	// テーブル作成＆初期データ作成
	[self execSql:"CREATE TABLE Transactions ("
		  "key INTEGER PRIMARY KEY, asset INTEGER, date DATE, type INTEGER, category INTEGER,"
		  "value REAL, description TEXT, memo TEXT);"];

	[self execSql:"CREATE TABLE Assets (key INTEGER PRIMARY KEY, name TEXT, type INTEGER, initialBalance REAL, sorder INTEGER);"];

	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(1, %Q, 0, 0.0, 0);", 
					 [NSLocalizedString(@"Cash", @"") UTF8String]);
	[self execSql:sql];

	// 以下は将来使うため
	[self execSql:"CREATE TABLE Categories (key INTEGER PRIMARY KEY, name TEXT, sorder INTEGER);"];
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

- (NSMutableArray*)loadAssets
{
	sqlite3_stmt *stmt;
	NSMutableArray *assets = [[NSMutableArray alloc] init];

	sqlite3_prepare_v2(db, "SELECT * FROM Assets ORDER BY sorder;", -1, &stmt, NULL);
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Asset *as = [[Asset alloc] init];
		as.pkey = sqlite3_column_int(stmt, 0);
		const char *name = (const char *)sqlite3_column_text(stmt, 1);
		as.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		as.type = sqlite3_column_int(stmt, 2);
		as.initialBalance = sqlite3_column_double(stmt, 3);
		as.sorder = sqlite3_column_int(stmt, 4);

		as.db = self; // back pointer
		
		[assets addObject:as];
		[as release];
	}
	
	return assets;
}

- (void)insertAsset:(Asset*)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(NULL, %Q, %d, %f, %d);",
					 [asset.name UTF8String], asset.type, asset.initialBalance, asset.sorder);
	[self execSql:sql];

	asset.pkey = sqlite3_last_insert_rowid(db);
}

- (void)updateAsset:(Asset*)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Assets SET name=%Q type=%d initialBalance=%f sorder=%d WHERE key=%d;",
					 [asset.name UTF8String], asset.type, asset.initialBalance, asset.sorder,
					 asset.pkey);
	[self execSql:sql];
}

- (void)updateInitialBalance:(Asset*)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Assets SET initialBalance=%f WHERE key=%d;",
					 asset.initialBalance, asset.pkey);
	[self execSql:sql];
}

- (void)deleteAsset:(Asset*)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE Assets WHERE key=%d;",
					 asset.pkey);
	[self execSql:sql];
}

#if 0
- (double)loadInitialBalance:(int)asset
{
	sqlite3_stmt *stmt;
	
	/* get initial balance */
	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT initialBalance FROM Assets WHERE key = %d;", asset);
	sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
	sqlite3_step(stmt);
	double initialBalance = sqlite3_column_double(stmt, 0);
	sqlite3_finalize(stmt);

	return initialBalance;
}

- (void)saveInitialBalance:(double)initialBalance asset:(int)asset
{
	/* get initial balance */
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Assets SET initialBalance=%f WHERE key=%d;", initialBalance, asset);
	[self execSql:sql];
}
#endif

///////////////////////////////////////////////////////////////////////////////
// Transaction 処理

- (NSMutableArray *)loadTransactions:(int)asset
{
	sqlite3_stmt *stmt;

	/* get transactions */
	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT key, date, type, value, description, memo"
					 " FROM Transactions WHERE asset = %d ORDER BY date;", 
					 asset);
	sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

	NSMutableArray *transactions = [[NSMutableArray alloc] init];

	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Transaction *t = [[Transaction alloc] init];
		t.pkey = sqlite3_column_int(stmt, 0);
		const char *date = (const char*)sqlite3_column_text(stmt, 1);
		t.type = sqlite3_column_int(stmt, 2);
		t.value = sqlite3_column_double(stmt, 3);
		const char *desc = (const char*)sqlite3_column_text(stmt, 4);
		const char *memo = (const char*)sqlite3_column_text(stmt, 5);

		t.date = [dateFormatter dateFromString:
						[NSString stringWithCString:date encoding:NSUTF8StringEncoding]];
		if (t.date == nil) {
			// fail safe
			[t release];
			continue;
		}
		t.description = [NSString stringWithCString:desc encoding:NSUTF8StringEncoding];
		t.memo = [NSString stringWithCString:memo encoding:NSUTF8StringEncoding];

		[transactions addObject:t];
		[t release];
	}
	sqlite3_finalize(stmt);

	return transactions;
}

- (void)saveTransactions:(NSMutableArray*)transactions asset:(int)asset
{
	[self beginTransactionDB];

	// delete all transactions
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE asset = %d;", asset);
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
	static sqlite3_stmt *stmt = NULL;

	if (stmt == NULL) {
		const char *s = "INSERT INTO Transactions VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);";
		sqlite3_prepare_v2(db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_int(stmt, 1, asset);
	sqlite3_bind_text(stmt, 2, [[dateFormatter stringFromDate:t.date] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 3, t.type);
	sqlite3_bind_int(stmt, 4, 0); // category
	sqlite3_bind_double(stmt, 5, t.value);
	sqlite3_bind_text(stmt, 6, [t.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 7, [t.memo UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);

	// get primary key
	t.pkey = sqlite3_last_insert_rowid(db);
}

- (void)updateTransaction:(Transaction *)t
{
	static sqlite3_stmt *stmt = NULL;

	if (stmt == NULL) {
		const char *s = "UPDATE Transactions SET date=?, type=?, category=?, value=?, description=?, memo=? WHERE key = ?;";
		sqlite3_prepare_v2(db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_text(stmt, 1, [[dateFormatter stringFromDate:t.date] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 2, t.type);
	sqlite3_bind_int(stmt, 3, 0); // category
	sqlite3_bind_double(stmt, 4, t.value);
	sqlite3_bind_text(stmt, 5, [t.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 6, [t.memo UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 7, t.pkey);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);
}

- (void)deleteTransaction:(Transaction *)t
{
	static sqlite3_stmt *stmt = NULL;
	if (stmt == NULL) {
		const char *s = "DELETE FROM Transactions WHERE key = ?;";
		sqlite3_prepare_v2(db, s, -1, &stmt, NULL);
	}
	sqlite3_bind_int(stmt, 1, t.pkey);
	sqlite3_step(stmt);
	sqlite3_reset(stmt);
}

- (void)deleteOldTransactionsBefore:(NSDate*)date asset:(int)asset
{
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE date < %Q AND asset = %d;",
					 [[dateFormatter stringFromDate:date] UTF8String], asset);
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

