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

    DBStatement *stmt;
    stmt = [db prepare:"SELECT * FROM Categories ORDER BY sorder;"];
    while ([stmt step] == SQLITE_ROW) {
        Category *c = [[Category alloc] init];
        c.pkey = [stmt colInt:0];
        c.name = [stmt colString:1];
        c.sorder = [stmt colInt:2];
		
        [categories addObject:c];
        [c release];
    }
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

    DBStatement *stmt;
    stmt = [db prepare:"INSERT INTO Categories VALUES(NULL, ?, ?);"];
    [stmt bindString:1 val:c.name];
    [stmt bindInt:2 val:c.sorder];
    [stmt step];

    c.pkey = [db lastInsertRowId];

    return c;
}

-(void)updateCategory:(Category*)category
{
    DBStatement *stmt;
    stmt = [db prepare:"UPDATE Categories SET name=?, sorder=? WHERE key=?;"];
    [stmt bindString:1 val:category.name];
    [stmt bindInt:2 val:category.sorder];
    [stmt bindInt:3 val:category.pkey];
    [stmt step];
}

-(void)deleteCategoryAtIndex:(int)index
{
    Category *c = [categories objectAtIndex:index];

    DBStatement *stmt;
    stmt = [db prepare:"DELETE FROM Categories WHERE key=?;"];
    [stmt bindInt:1 val:c.pkey];
    [stmt step];

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
        [self updateCategory:c];
    }
    [db commitTransaction];
}

@end
