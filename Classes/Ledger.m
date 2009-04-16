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

// Ledger : 総勘定元帳

#import "DataModel.h"
#import "Ledger.h"

@implementation Ledger

@synthesize assets, selAsset;

- (void)load
{
    DBStatement *stmt;
    self.assets = [[[NSMutableArray alloc] init] autorelease];

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

    if ([assets count] > 0) {
        selAsset = [assets objectAtIndex:0];
    }
}

- (void)rebuild
{
    for (Asset *as in assets) {
        [as rebuild];
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

- (void)changeSelAsset:(Asset *)as
{
    selAsset = as;
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
    
    DBStatement *stmt;
    Database *db = [Database instance];
    stmt = [db prepare:"DELETE FROM Assets WHERE key=?;"];
    [stmt bindInt:0 val:as.pkey];
    [stmt step];

    [[DataModel journal] deleteTransactionsWithAsset:as];
#if 0 // ###
    stmt = [db prepare:"DELETE FROM Transactions WHERE asset=? OR dst_asset=?;"];
    [stmt bindInt:0 val:as.pkey];
    [stmt bindInt:1 val:as.pkey];
    [stmt step];
#endif

    [assets removeObject:as];

    [self rebuild];
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

@end
