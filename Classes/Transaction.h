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

#define TYPE_OUTGO      0       // 支払
#define TYPE_INCOME	1       // 入金
#define	TYPE_ADJ        2       // 残高調整
#define TYPE_TRANSFER   3       // 資産間移動

@class Asset;

@interface Transaction : NSObject <NSCoding, NSCopying> {
    int pkey; // primary key
    NSDate *date;
    int asset;
    int dst_asset;
    NSString *description;
    NSString *memo;
    double value; // plus - income, minus - outgo.
    double balance;
    int type;  // TYPE_*
    int category;
}

@property(nonatomic,assign) int pkey;
@property(nonatomic,assign) int asset;
@property(nonatomic,assign) int dst_asset;
@property(nonatomic,copy) NSDate *date;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *memo;
@property(nonatomic,assign) double value;
@property(nonatomic,assign) double balance;
@property(nonatomic,assign) int type;
@property(nonatomic,assign) int category;

- (id)initWithDate:(NSDate*)date description:(NSString*)desc value:(double)v;

- (double)evalue:(Asset *)as;
- (void)setEvalue:(double)v withAsset:(Asset *)as;

- (double)fixBalance:(double)prevBalance isInitial:(BOOL)isInitial;
- (double)prevBalance;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;

+ (void)createTable;
+ (NSMutableArray *)loadTransactions:(Asset *)as;
- (void)insertDb;
- (void)updateDb;
- (void)deleteDb;

@end
