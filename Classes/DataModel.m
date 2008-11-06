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

// DataModel V2
// (SQLite ver)

#import "DataModel.h"

@implementation DataModel

@synthesize assets, selAsset;

- (id)init
{
	[super init];

	db = nil;

	assets = [[NSMutableArray alloc] init];
	selAsset = nil;

	return self;
}

- (void)dealloc 
{
	[db release];
	[assets release];

	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////
// Load / Save DB

- (void)load
{
	// Load from DB
	db = [[Database alloc] init];

	// 現バージョンでは Asset は1個だけ
	Asset *asset = [[Asset alloc] init];
	asset.db = db;
	asset.pkey = 1;
	[assets addObject:asset];
	[asset release];

	if ([db openDB]) {
		// Okay database exists. load data.
		[asset reload];
		//[asset loadOldFormatData]; // for testing
	} else {
		[asset loadOldFormatData];
	}

	// ad hoc...
	selAsset = asset;
}

// private
- (void)reload
{
	[selAsset reload];
}

// private
- (void)resave
{
	[selAsset resave];
}

////////////////////////////////////////////////////////////////////////////
// Asset operation

- (int)assetCount
{
	return [assets count];
}

- (Asset*)assetAtIndex:(int)n
{
	return [assets objectAtIndex:n];
}

- (void)changeSelAsset:(Asset *)as
{
	if (selAsset != as) {
		if (selAsset != nil) {
			[selAsset clear];
		}
		selAsset = as;
		[selAsset reload];
	}
}

////////////////////////////////////////////////////////////////////////////
// Utility

static NSNumberFormatter *currencyFormatter = nil;

+ (NSString*)currencyString:(double)x
{
	if (currencyFormatter == nil) {
		currencyFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[currencyFormatter setLocale:[NSLocale currentLocale]];
	}
	NSString *bstr = [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:x]];

	return bstr;
}

@end
