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

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataModel.h"

#define REPORT_DAILY 0
#define REPORT_WEEKLY 1
#define REPORT_MONTHLY 2
#define REPORT_ANNUAL 3

#define MAX_REPORT_ENTRIES      365

/*
  レポートの構造

  Report -> ReportEntry -> CatReport
 */

// レポート
@interface Report : NSObject {
    int mType; // REPORT_XXX
    NSMutableArray *mReportEntries;  // ReportEntry の配列
}

@property(nonatomic,assign) int type;
@property(nonatomic,retain) NSMutableArray *reportEntries;

- (void)generate:(int)type asset:(Asset *)asset;
- (double)getMaxAbsValue;

// private
- (NSDate*)firstDateOfAsset:(int)asset;
- (NSDate*)lastDateOfAsset:(int)asset;

@end

// レポートエントリ
@interface ReporEntry : NSObject {
    NSDate *mStart;
    NSDate *mEnd;
    double mTotalIncome;
    double mTotalOutgo;

    NSMutableArray *mIncomeCatReports; // CatReport の配列
    NSMutableArray *mOutgoCatReports; // CatReport の配列
}

@property(nonatomic,readonly) NSDate *start;
@property(nonatomic,readonly) NSDate *end;
@property(nonatomic,readonly) double totalIncome;
@property(nonatomic,readonly) double totalOutgo;
@property(nonatomic,readonly) NSMutableArray *incomeCatReports;
@property(nonatomic,readonly) NSMutableArray *outgoCatReports;

- (BOOL)addTransaction:(Transaction*)t;
- (void)sortAndTotalUp;
- (double)_sortAndTotalUp:(NSMutableArray*)array;

@end
// レポート(カテゴリ毎)
@interface CatReport : NSObject {
    int mCategory;
    int mAssetKey;
    double mSum;

    NSMutableArray *mTransactions; // Transaction の配列
}

@property(nonatomic,readonly) int category;
@property(nonatomic,readonly) int assetKey;
@property(nonatomic,readonly) double sum;
@property(nonatomic,readonly) NSMutableArray *transactions;

- (id)initWithCategory:(int)category withAsset:(int)assetKey;

@end


