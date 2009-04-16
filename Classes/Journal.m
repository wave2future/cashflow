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

// 仕訳帳

#import "AppDelegate.h"
#import "DataModel.h"
#import "Journal.h"

@implementation Journal

@synthesize entries;

- (id)init
{
    if (self = [super init]) {
        entries = nil;
    }
    return self;
}

- (void)dealloc 
{
    [entries release];
    [super dealloc];
}

- (void)reload
{
    if (entries) {
        [entries release];
    }
    entries = [Transaction loadTransactions];
}

/**
   NSFastEnumeration protocol
*/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [entries countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (void)insertTransaction:(Transaction*)tr
{
    int i;
    int max = [entries count];
    Transaction *t = nil;

    // 挿入位置を探す
    for (i = 0; i < max; i++) {
        t = [entries objectAtIndex:i];
        if ([tr.date compare:t.date] == NSOrderedAscending) {
            break;
        }
    }

    // 挿入
    [entries insertObject:tr atIndex:i];
    [tr insertDb];

    // 上限チェック
    if ([entries count] > MAX_TRANSACTIONS) {
        // 最も古い取引を削除する
        // Note: 初期残高を調整するため、Asset 側で削除させる
        Transaction *t = [entries objectAtIndex:0];
        Asset *asset = [[DataModel ledger] assetWithKey:t.asset];
        [asset deleteEntryAt:0];
    }
}

- (void)replaceTransaction:(Transaction *)from withObject:(Transaction*)to
{
    // copy key
    to.pkey = from.pkey;

    // update DB
    [to updateDb];

    int idx = [entries indexOfObject:from];
    [entries replaceObjectAtIndex:idx withObject:to];
}

- (void)deleteTransaction:(Transaction *)t
{
    [t deleteDb];
    [entries removeObject:t];
}

- (void)deleteTransactionsWithAsset:(Asset *)asset
{
    [Transaction deleteDbWithAsset:asset.pkey];
    [self reload];

    // rebuild が必要!
}

@end
