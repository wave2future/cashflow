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
#import "Config.h"

@implementation DataModel

@synthesize journal, ledger, categories;

static DataModel *theDataModel = nil;

+ (DataModel *)instance
{
    if (!theDataModel) {
        theDataModel = [[DataModel alloc] init];
        [theDataModel load];
    }
    return theDataModel;
}

+ (void)finalize
{
    if (theDataModel) {
        [theDataModel release];
        theDataModel = nil;
    }
}

- (id)init
{
    [super init];

    journal = [[Journal alloc] init];
    ledger = [[Ledger alloc] init];
    categories = [[Categories alloc] init];
	
    return self;
}

- (void)dealloc 
{
    [journal release];
    [ledger release];
    [categories release];

    [super dealloc];
}

+ (Journal *)journal
{
    return [DataModel instance].journal;
}

+ (Ledger *)ledger
{
    return [DataModel instance].ledger;
}

+ (Categories *)categories
{
    return [DataModel instance].categories;
}

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
    if (![db openDB]) {
        [db initializeDB];
    }
	
    // Load all transactions
    [journal reload];

    // Load ledger
    [ledger load];
    [ledger rebuild];

    // Load categories
    [categories reload];
}

////////////////////////////////////////////////////////////////////////////
// Utility

//
// DateFormatter
//
+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dfDateTime = nil;
    static NSDateFormatter *dfDateOnly = nil;

    if (!dfDateTime) {
        dfDateTime = [[NSDateFormatter alloc] init];
        [dfDateTime setDateStyle:NSDateFormatterMediumStyle];
        [dfDateTime setTimeStyle:NSDateFormatterShortStyle];
    }
    if (!dfDateOnly) {
        dfDateOnly = [[NSDateFormatter alloc] init];
        [dfDateOnly setDateStyle:NSDateFormatterMediumStyle];
        [dfDateOnly setTimeStyle:NSDateFormatterNoStyle];
    }

    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        return dfDateOnly;
    }
    return dfDateTime;
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
