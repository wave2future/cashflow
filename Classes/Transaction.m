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

#import "Transaction.h"
#import "Database.h"

@implementation Transaction

@synthesize pkey, asset, dst_asset, date, description, memo, value, balance, type, category;

- (id)init
{
    asset = -1;
    dst_asset = -1;
    // 現在時刻で作成
    NSDate *dt = [[[NSDate alloc] init] autorelease];
    self.date = dt;
    self.description = @"";
    self.memo = @"";
    value = 0.0;
    balance = 0.0;
    type = 0;
    category = -1;
    pkey = 0; // init
    return self;
}

- (void)dealloc
{
    [date release];
    [description release];
    [memo release];
    [super dealloc];
}

- (id)initWithDate: (NSDate*)dt description:(NSString*)desc value:(double)v
{
    asset = -1;
    dst_asset = -1;
    self.date = dt;
    self.description = desc;
    self.memo = @"";
    value = v;
    balance = 0.0; // ###
    type = 0;
    category = -1;
    pkey = 0; // init
    return self;
}

// 編集値を返す
- (double)evalue:(Asset *)as
{
    double ret;

    switch (type) {
    case TYPE_INCOME:
        ret = value;
        break;
    case TYPE_OUTGO:
        ret = -value;
        break;
    case TYPE_ADJ:
        ret = balance;
        break;
    case TYPE_TRANSFER:
        if (self.asset == as.pkey) {
            ret = value;
        } else {
            ret = -value;
        }
    }
	
    if (ret == 0.0) {
        ret = 0.0;	// avoid '-0'
    }
    return ret;
}

- (void)setEvalue:(double)v withAsset:(Asset *)as
{
    switch (type) {
    case TYPE_INCOME:
        value = v;
        break;
    case TYPE_OUTGO:
        value = -v;
        break;
    case TYPE_ADJ:
        balance = v;
        break;
    case TYPE_TRANSFER:
        if (self.asset == as.pkey) {
            value = v;
        } else {
            value = -v;
        }
    }
}

- (double)fixBalance:(double)prevBalance isInitial:(BOOL)isInitial
{
    if (type == TYPE_ADJ && !isInitial) {
        // balance ではなく、value のほうを調整する
        value = balance - prevBalance;
    } else {
        balance = prevBalance + value;
    }
    return balance;
}

- (double)prevBalance
{
    double prev = balance - value;
    return prev;
}

- (id)copyWithZone:(NSZone*)zone
{
    Transaction *n = [[Transaction alloc] init];
    n.pkey = self.pkey;
    n.asset = self.asset;
    n.dst_asset = self.dst_asset;
    n.date = self.date;
    n.description = self.description;
    n.memo = self.memo;
    n.value = self.value;
    n.balance = self.balance;
    n.type = self.type;
    n.category = self.category;
    return n;
}


// for backward compatibility

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.pkey = [decoder decodeIntForKey:@"Serial"];
        self.dst_asset = -1;
        self.date = [decoder decodeObjectForKey:@"Date"];
        self.type = [decoder decodeIntForKey:@"Type"];
        self.value = [decoder decodeDoubleForKey:@"Value"];
        //self.balance = [decoder decodeDoubleForKey:@"Balance"];
        self.description = [decoder decodeObjectForKey:@"Description"];
        self.memo = [decoder decodeObjectForKey:@"Memo"];
        //self.category = [decoder decodeIntForKey:@"Category"];

        /* backward compatibility */
        if (self.type == TYPE_OUTGO) {
            self.value = -self.value;
        }

        if (self.type < 0 || self.type > 2) {
            self.type = 0; // for safety
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:pkey forKey:@"Serial"];
    [coder encodeObject:date forKey:@"Date"];
    [coder encodeInt:type forKey:@"Type"];

    /* backward compatibility */
    double v;
    if (type == TYPE_OUTGO) {
        v = -value;
    } else {
        v = value;
    }
    [coder encodeDouble:v forKey:@"Value"];

    //[coder encodeDouble:balance forKey:@"Balance"];
    [coder encodeObject:description forKey:@"Description"];
    [coder encodeObject:memo forKey:@"Memo"];
    //[coder encodeInt:category forKey:@"Category"];
}

//
// Database operations
//
+ (void)createTable
{
    [[Database instance] 
        execSql:"CREATE TABLE Transactions ("
        "key INTEGER PRIMARY KEY,"
        "asset INTEGER,"
        "dst_asset INTEGER,"
        "date DATE,"
        "type INTEGER,"
        "category INTEGER,"
        "value REAL,"
        "description TEXT,"
        "memo TEXT);"];
}

+ (NSMutableArray *)loadTransactions:(Asset *)as
{
    DBStatement *stmt;

    /* load transactions */
    stmt = [[Database instance] prepare:"SELECT key, asset, dst_asset, date, type, category, value, description, memo"
               " FROM Transactions WHERE asset = ? OR dst_asset = ? ORDER BY date;"];
    [stmt bindInt:0 val:as.pkey];
    [stmt bindInt:1 val:as.pkey];

    NSMutableArray *ary = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        Transaction *t = [[Transaction alloc] init];
        t.pkey = [stmt colInt:0];
        t.asset = [stmt colInt:1];
        t.dst_asset = [stmt colInt:2];
        t.date = [stmt colDate:3];
        t.type = [stmt colInt:4];
        t.category = [stmt colInt:5];
        t.value = [stmt colDouble:6];
        t.description = [stmt colString:7];
        t.memo = [stmt colString:8];

        if (t.type == TYPE_TRANSFER && t.dst_asset == as.pkey) {
            t.value = -t.value;
        }

        if (t.date == nil) {
            // fail safe
            NSLog(@"Invalid date: %@", [stmt colString:1]);
            [t release];
            continue;
        }

        [ary addObject:t];
        [t release];
    }

    return ary;
}

- (void)insertDb
{
    static DBStatement *stmt = nil;

    if (stmt == nil) {
        const char *s = "INSERT INTO Transactions VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);";
        stmt = [[Database instance] prepare:s];
        [stmt retain];
    }
    [stmt bindInt:0 val:asset];
    [stmt bindInt:1 val:dst_asset];
    [stmt bindDate:2 val:date];
    [stmt bindInt:3 val:type];
    [stmt bindInt:4 val:category];
    [stmt bindDouble:5 val:value];
    [stmt bindString:6 val:description];
    [stmt bindString:7 val:memo];
    [stmt step];
    [stmt reset];

    // get primary key
    pkey = [[Database instance] lastInsertRowId];
}

- (void)updateDb
{
    static DBStatement *stmt = nil;

    if (stmt == nil) {
        const char *s = "UPDATE Transactions SET asset=?, dst_asset=?, date=?, type=?, category=?, value=?, description=?, memo=? WHERE key = ?;";
        stmt = [[Database instance] prepare:s];
        [stmt retain];
    }
    [stmt bindInt:0 val:asset];
    [stmt bindInt:1 val:dst_asset];
    [stmt bindDate:2 val:date];
    [stmt bindInt:3 val:type];
    [stmt bindInt:4 val:category];
    [stmt bindDouble:5 val:value];
    [stmt bindString:6 val:description];
    [stmt bindString:7 val:memo];
    [stmt bindInt:8 val:pkey];
    [stmt step];
    [stmt reset];
}

- (void)deleteDb
{
    static DBStatement *stmt = nil;
    if (stmt == nil) {
        const char *s = "DELETE FROM Transactions WHERE key = ?;";
        stmt = [[Database instance] prepare:s];
        [stmt retain];
    }
    [stmt bindInt:0 val:pkey];
    [stmt step];
    [stmt reset];
}


@end
