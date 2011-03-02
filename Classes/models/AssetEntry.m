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

@synthesize assetKey = mAssetKey;
@synthesize transaction = mTransaction;
@synthesize value = mValue;
@synthesize balance = mBalance;

- (void)dealloc
{
    [mTransaction release];
    [super dealloc];
}

- (id)init
{
    self = [super init];

    mTransaction = nil;
    mAssetKey = -1;
    mValue = 0.0;
    mBalance = 0.0;

    return self;
}

- (id)initWithTransaction:(Transaction *)t withAsset:(Asset *)asset
{
    self = [self init];

    mAssetKey = asset.pid;
    
    if (t == nil) {
        // 新規エントリ生成
        self.transaction = [[[Transaction alloc] init] autorelease];
        mTransaction.asset = self.assetKey;
    }
    else {
        self.transaction = t;

        if ([self isDstAsset]) {
            mValue = -t.value;
        } else {
            mValue = t.value;
        }
    }

    return self;
}

//
// 資産間移動の移動先取引なら YES を返す
//
- (BOOL)isDstAsset
{
    if (mTransaction.type == TYPE_TRANSFER && mAssetKey == mTransaction.dst_asset) {
        return YES;
    }

    return NO;
}

- (Transaction *)transaction
{
    [self _setupTransaction];
    return mTransaction;
}

// 値を Transaction に書き戻す
- (void)_setupTransaction
{
    if (mTransaction.type == TYPE_ADJ) {
        mTransaction.balance = mBalance;
        mTransaction.hasBalance = YES;
    } else {
        mTransaction.hasBalance = NO;
        if ([self isDstAsset]) {
            mTransaction.value = -value;
        } else {
            mTransaction.value = value;
        }
    }
}

// TransactionViewController 用の値を返す
- (double)evalue
{
    double ret = 0.0;

    switch (mTransaction.type) {
    case TYPE_INCOME:
        ret = mValue;
        break;
    case TYPE_OUTGO:
        ret = -mValue;
        break;
    case TYPE_ADJ:
        ret = mBalance;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            ret = mValue;
        } else {
            ret = -mValue;
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
    switch (mTransaction.type) {
    case TYPE_INCOME:
        mValue = v;
        break;
    case TYPE_OUTGO:
        mValue = -v;
        break;
    case TYPE_ADJ:
        mBalance = v;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            mValue = v;
        } else {
            mValue = -v;
        }
        break;
    }
}

// 種別変更
//   type のほか、transaction の dst_asset, asset, value も調整する
- (BOOL)changeType:(int)type assetKey:(int)as dstAssetKey:(int)das
{
    if (type == TYPE_TRANSFER) {
        if (das == self.assetKey) {
            // 自分あて転送は許可しない
            // ### TBD
            return NO;
        }

        mTransaction.type = TYPE_TRANSFER;
        [self setDstAsset:das];
    } else {
        // 資産間移動でない取引に変更した場合、強制的に指定資産の取引に変更する
        double ev = self.evalue;
        mTransaction.type = type;
        mTransaction.asset = as;
        mTransaction.dst_asset = -1;
        self.evalue = ev;
    }
    return YES;
}

// 転送先資産のキーを返す
- (int)dstAsset
{
    if (mTransaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return -1;
    }

    if ([self isDstAsset]) {
        return mTransaction.asset;
    }

    return mTransaction.dst_asset;
}

- (void)setDstAsset:(int)as
{
    if (mTransaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return;
    }

    if ([self isDstAsset]) {
        mTransaction.asset = as;
    } else {
        mTransaction.dst_asset = as;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AssetEntry *e = [[AssetEntry alloc] init];
    e.assetKey = self.assetKey;
    e.value = self.value;
    e.balance = self.balance;
    e.transaction = [[self.transaction copy] autorelease];

    return e;
}

@end
