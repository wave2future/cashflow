// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2011, Takuya Murakami, All rights reserved.

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

#import "AppDelegate.h"
#import "Report.h"
#import "Database.h"
#import "Config.h"

@implementation ReporEntry

@synthesize start = mStart, end = mEnd;
@synthesize totalIncome = mTotalIncome, totalOutgo = mTotalOutgo;
@synthesize incomeCatReports = mIncomeCatReports, outgoCatReports = mOutgoCatReports;

- (id)init
{
    [super init];
    mStart = nil;
    mTotalIncome = 0.0;
    mTotalOutgo = 0.0;

    mIncomeCatReports = [[NSMutableArray alloc] init];
    mOutgoCatReports = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc 
{
    [mStart release];
    [mEnd release];
    [mIncomeCatReports release];
    [mOutgoCatReports release];
    [super dealloc];
}

/**
   絶対値比較
*/
static int sortCatReport(id x, id y, void *context)
{
    CatReport *xr = (CatReport *)x;
    CatReport *yr = (CatReport *)y;

    double xv = xr.value;
    double yv = yr.value;
    if (xv < 0) xv = -xv;
    if (yv < 0) yv = -yv;
	
    if (xv == yv) {
        return NSOrderedSame;
    }
    if (xv > yv) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

/**
 セットアップ
 
 @param assetKey 資産キー (-1の場合は全資産)
 @param start 開始日
 @param end 終了日
 */
- (void)setUp:(int)assetKey start:(NSDate *)a_start end:(NSDate *)a_end
{
    mStart = [a_start retain];
    mEnd = [a_end retain];

    // カテゴリ毎のレポート (CatReport) の生成
    Categories *categories = [DataModel instance].categories;
    int numCategories = [categories count];

    for (int i = 0; i < numCategories; i++) {
        Category *c = [categories categoryAtIndex:i];
        CatReport *cr = [[CatReport alloc] initWithCategory:c.pid withAsset:assetKey];

        [mIncomeCatReports addObject:cr];
        [mOutgoCatReports addObject:cr];

        [cr release];
    }
		
    // 未分類項目用レポート
    CatReport *cr = [[CatReport alloc] init];
    cr.catKey = -1;
    cr.assetKey = assetKey;

    [mIncomeCatReports addObject:cr];
    [mOutgoCatReports addObject:cr];

    [cr release];
}

/**
   取引をレポートに追加

   @return YES - 日付範囲内、NO - 日付範囲外
*/
- (BOOL)addTransaction:(Transaction *)t
{
    // 日付チェック
    NSComparisonResult cpr;
    if (mStart) {
        cpr = [t.date compare:mStart];
        if (cpr == NSOrderedAscending) return NO;
    }
    if (mEnd) {
        cpr = [t.date compare:mEnd];
        if (cpr == NSOrderedSame || cpr == NSOrderedDescending) {
            return NO;
        }
    }

    // 資産 ID チェック
    double value;
    if (mAssetKey < 0) {
        // 資産指定なしレポートの場合、資産間移動は計上しない
        if (t.type == TYPE_TRANSFER) return YES;
    } else {
        if (t.asset == mAssetKey) {
            value = t.value;
        } else if (t.dstAsset == mAssetKey) {
            value = -t.value;
        } else {
            return YES; // 対象外資産
        }
    }

    // 該当カテゴリを検索して追加
    NSMutableArray *ary = mIncomeCatReports;
    if (value < 0) {
        ary = mOutgoCatReports;
    }
    for (CatReport *cr in ary) {
        if (cr.catkey == t.category) {
            [cr addTransaction:t value:value];
            break;
        }
    }
    return YES;
}

- (void)totalUp
{		
    // ソート
    [mIncomeCatReports sortUsingFunction:sortCatReport context:nil];
    [mOutgoCatReports sortUsingFunction:sortCatReport context:nil];

    // 金額が 0 のエントリを削除する
    // TODO:

    // 集計
    mTotalIncome = 0.0;
    mTotalOutgo = 0.0;
    for (cr in mIncomeCatReports) {
        mTotalIncome += cr.value;
    }
    for (cr in mOutgoCatReports) {
        mTotalOutgo += cr.value;
    }
}

@end
