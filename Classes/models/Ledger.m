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

@synthesize assets = mAssets;

- (void)load
{
    self.assets = [Asset find_all:@"ORDER BY sorder"];
}

- (void)rebuild
{
    for (Asset *as in mAssets) {
        [as rebuild];
    }
}

- (int)assetCount
{
    return [mAssets count];
}

- (Asset*)assetAtIndex:(int)n
{
    return [mAssets objectAtIndex:n];
}

- (Asset*)assetWithKey:(int)pid
{
    for (Asset *as in mAssets) {
        if (as.pid == pid) return as;
    }
    return nil;
}

- (int)assetIndexWithKey:(int)pid
{
    int i;
    for (i = 0; i < [mAssets count]; i++) {
        Asset *as = [mAssets objectAtIndex:i];
        if (as.pid == pid) return i;
    }
    return -1;
}

- (void)addAsset:(Asset *)as
{
    [mAssets addObject:as];
    [as save];
}

- (void)deleteAsset:(Asset *)as
{
    [as delete];

    [[DataModel journal] deleteAllTransactionsWithAsset:as];

    [mAssets removeObject:as];

    [self rebuild];
}

- (void)updateAsset:(Asset*)asset
{
    [asset save];
}

- (void)reorderAsset:(int)from to:(int)to
{
    Asset *as = [[mAssets objectAtIndex:from] retain];
    [mAssets removeObjectAtIndex:from];
    [mAssets insertObject:as atIndex:to];
    [as release];
	
    // renumbering sorder
    Database *db = [Database instance];
    [db beginTransaction];
    for (int i = 0; i < [mAssets count]; i++) {
        as = [mAssets objectAtIndex:i];
        as.sorder = i;
        [as save];
    }
    [db commitTransaction];
}

@end
