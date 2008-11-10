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

#import "DataModel.h"

@implementation DataModel

@synthesize db, assets, selAsset, categories;

- (id)init
{
	[super init];

	db = nil;

	assets = [[NSMutableArray alloc] init];
	selAsset = nil;

	categories = [[Categories alloc] init];
	
	return self;
}

- (void)dealloc 
{
	[db release];
	[assets release];
	[categories release];

	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////
// Load / Save DB

- (void)load
{
	// Load from DB
	db = [[Database alloc] init];

	BOOL needLoadOldData = NO;
	if (![db openDB]) {
		[db initializeDB];
		needLoadOldData = YES;
	}
	
	// Load assets
	[self loadAssets];
	if ([assets count] > 0) {
		selAsset = [assets objectAtIndex:0];

		if (needLoadOldData) {
			[selAsset loadOldFormatData];
		} else {
			[selAsset reload];
		}
	}

	// Load categories
	categories.db = db;
	[categories reload];
}

// private
- (NSMutableArray*)loadAssets
{
	sqlite3_stmt *stmt;
	assets = [[NSMutableArray alloc] init];

	stmt = [db prepare:"SELECT * FROM Assets ORDER BY sorder;"];
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Asset *as = [[Asset alloc] init];
		as.pkey = sqlite3_column_int(stmt, 0);
		const char *name = (const char *)sqlite3_column_text(stmt, 1);
		as.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		as.type = sqlite3_column_int(stmt, 2);
		as.initialBalance = sqlite3_column_double(stmt, 3);
		as.sorder = sqlite3_column_int(stmt, 4);

		as.db = db; // back pointer
		
		[assets addObject:as];
		[as release];
	}
}

// private
- (void)reload
{
	[selAsset reload];
}

// private
- (void)resave
{
	[selAsset resave];
}

////////////////////////////////////////////////////////////////////////////
// Asset operation

- (int)assetCount
{
	return [assets count];
}

- (Asset*)assetAtIndex:(int)n
{
	return [assets objectAtIndex:n];
}

- (void)addAsset:(Asset *)as
{
	[assets addObject:as];

	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Assets VALUES(NULL, %Q, %d, %f, %d);",
					 [as.name UTF8String], as.type, as.initialBalance, as.sorder);
	[db execSql:sql];

	as.pkey = sqlite3_last_insert_rowid(db.handle);
}

- (void)deleteAsset:(Asset *)as
{
	if (selAsset == as) {
		selAsset = nil;
	}
	[as clear];
	
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Assets WHERE key=%d;",
					 asset.pkey);
	[db execSql:sql];

	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Transactions WHERE asset=%d;",
					 asset.pkey);
	[db execSql:sql];

	[assets removeObject:as];
}

- (void)reorderAsset:(int)from to:(int)to
{
	Asset *as = [[assets objectAtIndex:from] retain];
	[assets removeObjectAtIndex:from];
	[assets insertObject:as atIndex:to];
	[as release];
	
	// renumbering sorder
	[db beginTransaction];
	for (int i = 0; i < [assets count]; i++) {
		as = [assets objectAtIndex:i];
		as.sorder = i;

		sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Assets SET name=%Q, type=%d, initialBalance=%f, sorder=%d WHERE key=%d;",
					 [as.name UTF8String], as.type, as.initialBalance, as.sorder,
					 as.pkey);
		[db execSql:sql];
	}
	[db endTransaction];
}


- (void)changeSelAsset:(Asset *)as
{
	if (selAsset != as) {
		if (selAsset != nil) {
			[selAsset clear];
		}
		selAsset = as;
		[selAsset reload];
	}
}

////////////////////////////////////////////////////////////////////////////
// Utility

static NSNumberFormatter *currencyFormatter = nil;

+ (NSString*)currencyString:(double)x
{
	if (currencyFormatter == nil) {
		currencyFormatter = [[NSNumberFormatter alloc] init];
		[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[currencyFormatter setLocale:[NSLocale currentLocale]];
	}
	NSNumber *n = [NSNumber numberWithDouble:x];
	NSString *bstr = [currencyFormatter stringFromNumber:n];

	return bstr;
}

@end
