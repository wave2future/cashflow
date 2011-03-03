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

#import "Transaction.h"
#import "Database.h"
#import "Config.h"
#import "DescLRUManager.h"

@implementation Transaction

@synthesize hasBalance = mHasBalance;
@synthesize balance = mBalance;

+ (id)allocator
{
    return [[[Transaction alloc] init] autorelease];
}

/*
 */
+ (BOOL)migrate
{
    BOOL ret = [super migrate];
    return ret;
}

- (id)init
{
    [super init];

    self.asset = -1;
    self.dstAsset = -1;
    
    // 現在時刻で作成
    NSDate *dt = [[[NSDate alloc] init] autorelease];
    
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        // 時刻を 0:00:00 に設定
        NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dt];
        dt = [greg dateFromComponents:dc];
    }
    
    self.date = dt;
    self.description = @"";
    self.memo = @"";
    self.value = 0.0;
    self.type = 0;
    self.category = -1;
    self.hasBalance = NO;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithDate: (NSDate*)dt description:(NSString*)desc value:(double)v
{
    [super init];

    self.asset = -1;
    self.dstAsset = -1;
    self.date = dt;
    self.description = desc;
    self.memo = @"";
    self.value = v;
    self.type = 0;
    self.category = -1;
    self.pid = 0; // init
    self.hasBalance = NO;
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    Transaction *n = [[Transaction alloc] init];
    n.pid = self.pid;
    n.asset = self.asset;
    n.dstAsset = self.dstAsset;
    n.date = self.date;
    n.description = self.description;
    n.memo = self.memo;
    n.value = self.value;
    n.type = self.type;
    n.category = self.category;
    n.hasBalance = self.hasBalance;
    n.balance = self.balance;
    return n;
}

- (void)_insert
{
    [super _insert];
    [DescLRUManager addDescLRU:self.description category:self.category];
}

- (void)_update
{
    [super _update];
    [DescLRUManager addDescLRU:self.description category:self.category];
}

- (void)updateWithoutUpdateLRU
{
    [super _update];
}

@end
