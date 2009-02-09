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

// DataModel V1 (for backward compatibility)

#import "AppDelegate.h"
#import "DataModelV1.h"

@implementation DataModelV1

@synthesize transactions, initialBalance;

+ (DataModelV1*)allocWithLoad
{
    DataModelV1 *dm = nil;

    NSString *dataPath = [AppDelegate pathOfDataFile:@"Transactions.dat"];

    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    if (data != nil) {
        NSKeyedUnarchiver *ar = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        [ar setClass:[DataModelV1 class] forClassName:@"DataModel"]; // class name changed...

        dm = [ar decodeObjectForKey:@"DataModel"];
        if (dm != nil) {
            [dm retain];
            [ar finishDecoding];
        }
    }
	
    return dm;
}

+ (void)deleteDataFile
{
    // データを削除
    NSString *dataPath = [AppDelegate pathOfDataFile:@"Transactions.dat"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManger removeFileAtPath:dataPath handler:self];
}

- (id)init
{
    [super init];

    initialBalance = 0.0;
    transactions = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc 
{
    [transactions release];
    [super dealloc];
}

- (int)transactionCount
{
    return transactions.count;
}

- (Transaction*)transactionAt:(int)n
{
    return [transactions objectAtIndex:n];
}

//
// Archive / Unarchive
//
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        //self.serialCounter = [decoder decodeIntForKey:@"serialCounter"];
        self.initialBalance = [decoder decodeDoubleForKey:@"initialBalance"];
        self.transactions = [decoder decodeObjectForKey:@"Transactions"];

        //[self recalcBalanceInitial];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    //[coder encodeInt:serialCounter forKey:@"serialCounter"];
    [coder encodeDouble:initialBalance forKey:@"initialBalance"];
    [coder encodeObject:transactions forKey:@"Transactions"];
}

@end
