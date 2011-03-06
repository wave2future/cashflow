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

// DataModel V2
// (SQLite ver)

#import "AppDelegate.h"
#import "DataModel.h"
#import "CashflowDatabase.h"
#import "Config.h"
#import "DescLRUManager.h"

@implementation DataModel

@synthesize journal = mJournal;
@synthesize ledger = mLedger;
@synthesize categories = mCategories;
@synthesize isLoadDone = mIsLoadDone;

static DataModel *theDataModel = nil;

+ (DataModel *)instance
{
    if (!theDataModel) {
        theDataModel = [[DataModel alloc] init];
        //[theDataModel load];
    }
    return theDataModel;
}

+ (void)finalize
{
    if (theDataModel) {
        [theDataModel release];
        theDataModel = nil;
    }
}

- (id)init
{
    [super init];

    mJournal = [[Journal alloc] init];
    mLedger = [[Ledger alloc] init];
    mCategories = [[Categories alloc] init];
    mIsLoadDone = NO;
	
    return self;
}

- (void)dealloc 
{
    [mJournal release];
    [mLedger release];
    [mCategories release];

    [super dealloc];
}

+ (Journal *)journal
{
    return [DataModel instance].journal;
}

+ (Ledger *)ledger
{
    return [DataModel instance].ledger;
}

+ (Categories *)categories
{
    return [DataModel instance].categories;
}

- (void)startLoad:(id<DataModelDelegate>)delegate
{
    mDelegate = delegate;
    mIsLoadDone = NO;
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadThread:) object:nil];
    [thread start];
    [thread release];
}

- (void)loadThread:(id)dummy
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];

    [self load];
    
    mIsLoadDone = YES;
    if (mDelegate) {
        [mDelegate dataModelLoaded];
    }
    
    [pool release];
    [NSThread exit];
}

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
    if (![db open:DBNAME]) {
    }

    [Transaction migrate];
    [Asset migrate];
    [Category migrate];
    [DescLRU migrate];
    
    [DescLRUManager migrate];
	
    // Load all transactions
    [mJournal reload];

    // Load ledger
    [mLedger load];
    [mLedger rebuild];

    // Load categories
    [mCategories reload];
}

////////////////////////////////////////////////////////////////////////////
// Utility

//
// DateFormatter
//
+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dfDateTime = nil;
    static NSDateFormatter *dfDateOnly = nil;

    if (!dfDateTime) {
        dfDateTime = [self _dateFormatterWithDayOfWeek:NSDateFormatterShortStyle];
    }
    if (!dfDateOnly) {
        dfDateOnly = [self _dateFormatterWithDayOfWeek:NSDateFormatterNoStyle];
    }

    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        return dfDateOnly;
    }
    return dfDateTime;
}

+ (NSDateFormatter *)_dateFormatterWithDayOfWeek:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:timeStyle];
    
    NSMutableString *s = [NSMutableString stringWithCapacity:30];
    [s setString:[df dateFormat]];

    [s replaceOccurrencesOfString:@"MMM d, y" withString:@"EEE, MMM d, y" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"yyyy/MM/dd" withString:@"yyyy/MM/dd(EEEEE)" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    
    [df setDateFormat:s];
    return df;
}


// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (int)categoryWithDescription:(NSString *)desc
{
    Transaction *t = [Transaction find_by_description:desc cond:@"ORDER BY date DESC"];

    if (t == nil) {
        return -1;
    }
    return t.category;
}

@end
