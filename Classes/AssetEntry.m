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

// AssetEntry

#import "AppDelegate.h"
#import "Asset.h"

@implementation AssetEntry

@synthesize asset, transaction, balance;

- (id)init
{
    self = [super init];

    transaction = nil;
    asset = -1;
    value = 0.0;
    balance = 0.0;

    return self;
}

- (void)dealloc
{
    [transaction release];
    [super dealloc];
}

- (void)setAsset:(Asset *)as transaction:(Transaction *)t
{
    asset = as.pkey;
    if (t != transaction) {
        [transaction release];
        transaction = [t retain];
    }
    
    if (t == nil) {
        // 新規エントリ生成
        transaction = [[Transaction alloc] init];
        transaction.asset = asset;
    }
    else {
        if ([self isDstAsset]) {
            value = -t.value;
        } else {
            value = t.value;
        }
    }
}

//
// 資産間移動の移動先取引なら YES を返す
//
- (BOOL)isDstAsset
{
    if (transaction.type == TYPE_TRANSFER && asset == transaction.dst_asset) {
        return YES;
    }

    return NO;
}

- (double)value
{
    return value;
}

- (void)setValue:(double)v
{
    value = v;

    if ([self isDstAsset]) {
        transaction.value = -value;
    } else {
        transaction.value = value;
    }
}    

// TransactionViewController 用の値を返す
- (double)evalue
{
    double ret;

    switch (transaction.type) {
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
        if ([self isDstAsset]) {
            ret = value;
        } else {
            ret = -value;
        }
        break;
    }
	
    if (ret == 0.0) {
        ret = 0.0;	// avoid '-0'
    }
    return ret;
}

// 編集値をセット
- (void)setEvalue:(double)v
{
    switch (transaction.type) {
    case TYPE_INCOME:
        self.value = v;
        break;
    case TYPE_OUTGO:
        self.value = -v;
        break;
    case TYPE_ADJ:
        balance = v;
        transaction.balance = v;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            self.value = v;
        } else {
            self.value = -v;
        }
        break;
    }
}

// 転送先資産のキーを返す
- (int)dstAsset
{
    if (transaction.type != TYPE_TRANSFER) {
        return -1;
    }

    if ([self isDstAsset]) {
        return transaction.asset;
    }

    return transaction.dst_asset;
}

- (void)setDstAsset:(int)as
{
    if (transaction.type != TYPE_TRANSFER) {
        // ###
        return;
    }

    if ([self isDstAsset]) {
        transaction.asset = as;
    } else {
        transaction.dst_asset = as;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AssetEntry *e = [[AssetEntry alloc] init];
    e.asset = self.asset;
    e.value = self.value;
    e.balance = self.balance;
    e.transaction = [[self.transaction copy] autorelease];

    return e;
}

@end
