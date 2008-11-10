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

#import "Category.h"
#import "AppDelegate.h"

@implementation Category
@synthesize pkey, name, sorder;
@end

@implementation Categories

@synthesize db;

-(id)init
{
	[super init];
	categories = nil;

	return self;
}

-(void)dealloc
{
	if (categories != nil) {
		[categories release];
	}
	[super dealloc];
}

-(void)reload
{
	ASSERT(db != nil);
	if (categories != nil) {
		[categories release];
	}
	categories = [[NSMutableArray alloc] init];

	sqlite3_stmt *stmt;
	sqlite3_prepare_v2(db.db, "SELECT * FROM Categories ORDER BY sorder;", -1, &stmt, NULL);
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		Category *c = [[Category alloc] init];
		c.pkey = sqlite3_column_int(stmt, 0);
		const char *name = (const char *)sqlite3_column_text(stmt, 1);
		c.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		c.sorder = sqlite3_column_int(stmt, 2);
		
		[categories addObject:c];
		[c release];
	}
	sqlite3_finalize(stmt);
}

-(int)categoryCount
{
	return [categories count];
}

-(Category*)categoryAtIndex:(int)n
{
	ASSERT(categories != nil);
	return [categories objectAtIndex:n];
}

- (int)categoryIndexWithKey:(int)key
{
	Category *c = [self categoryWithKey:key];
	int i, max = [categories count];
	for (i = 0; i < max; i++) {
		Category *c = [categories objectAtIndex:i];
		if (c.pkey == key) {
			return i;
		}
	}
	return -1;
}

-(NSString*)categoryStringWithKey:(int)key
{
	int idx = [self categoryIndexWithKey:key];
	if (idx < 0) {
		return @"";
	}
	Category *c = [categories objectAtIndex:idx];
	return c.name;
}

-(Category*)addCategory:(NSString *)name
{
	Category *c = [[Category alloc] init];
	c.name = name;
	[categories addObject:c];
	[c release];

	[self renumber];

	char sql[1024];
	sqlite3_snprintf(sizeof(sql), sql,
					 "INSERT INTO Categories VALUES(NULL, %Q, %d);",
					 [c.name UTF8String], c.sorder);
	[db execSql:sql];

	c.pkey = sqlite3_last_insert_rowid(db.db);

	return c;
}

-(void)updateCategory:(Category*)category
{
	char sql[1024];
	sqlite3_snprintf(sizeof(sql), sql,
					 "UPDATE Categories SET name=%Q, sorder=%d WHERE key=%d;",
					 [category.name UTF8String], category.sorder, category.pkey);
	[db execSql:sql];
}

-(void)deleteCategoryAtIndex:(int)index
{
	Category *c = [categories objectAtIndex:index];

	char sql[1024];
	sqlite3_snprintf(sizeof(sql), sql,
					 "DELETE FROM Categories WHERE key=%d;",
					 c.pkey);
	[db execSql:sql];

	[categories removeObjectAtIndex:index];
}

- (void)reorderCategory:(int)from to:(int)to
{
	Category *c = [[categories objectAtIndex:from] retain];
	[categories removeObjectAtIndex:from];
	[categories insertObject:c atIndex:to];
	[c release];
	
	[self renumber];
}

-(void)renumber
{
	int i, max = [categories count];

	[db beginTransaction];
	for (i = 0; i < max; i++) {
		Category *c = [categories objectAtIndex:i];
		c.sorder = i;
		[db updateCategory:c];
	}
	[db commitTransaction];
}

@end
