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

#import "Database.h"
#import "AppDelegate.h"

@implementation Database

@synthesize handle;

- (id)init
{
	self = [super init];
	if (self != nil) {
		handle = 0;

		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateFormat: @"yyyyMMddHHmm"];
	}
	
	return self;
}

- (void)dealloc
{
	if (handle != nil) {
		sqlite3_close(handle);
	}
	[dateFormatter release];
	[super dealloc];
}

- (void)execSql:(const char *)sql
{
	ASSERT(handle != 0);
	
	int result = sqlite3_exec(handle, sql, NULL, NULL, NULL);
	if (result != SQLITE_OK) {
		NSLog(@"sqlite3: %s", sqlite3_errmsg(handle));
		ASSERT(0);
	}
}

- (void)beginTransaction
{
	[self execSql:"BEGIN;"];
}

- (void)commitTransaction
{
	[self execSql:"COMMIT;"];
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
	
	if (sqlite3_open([dbPath UTF8String], &handle) != 0) {
		// ouch!
		ASSERT(0);
	}
	return isExistedDb;
}

- (void)initializeDB
{
	// テーブル作成＆初期データ作成
	[self execSql:"CREATE TABLE Transactions ("
		  "key INTEGER PRIMARY KEY,"
		  "asset INTEGER,"
		  "dst_asset INTEGER,"
		  "date DATE,"
		  "type INTEGER,"
		  "category INTEGER,"
		  "value REAL,"
		  "description TEXT,"
		  "memo TEXT);"];

	[self execSql:"CREATE TABLE Assets ("
		  "key INTEGER PRIMARY KEY,"
		  "name TEXT,"
		  "type INTEGER,"
		  "initialBalance REAL,"
		  "sorder INTEGER);"];

	char sql[256];
	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(1, %Q, 0, 0.0, 0);", 
					 [NSLocalizedString(@"Cash", @"") UTF8String]);
	[self execSql:sql];

	// カテゴリテーブル追加
	[self execSql:"CREATE TABLE Categories ("
		  "key INTEGER PRIMARY KEY,"
		  "name TEXT,"
		  "order INTEGER);"];
}

//////////////////////////////////////////////////////////////////////////////////
// Utility

- (NSDate*)dateFromCString:(const char *)str
{
	NSDate *date = [dateFormatter dateFromString:
		   [NSString stringWithCString:str encoding:NSUTF8StringEncoding]];
	return date;
}

- (const char *)cstringFromDate:(NSDate*)date
{
	const char *s = [[dateFormatter stringFromDate:date] UTF8String];
	return s;
}

@end

