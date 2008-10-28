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
	[self execSql:"CREATE TABLE Transactions ("
		  "key INTEGER PRIMARY KEY, asset INTEGER, date DATE, type INTEGER,"
		  "value REAL, balance REAL, description TEXT, memo TEXT);"];

	// 以下は将来使うため
	[self execSql:"CREATE TABLE Assets (key INTEGER PRIMARY KEY, name TEXT, type INTEGER);"];
	[self execSql:"INSERT INTO Assets VALUES(0, 'Cash', 0);"];

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

- (NSMutableArray *)loadFromDB:(int)asset
{
	char sql[128];

	sqlite3_snprintf(sizeof(sql), sql,
					 "SELECT key, date, type, value, balance, description, memo"
					 " FROM Transactions ORDER BY date WHERE asset = %d;", 
					 asset);
		
	sqlite3_stmt *stmt;
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

- (void)saveToDB:(Transactions*)transactions asset:(int)asset
{
	[self beginTransactionDB];

	char sql[128];
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE * FROM Transactions WHERE asset = %d;", asset);
	[self execSql:sql];

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
	char sql[1024];

	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO \"Transactions\" VALUES(NULL, %d, %Q, %d, %f, %f, %Q, %Q);",
					 asset,
					 [[dateFormatter stringFromDate:t.date] UTF8String],
					 t.type,
					 t.value,
					 t.balance,
					 [t.description UTF8String],
					 [t.memo UTF8String]);
	[self execSql:sql];

	// get primary key
	t.serial = sqlite3_last_insert_rowid(db);
}

- (void)updateTransaction:(Transaction *)t
{
	char sql[1024];

	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE \"Transactions\" SET date=%Q, type=%d, value=%f, balance=%f, description=%Q, memo=%Q WHERE key = %d;",
					 [[dateFormatter stringFromDate:t.date] UTF8String],
					 t.type,
					 t.value,
					 t.balance,
					 [t.description UTF8String],
					 [t.memo UTF8String],
					 t.serial);
	[self execSql:sql];
}

- (void)deleteTransaction:(Transaction *)t
{
	char sql[128];
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE * FROM \"Transactions\" WHERE key = %d;", 
					 t.serial);
	[self execSql:sql];
}

- (void)deleteOldTransactionsBefore:(NSDate*)date
{
	char sql[1024];
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE * FROM Transactions WHERE date < %Q",
					 [[dateFormatter stringFromDate:t.date] UTF8String]);
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

