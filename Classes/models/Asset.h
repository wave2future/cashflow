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
#import "Transaction.h"
#import "Database.h"
#import "AssetBase.h"
#import "AssetEntry.h"

// asset types
#define ASSET_CASH  0
#define ASSET_BANK  1
#define	ASSET_CARD  2

#define MAX_TRANSACTIONS	5000

@class Database;

//
// 資産 (総勘定元帳の勘定に相当)
// 
@interface Asset : AssetBase {
    NSMutableArray *entries; // AssetEntry の配列
    double lastBalance;
}

- (void)rebuild;

- (int)entryCount;
- (AssetEntry *)entryAt:(int)n;
- (void)insertEntry:(AssetEntry *)tr;
- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)t;
- (void)_deleteEntryAt:(int)n;
- (void)deleteEntryAt:(int)n;
- (void)deleteOldEntriesBefore:(NSDate*)date;
- (int)firstEntryByDate:(NSDate*)date;

- (double)lastBalance;
- (void)updateInitialBalance;

@end
