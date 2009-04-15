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

// DataModel V2
// (SQLite ver)

#import "DataModel.h"

@implementation DataModel

@synthesize assets, selAsset, categories;

- (id)init
{
    [super init];

    assets = [[NSMutableArray alloc] init];
    selAsset = nil;

    categories = [[Categories alloc] init];
	
    return self;
}

- (void)dealloc 
{
    [assets release];
    [categories release];

    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////
// Load / Save DB

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
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
        }
    }

    // Load all transactions
    [self reloadAssets];

    // Load categories
    [categories reload];
}

// private
- (void)loadAssets
{
    DBStatement *stmt;
    assets = [[NSMutableArray alloc] init];

    stmt = [[Database instance] prepare:"SELECT * FROM Assets ORDER BY sorder;"];
    while ([stmt step] == SQLITE_ROW) {
        Asset *as = [[Asset alloc] init];
        as.pkey = [stmt colInt:0];
        as.name = [stmt colString:1];
        as.type = [stmt colInt:2];
        as.initialBalance = [stmt colDouble:3];
        as.sorder = [stmt colInt:4];

        [assets addObject:as];
        [as release];
    }
}

////////////////////////////////////////////////////////////////////////////
// Asset operation

- (void)reloadAssets
{
    for (Asset *as in assets) {
        [as reload];
    }
}

- (void)dirtyAllAssets
{
    for (Asset *as in assets) {
        [as setDirty];
    }
}

- (int)assetCount
{
    return [assets count];
}

- (Asset*)assetAtIndex:(int)n
{
    return [assets objectAtIndex:n];
}

- (Asset*)assetWithKey:(int)pkey
{
    for (Asset *as in assets) {
        if (as.pkey == pkey) return as;
    }
    return nil;
}

- (int)assetIndexWithKey:(int)pkey
{
    int i;
    for (i = 0; i < [assets count]; i++) {
        Asset *as = [assets objectAtIndex:i];
        if (as.pkey == pkey) return i;
    }
    return -1;
}

- (void)addAsset:(Asset *)as
{
    [assets addObject:as];

    DBStatement *stmt = [[Database instance] prepare:"INSERT INTO Assets VALUES(NULL, ?, ?, ?, ?);"];
    [stmt bindString:0 val:as.name];
    [stmt bindInt:1 val:as.type];
    [stmt bindDouble:2 val:as.initialBalance];
    [stmt bindInt:3 val:as.sorder];
    [stmt step];

    as.pkey = [[Database instance] lastInsertRowId];
}

- (void)deleteAsset:(Asset *)as
{
    if (selAsset == as) {
        selAsset = nil;
    }
    [as clear];

    DBStatement *stmt;
    Database *db = [Database instance];
    stmt = [db prepare:"DELETE FROM Assets WHERE key=?;"];
    [stmt bindInt:0 val:as.pkey];
    [stmt step];

    stmt = [db prepare:"DELETE FROM Transactions WHERE asset=? OR dst_asset=?;"];
    [stmt bindInt:0 val:as.pkey];
    [stmt bindInt:1 val:as.pkey];
    [stmt step];

    [assets removeObject:as];
}

- (void)updateAsset:(Asset*)asset
{
    DBStatement *stmt = [[Database instance] prepare:"UPDATE Assets SET name=?,type=?,initialBalance=?,sorder=? WHERE key=?;"];
    [stmt bindString:0 val:asset.name];
    [stmt bindInt:1 val:asset.type];
    [stmt bindDouble:2 val:asset.initialBalance];
    [stmt bindInt:3 val:asset.sorder];
    [stmt bindInt:4 val:asset.pkey];
    [stmt step];
}

- (void)reorderAsset:(int)from to:(int)to
{
    Asset *as = [[assets objectAtIndex:from] retain];
    [assets removeObjectAtIndex:from];
    [assets insertObject:as atIndex:to];
    [as release];
	
    // renumbering sorder
    Database *db = [Database instance];
    [db beginTransaction];
    DBStatement *stmt = [db prepare:"UPDATE Assets SET sorder=? WHERE key=?;"];
    for (int i = 0; i < [assets count]; i++) {
        as = [assets objectAtIndex:i];
        as.sorder = i;

        [stmt bindInt:0 val:as.sorder];
        [stmt bindInt:1 val:as.pkey];
        [stmt step];
        [stmt reset];
    }
    [db commitTransaction];
}


- (void)changeSelAsset:(Asset *)as
{
#if 0   // transaction はいちいち解放しないこととした
    if (selAsset != as) {
        if (selAsset != nil) {
            [selAsset clear];
        }
        selAsset = as;
        [selAsset reload];
    }
#endif
    selAsset = as;
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

// LRU
#define MAX_LRU_SIZE 50

//
// 摘要のヒストリ(LRU)を取り出す
//  category 指定がある場合は、こちらを優先する
//
- (NSMutableArray *)descLRUWithCategory:(int)category
{
    NSMutableArray *descAry = [[[NSMutableArray alloc] init] autorelease];

    if (category >= 0) {
        [self _setDescLRU:descAry withCategory:category];
    }
    [self _setDescLRU:descAry withCategory:-1];

    return descAry;
}

- (void)_setDescLRU:(NSMutableArray *)descAry withCategory:(int)category
{
    DBStatement *stmt;
    Database *db = [Database instance];

    if (category < 0) {
        // 全検索
        stmt = [db prepare:"SELECT description FROM Transactions ORDER BY date DESC;"];
    } else {
        // カテゴリ指定検索
        stmt = [db prepare:"SELECT description FROM Transactions"
                   " WHERE category = ? ORDER BY date DESC;"];
        [stmt bindInt:0 val:category];
    }

    // 摘要をリストに追加していく
    while ([stmt step] == SQLITE_ROW) {
        const char *cs = [stmt colCString:0];
        if (*cs == '\0') continue;
        NSString *s = [NSString stringWithCString:cs encoding:NSUTF8StringEncoding];
        if (s == nil) continue;

        // 重複チェック
        BOOL match = NO;
        NSString *ss;
        int i, max = [descAry count];
        for (i = 0; i < max; i++) {
            ss = [descAry objectAtIndex:i];
            if ([s isEqualToString:ss]) {
                match = YES;
                break;
            }
        }

        // 追加
        if (!match) {
            [descAry addObject:s];
            if ([descAry count] > MAX_LRU_SIZE) {
                break;
            }
        }
    }
}

// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (int)categoryWithDescription:(NSString *)desc
{
    DBStatement *stmt;
    int category = -1;

    stmt = [[Database instance] prepare:"SELECT category FROM Transactions WHERE description = ? ORDER BY date DESC;"];
    [stmt bindString:0 val:desc];

    if ([stmt step] == SQLITE_ROW) {
        category = [stmt colInt:0];
    }
    return category;
}

@end
