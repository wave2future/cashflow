// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
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

#import "CashFlowAppDelegate.h"
#import "Report.h"

@implementation Report
@synthesize date, totalIncome, totalOutgo;

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
	[super dealloc];
}

@end

/////////////////////////////////////////////////////////////////////

@implementation Reports
@synthesize reports;

- (id)init
{
	[super init];
	reports = nil;
	return self;
}

- (void)dealloc
{
	[reports release];
	[super dealloc];
}

- (void)generate
{
	if (reports != nil) {
		[reports release];
	}
	reports = [[NSMutableArray alloc] init];

	NSMutableArray *transactions = theDataModel.transactions;
	int trnum = [transactions count];
	if (trnum == 0) return;

	NSDate *firstDate = [[transactions objectAtIndex:0] date];


	NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	// 最初の取引の月初を取得する
	NSDateComponents *dc;
	dc = [bgreg components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:firstDate];
	[dc setDay:1];

	int n = 0;
	while (n < trnum) {
		// Report 生成
		Report *r = [[Report alloc] init];
		[reports addObject:r];
		[r release];

		// 日付設定
		r.date = [greg dateFromComponents:dc];

		// 次の月の最初の日付を得る
		int month = [dc month];
		int year = [dc year];
		month++;
		if (month > 12) {
			month = 1;
			year++;
		}
		[dc setMonth:month];
		[dc setYear:year];
		NSDate *nextMonth = [greg dateFromComponents:dc];

		// 集計
		for (; n < trnum; n++) {
			Transaction *t = [transactions objectAtIndex:n];
			
			if ([t.date compare:nextMonth] != NSOrderedAscending) {
				break;
			}

			/* 金額加算 */
			double value;
			switch (t.type) {
			case TYPE_INCOME:
			case TYPE_ADJ:
				value = t.value;
				break;
			case TYPE_OUTGO:
				value = -t.value;
				break;
			}
			if (value >= 0) {
				r.totalIncome += value;
			} else {
				r.totalOutgo += -value;
			}
		}
	}
}

@end
