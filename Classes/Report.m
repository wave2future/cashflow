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

#import "AppDelegate.h"
#import "Report.h"
#import "Database.h"

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
    db = [Database instance];
	
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
        assetKey = asset.pkey;
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
        dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:firstDate];
        [dc setDay:1];
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
        r.totalIncome = [self calculateSumWithinRange:assetKey isOutgo:NO startDate:r.date endDate:dd];
        r.totalOutgo = -[self calculateSumWithinRange:assetKey isOutgo:YES startDate:r.date endDate:dd];

        // カテゴリ毎の集計
        int i;
        r.catReports = [[NSMutableArray alloc] init];
        double remain = r.totalIncome - r.totalOutgo;

        for (i = 0; i < numCategories; i++) {
            Category *c = [[DataModel instance].categories categoryAtIndex:i];
            CatReport *cr = [[CatReport alloc] init];

            cr.catkey = c.pkey;
            cr.value = [self calculateSumWithinRangeCategory:assetKey startDate:r.date endDate:r.endDate category:cr.catkey];
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
    DBStatement *stmt;

    if (asset < 0) {
        stmt = [db prepare:"SELECT MIN(date) FROM Transactions;"];
    } else {
        stmt = [db prepare:"SELECT MIN(date) FROM Transactions WHERE asset=? OR dst_asset=?;"];
        [stmt bindInt:0 val:asset];
        [stmt bindInt:1 val:asset];
    }

    NSDate *date = nil;
    if ([stmt step] == SQLITE_ROW) {
        date = [stmt colDate:0];
    }
    return date;
}

- (NSDate*)lastDateOfAsset:(int)asset
{
    DBStatement *stmt;

    if (asset < 0) {
        stmt = [db prepare:"SELECT MAX(date) FROM Transactions;"];
    } else {
        stmt = [db prepare:"SELECT MAX(date) FROM Transactions WHERE asset=? OR dst_asset=?;"];
        [stmt bindInt:0 val:asset];
        [stmt bindInt:1 val:asset];
    }

    NSDate *date = nil;
    if ([stmt step] == SQLITE_ROW) {
        date = [stmt colDate:0];
    }

    return date;
}

static void init_filter(Filter *filter)
{
    filter->start = NULL;
    filter->end = NULL;
    filter->asset = -1;
    filter->dst_asset = -1;
    filter->isOutgo = NO;
    filter->isIncome = NO;
    filter->category = -1;
}

- (double)calculateSum:(Filter *)filter
{
    Transaction *t;

    double sum = 0.0;
    for (t in [DataModel journal]) {
        // match filter
        if (filter.start && [t.date compare:filter.start] == NSOrderedAscending) {
            continue;
        }
        if (filter.end && [t.date compare:filter.end] == NSOrderedDescending) {
            continue;
        }
        if (filter.asset >= 0 && t.asset != filter.asset) {
            continue;
        }
        if (filter.dst_asset >= 0 && t.dst_asset != filter.dst_asset) {
            continue;
        }
        if (filter.category >= 0 && t.category != filter.category) {
            continue;
        }
        if (filter.isOutgo && t.value >= 0) {
            continue;
        }
        if (filter.isIncome && t.value <= 0) {
            continue;
        }
        sum += t.value;
    }
    return sum;
}


- (double)calculateSumWithinRange:(int)asset isOutgo:(BOOL)isOutgo startDate:(NSDate*)start endDate:(NSDate*)end
{
    double sum = 0.0;
    Filter filter;
    init_filter(&filter);

    filter.asset = asset;
    filter.isOutgo = isOutgo;
    filter.isIncome = !isOutgo;
    filter.start = start;
    filter.end = end;

    sum = [self calculateSum:&filter];

    filter.asset = -1;
    filter.dst_asset = asset;
    filter.isOutgo = !isOutgo;
    filter.isIncome = isOutgo;

    sum -= [self calculateSum:&filter];

    return sum;
}

- (double)calculateSumWithinRangeCategory:(int)asset startDate:(NSDate*)start endDate:(NSDate*)end category:(int)category
{
    double sum = 0.0;
    Filter filter;
    init_filter(&filter);

    filter.asset = asset;
    filter.start = start;
    filter.end = end;
    filter.category = category;

    sum = [self calculateSum:&filter];

    filter.asset = -1;
    filter.dst_asset = asset;

    sum -= [self calculateSum:&filter];

    return sum;
}

@end
