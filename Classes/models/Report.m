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

static void init_filter(Filter *filter);


@implementation CatReport
@synthesize catkey, value;
@end

@implementation Report
@synthesize date, endDate, totalIncome, totalOutgo, catReports;

- (id)init
{
    [super init];
    date = nil;
    totalIncome = 0.0;
    totalOutgo = 0.0;

    return self;
}

- (void)dealloc 
{
    [date release];
    [endDate release];
    [catReports release];
    [super dealloc];
}

@end

/////////////////////////////////////////////////////////////////////

@implementation Reports
@synthesize reports, type;

- (id)init
{
    [super init];
    type = REPORT_MONTHLY;
    reports = nil;
    return self;
}

- (void)dealloc
{
    [reports release];
    [super dealloc];
}

static int compareCatReport(id x, id y, void *context)
{
    CatReport *xr = (CatReport *)x;
    CatReport *yr = (CatReport *)y;
	
    if (xr.value == yr.value) {
        return NSOrderedSame;
    }
    if (xr.value > yr.value) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

- (void)generate:(int)t asset:(Asset*)asset
{
    self.type = t;
	
    if (reports != nil) {
        [reports release];
    }
    reports = [[NSMutableArray alloc] init];

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
    switch (type) {
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
	
    int numCategories = [[DataModel instance].categories categoryCount];
	
    while ([dd compare:lastDate] != NSOrderedDescending) {
        // Report 生成
        Report *r = [[Report alloc] init];
        [reports addObject:r];
        [r release];

        // 日付設定
        r.date = dd;
		
        // 次の期間開始時期を計算する
        dd = [greg dateByAddingComponents:steps toDate:dd options:0];
        r.endDate = dd;

        // 集計
        Filter filter;
        init_filter(&filter);

        filter.asset = assetKey;
        filter.start = r.date;
        filter.end = dd;

        filter.isIncome = YES;
        filter.isOutgo = NO;
        r.totalIncome = [self calculateSum:&filter];

        filter.isIncome = NO;
        filter.isOutgo = YES;
        r.totalOutgo = [self calculateSum:&filter];

        // カテゴリ毎の集計
        int i;
        r.catReports = [[NSMutableArray alloc] init];
        double remain = r.totalIncome + r.totalOutgo;

        init_filter(&filter);
        filter.asset = assetKey;

        for (i = 0; i < numCategories; i++) {
            Category *c = [[DataModel instance].categories categoryAtIndex:i];
            CatReport *cr = [[CatReport alloc] init];

            cr.catkey = c.pid;

            filter.category = c.pid;
            filter.start = r.date;
            filter.end = r.endDate;
            cr.value = [self calculateSum:&filter];

            remain -= cr.value;

            [r.catReports addObject:cr];
            [cr release];
        }
		
        // 未分類項目
        CatReport *cr = [[CatReport alloc] init];
        cr.catkey = -1;
        cr.value = remain;
        [r.catReports addObject:cr];
        [cr release];
		
        // ソート
        [r.catReports sortUsingFunction:compareCatReport context:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////
// Report 処理

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

static void init_filter(Filter *filter)
{
    filter->start = NULL;
    filter->end = NULL;
    filter->asset = -1;
    filter->isOutgo = NO;
    filter->isIncome = NO;
    filter->category = -1;
}

- (double)calculateSum:(Filter *)filter
{
    Transaction *t;

    double sum = 0.0;
    double value;

    for (t in [DataModel journal]) {
        // match filter
        NSComparisonResult cpr;
        if (filter->start) {
            cpr = [t.date compare:filter->start];
            if (cpr == NSOrderedAscending) continue;
        }
        if (filter->end) {
            cpr = [t.date compare:filter->end];
            if (cpr == NSOrderedSame || cpr == NSOrderedDescending) {
                continue;
            }
        }
        if (filter->category >= 0 && t.category != filter->category) {
            continue;
        }

        if (filter->asset < 0) {
            // 資産指定なしの資産間移動は計上しない
            if (t.type == TYPE_TRANSFER) {
                continue;
            }
            value = t.value;
        }
        else {
            if (t.asset == filter->asset) {
                value = t.value;
            }
            else if (t.dstAsset == filter->asset) {
                value = -t.value;
            }
            else {
                continue;
            }
        }
            
        if (filter->isOutgo && value >= 0) {
            continue;
        }
        if (filter->isIncome && value <= 0) {
            continue;
        }
        sum += value;
    }
    return sum;
}

@end
