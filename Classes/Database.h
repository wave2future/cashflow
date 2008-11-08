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

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Transaction.h"
#import "Asset.h"

@class Asset;

@interface Database : NSObject {
	sqlite3 *db;
	NSDateFormatter *dateFormatter;
}

- (id)init;
- (void)dealloc;

- (BOOL)openDB;
- (void)initializeDB;

// Asset operation
- (NSMutableArray *)loadAssets;
- (void)insertAsset:(Asset*)asset;
- (void)updateAsset:(Asset*)asset;
- (void)updateInitialBalance:(Asset*)asset;
- (void)deleteAsset:(Asset*)asset;

// Transaction operation
- (NSMutableArray *)loadTransactions:(int)asset;
- (void)saveTransactions:(NSMutableArray*)transactions asset:(int)asset;

- (void)insertTransaction:(Transaction *)t asset:(int)asset;
- (void)updateTransaction:(Transaction *)t;
- (void)deleteTransaction:(Transaction *)t;
- (void)deleteOldTransactionsBefore:(NSDate*)date asset:(int)asset;

// Report operation
- (NSDate*)firstDateOfAsset:(int)asset;
- (NSDate*)lastDateOfAsset:(int)asset;
- (double)calculateSumWithinRange:(int)asset isOutgo:(BOOL)isOutgo startDate:(NSDate*)start endDate:(NSDate*)end;

// private
- (void)beginTransaction;
- (void)commitTransaction;

@end
