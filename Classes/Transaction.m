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

#import "Transaction.h"


@implementation Transaction

@synthesize date, description, memo, value, balance, type, serial;

- (id)init
{
	// 現在時刻で作成
	NSDate *dt = [[[NSDate alloc] init] autorelease];
	self.date = dt;
	self.description = @"";
	self.memo = @"";
	value = 0.0;
	balance = 0.0;
	type = 0;
	serial = 0; // init
	return self;
}

- (void)dealloc
{
	[date release];
	[description release];
	[memo release];
	[super dealloc];
}

- (id)initWithDate: (NSDate*)dt description:(NSString*)desc value:(double)v
{
	self.date = dt;
	self.description = desc;
	self.memo = @"";
	value = v;
	balance = 0.0; // ###
	serial = 0; // init
	return self;
}

- (double)fixBalance:(double)prevBalance
{
	switch (type) {
		case TYPE_INCOME:
			balance = prevBalance + value;
			break;
			
		case TYPE_OUTGO:
			balance = prevBalance - value;
			break;
			
		case TYPE_ADJ:
			value = balance - prevBalance;
			break;
	}
	return balance;
}

- (double)prevBalance
{
	double prev;
	
	switch (type) {
		case TYPE_INCOME:
		case TYPE_ADJ:
			prev = balance - value;
			break;
			
		case TYPE_OUTGO:
			prev = balance + value;
			break;
	}
	return prev;
}

- (id)copyWithZone:(NSZone*)zone
{
	Transaction *n = [[Transaction alloc] init];
	n.serial = self.serial;
	n.date = self.date;
	n.description = self.description;
	n.memo = self.memo;
	n.value = self.value;
	n.balance = self.balance;
	n.type = self.type;
	return n;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if (self) {
		self.serial = [decoder decodeIntForKey:@"Serial"];
		self.date = [decoder decodeObjectForKey:@"Date"];
		self.type = [decoder decodeIntForKey:@"Type"];
		self.value = [decoder decodeDoubleForKey:@"Value"];
		self.balance = [decoder decodeDoubleForKey:@"Balance"];
		self.description = [decoder decodeObjectForKey:@"Description"];
		self.memo = [decoder decodeObjectForKey:@"Memo"];
		
		if (self.type < 0 || self.type > 2) {
			self.type = 0; // for safety
		}
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:serial forKey:@"Serial"];
	[coder encodeObject:date forKey:@"Date"];
	[coder encodeInt:type forKey:@"Type"];
	[coder encodeDouble:value forKey:@"Value"];
	[coder encodeDouble:balance forKey:@"Balance"];
	[coder encodeObject:description forKey:@"Description"];
	[coder encodeObject:memo forKey:@"Memo"];
}

@end
