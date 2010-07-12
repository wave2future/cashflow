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

#import "DescLRUManager.h"

@implementation DescLRUManager

+ (void)addDescLRU:(NSString *)description category:(int)category
{
    NSDate *now = [[[NSDate alloc] init] autorelease];
    [self addDescLRU:description category:category date:now];
}

+ (void)addDescLRU:(NSString *)description category:(int)category date:(NSDate*)date
{
    // find desc LRU from history
    dbstmt *stmt = [DescLRU gen_stmt:@"WHERE description = ? AND category = ?"];
    [stmt bindString:0 val:description];
    [stmt bindInt:1 val:category];
    NSMutableArray *ary = [DescLRU find_stmt:stmt];

    DescLRU *lru;
    if ([ary count] > 0) {
        // update date
        lru = [ary objectAtIndex:0];
    } else {
        lru = [[[DescLRU alloc] init] autorelease];
        lru.description = description;
        lru.category = category;
    }
    lru.lastUse = date;
    [lru save];
}

+ (NSMutableArray *)getDescLRUs:(int)category
{
    NSMutableArray *ary;

    if (category < 0) {
        // 全検索
        ary = [DescLRU find_cond:@"ORDER BY lastUse DESC LIMIT 100"];
    } else {
        dbstmt *stmt = [DescLRU gen_stmt:@"WHERE category = ? ORDER BY lastUse DESC LIMIT 100"];
        [stmt bindInt:0 val:category];
        ary = [DescLRU find_stmt:stmt];
    }
    return ary;
}

+ (NSMutableArray *)getDescLRUStrings:(int)category
{
    NSMutableArray *ary = [self getDescLRUs:category];

    // 文字列配列に変換
    NSMutableArray *ss = [[[NSMutableArray alloc] init] autorelease];
    for (DescLRU *lru in ary) {
        [ss addObject:lru.description];
    }

    return ss;
}

#if 0
+ (void)gc
{
    NSMutableArray *ary = [DescLRU find:cond:@"ORDER BY lastUse DESC LIMIT 1 OFFSET 100"];
    if ([ary count] > 0) {
        DescLRU *lru = [ary objectAtIndex:0];
        dbstmt *stmt = [[Database instance] prepare:@"DELETE FROM DescLRUs WHERE lastUse < ?"];
        [stmt bindDate:0 val:lru.date];
        [stmt step];
    }
}
#endif

@end
