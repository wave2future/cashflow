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

#import <UIKit/UIKit.h>
#import "Journal.h"
#import "Ledger.h"
#import "Category.h"
#import "DescLRU.h"
#import "Database.h"

@protocol DataModelDelegate
- (void)dataModelLoaded;
@end

@interface DataModel : NSObject
{
    // Journal
    Journal *mJournal;

    // Ledger
    Ledger *mLedger;

    // Category
    Categories *mCategories;
    
    id<DataModelDelegate> mDelegate;
    BOOL mIsLoadDone;
}

@property(nonatomic,retain) Journal *journal;
@property(nonatomic,retain) Ledger *ledger;
@property(nonatomic,retain) Categories *categories;
@property(readonly) BOOL isLoadDone;

+ (DataModel *)instance;
+ (void)finalize;

+ (Journal *)journal;
+ (Ledger *)ledger;
+ (Categories *)categories;

+ (NSDateFormatter *)dateFormatter;

// initializer
- (id)init;

// load/save
- (void)startLoad:(id<DataModelDelegate>)delegate;
- (void)loadThread:(id)dummy;
- (void)load;

// utility operation
//+ (NSString*)currencyString:(double)x;

- (int)categoryWithDescription:(NSString *)desc;

@end
