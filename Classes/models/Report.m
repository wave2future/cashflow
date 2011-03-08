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

/////////////////////////////////////////////////////////////////////
// Report

@implementation Report
@synthesize reportEntries = mReportEntries, type = mType;

- (id)init
{
    [super init];
    mType = REPORT_MONTHLY;
    mReportEntries = nil;
    return self;
}

- (void)dealloc
{
    [mReportEntries release];
    [super dealloc];
}

/**
 レポート生成

 @param type タイプ (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL)
 @param asset 対象資産 (nil の場合は全資産)
 */
- (void)generate:(int)type asset:(Asset*)asset
{
    mType = type;
	
    if (mReportEntries != nil) {
        [mReportEntries release];
    }
    mReportEntries = [[NSMutableArray alloc] init];

    NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
    // レポートの開始日と終了日を取得
    int assetKey;
    if (asset == nil) {
        assetKey = -1;
    } else {
        assetKey = asset.pid;
    }
    NSDate *firstDate = [self firstDateOfAsset:assetKey];
    if (firstDate == nil) return; // no data
    NSDate *lastDate = [self lastDateOfAsset:assetKey];

    // レポート周期の開始時間および間隔を求める
    NSDateComponents *dateComponents, *steps;
    NSDate *nextStartDay = nil;
	
    steps = [[[NSDateComponents alloc] init] autorelease];
    switch (mType) {
        case REPORT_DAILY:;
            dateComponents = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
            nextStartDay = [greg dateFromComponents:dateComponents];
            [steps setDay:1];
            break;

        case REPORT_WEEKLY:
            dateComponents = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
            nextStartDay = [greg dateFromComponents:dateComponents];
            int weekday = [dateComponents weekday];
            [steps setDay:-weekday+1];
            nextStartDay = [greg dateByAddingComponents:steps toDate:nextStartDay options:0];
            [steps setDay:7];
            break;

        case REPORT_MONTHLY:
            dateComponents = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];

            // 締め日設定
            int cutoffDate = [Config instance].cutoffDate;
            if (cutoffDate == 0) {
                // 月末締め ⇒ 開始は同月1日から。
                [dateComponents setDay:1];
            }
            else {
                // 一つ前の月の締め日翌日から開始
                int year = [dateComponents year];
                int month = [dateComponents month];
                month--;
                if (month < 1) {
                    month = 12;
                    year--;
                }
                [dateComponents setYear:year];
                [dateComponents setMonth:month];
                [dateComponents setDay:cutoffDate + 1];
            }

            nextStartDay = [greg dateFromComponents:dateComponents];
            [steps setMonth:1];
            break;
			
        case REPORT_ANNUAL:
            dateComponents = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
            [dateComponents setMonth:1];
            [dateComponents setDay:1];
            nextStartDay = [greg dateFromComponents:dateComponents];
            [steps setYear:1];
            break;
    }
	
    // レポートエントリを生成する
    while ([nextStartDay compare:lastDate] != NSOrderedDescending) {
        NSDate *start = nextStartDay;

        // 次の期間開始時期を計算する
        nextStartDay = [greg dateByAddingComponents:steps toDate:nextStartDay options:0];

        // Report 生成
        ReporEntry *r = [[ReporEntry alloc] init];
        //[r totalUp:assetKey start:start end:nextStartDay];

        [mReportEntries addObject:r];
        [r release];
    }

    // 集計開始
    int reportEntryIndex = 0;
    ReportEntry *reportEntry = [mReportEntries objectAtIndex:reportEntryIndex];

    // 全取引について処理を実行
    for (Transaction *t in [DataModel journal]) {
        // レポートエントリに取引を追加
        while (![reportEntry addTransaction:t])
            reportEntryIndex++;
            reportEntry = [mReportEntries objectAtInex:reportEntryIndex];
        }
    }
}

/**
   レポート内の値の最大絶対値を得る
*/
- (double)getMaxAbsValue
{
    double maxAbsValue = 1;
    for (ReporEntry *rep in mReportEntries) {
        if (rep.totalIncome > maxAbsValue) maxAbsValue = rep.totalIncome;
        if (-rep.totalOutgo > maxAbsValue) maxAbsValue = -rep.totalOutgo;
    }
    return maxAbsValue;
}

/**
 指定された資産の最初の取引日を取得
 */
- (NSDate*)firstDateOfAsset:(int)asset
{
    NSMutableArray *entries = [DataModel journal].entries;
    Transaction *t = nil;

    for (t in entries) {
        if (asset < 0) break;
        if (t.asset == asset || t.dstAsset == asset) break;
    }
    if (t == nil) {
        return nil;
    }
    return t.date;
}

/**
 指定された資産の最後の取引日を取得
 */
- (NSDate*)lastDateOfAsset:(int)asset
{
    NSMutableArray *entries = [DataModel journal].entries;
    Transaction *t = nil;
    int i;

    for (i = [entries count] - 1; i >= 0; i--) {
        t = [entries objectAtIndex:i];
        if (asset < 0) break;
        if (t.asset == asset || t.dstAsset == asset) break;
    }
    if (i < 0) return nil;
    return t.date;
}

@end

/////////////////////////////////////////////////////////////////////
// Report

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

/////////////////////////////////////////////////////////////////////
// Category Report

@implementation CatReport

@synthesize category = mCategory;
@synthesize assetKey = mAssetKey;
@synthesize sum = mSum;
@synthesize transactions = mTransactions;

- (id)initWithCategory:(int)category withAsset:(int)assetKey
{
    self = [super init];
    if (self != nil) {
        mCategory = category;
        mAssetKey = assetKey;
        mTransactions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mTransactions release];
    [super dealloc];
}

- (void)addTransaction:(Transaction*)t value:(double)value
{
    [mTransactions addObject:t];
    mSum += value;
}

@end
