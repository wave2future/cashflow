// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2010, Takuya Murakami, All rights reserved.

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
// Reports

@implementation Report
@synthesize reports = mReportEntries, type = mType;

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

static int compareCatReport(id x, id y, void *context)
{
    CatReport *xr = (CatReport *)x;
    CatReport *yr = (CatReport *)y;
	
    if (xr.sum == yr.sum) {
        return NSOrderedSame;
    }
    if (xr.sum > yr.sum) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

- (void)generate:(int)t asset:(Asset*)asset
{
    self.type = t;
	
    if (mReportEntries != nil) {
        [mReportEntries release];
    }
    mReportEntries = [[NSMutableArray alloc] init];

    NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
    //	NSDate *firstDate = [[asset transactionAt:0] date];
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
    NSDateComponents *dc, *steps;
    NSDate *dd = nil;
	
    steps = [[[NSDateComponents alloc] init] autorelease];
    switch (mType) {
    case REPORT_MONTHLY:
        dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];

        // 締め日設定
        int cutoffDate = [Config instance].cutoffDate;
        if (cutoffDate == 0) {
            // 月末締め ⇒ 開始は同月1日から。
            [dc setDay:1];
        }
        else {
            // 一つ前の月の締め日翌日から開始
            int year = [dc year];
            int month = [dc month];
            month--;
            if (month < 1) {
                month = 12;
                year--;
            }
            [dc setYear:year];
            [dc setMonth:month];
            [dc setDay:cutoffDate + 1];
        }

        dd = [greg dateFromComponents:dc];
        [steps setMonth:1];
        break;
			
    case REPORT_WEEKLY:
        dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
        dd = [greg dateFromComponents:dc];
        int weekday = [dc weekday];
        [steps setDay:-weekday+1];
        dd = [greg dateByAddingComponents:steps toDate:dd options:0];
        [steps setDay:7];
        break;
    }
	
    while ([dd compare:lastDate] != NSOrderedDescending) {
        NSDate *start = dd;

        // 次の期間開始時期を計算する
        dd = [greg dateByAddingComponents:steps toDate:dd options:0];

        // Report 生成
        ReporEntry *r = [[ReporEntry alloc] init];
        [r totalUp:assetKey start:start end:dd];

        [mReportEntries addObject:r];
        [r release];
    }
}

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
@synthesize date = mDate, endDate = mEndDate;
@synthesize totalIncome = mTotalIncome, totalOutgo = mTotalOutgo;
@synthesize catReports = mCatReports;

- (id)init
{
    [super init];
    mDate = nil;
    mTotalIncome = 0.0;
    mTotalOutgo = 0.0;

    mCatReports = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc 
{
    [mDate release];
    [mEndDate release];
    [mCatReports release];
    [super dealloc];
}

- (void)totalUp:(int)assetKey start:(NSDate *)start end:(NSDate *)end
{
    mDate = [start retain];
    mEndDate = [end retain];

    // カテゴリ毎の集計
    int i;
    int numCategories = [[DataModel instance].categories categoryCount];

    for (i = 0; i < numCategories; i++) {
        Category *c = [[DataModel instance].categories categoryAtIndex:i];
        CatReport *cr = [[CatReport alloc] init];

        [cr totalUp:c.pid asset:assetKey start:self.date end:self.endDate];

        [mCatReports addObject:cr];
        [cr release];
    }
		
    // 未分類項目
    CatReport *cr = [[CatReport alloc] init];
    [cr totalUp:-1 asset:assetKey start:mDate end:mEndDate];
    [mCatReports addObject:cr];
    [cr release];
		
    // ソート
    [mCatReports sortUsingFunction:compareCatReport context:nil];

    // 集計
    mTotalIncome = 0.0;
    mTotalOutgo = 0.0;
    for (cr in self.catReports) {
        mTotalIncome += cr.income;
        mTotalOutgo += cr.outgo;
    }
}

@end

/////////////////////////////////////////////////////////////////////
// Category Report

@implementation CatReport

@synthesize catkey = mCatkey, income = mIncome, outgo = mOutgo, sum = mSum;
@synthesize transactions = mTransactions;

- (id)init
{
    [super init];
    mTransactions = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc
{
    [mTransactions release];
    [super dealloc];
}

- (void)totalUp:(int)key asset:(int)assetKey start:(NSDate*)start end:(NSDate*)end
{
    mCatkey = key;
    mSum = 0.0;

    double value;

    for (Transaction *t in [DataModel journal]) {
        // match filter
        NSComparisonResult cpr;
        if (start) {
            cpr = [t.date compare:start];
            if (cpr == NSOrderedAscending) continue;
        }
        if (end) {
            cpr = [t.date compare:end];
            if (cpr == NSOrderedSame || cpr == NSOrderedDescending) {
                continue;
            }
        }
        if (t.category != mCatkey) {
            continue;
        }

        if (assetKey < 0) {
            // 資産指定なしレポートの場合、資産間移動は計上しない
            if (t.type == TYPE_TRANSFER) {
                continue;
            }
            value = t.value;
        }
        else {
            if (t.asset == assetKey) {
                value = t.value;
            }
            else if (t.dstAsset == assetKey) {
                value = -t.value;
            }
            else {
                continue;
            }
        }
        [mTransactions addObject:t];
        
        if (value >= 0) {
            mIncome += value;
        } else {
            mOutgo += value;
        }
        mSum += value;
    }
}

@end
