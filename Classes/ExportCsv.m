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


#import "ExportCsv.h"
#import "CashFlowAppDelegate.h"

@implementation MailCsv

- (BOOL)sendMail
{
	NSMutableString *s = [self generateMailUrl];
	if (s == nil) return NO;
	
	NSLog(@"%@", s);

	NSURL *url = [NSURL URLWithString:s];

	[[UIApplication sharedApplication] openURL:url];
	
	// not reach here
	return YES;
}

- (NSMutableString *)generateMailUrl
{
	NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];

	[data appendString:@"mailto:?Subject=CashFlow%20CSV%20Data&body="];
	[data appendString:@"%20CashFlow%20generated%20CSV%20data%20%0D%0A"];
	[data appendString:@"Serial,Date,Value,Balance,Description%0D%0A"];

	NSMutableString *body = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];
	if (! [self generateCsv:body]) {
		return nil; // no data
	}
	[self EncodeMailBody:body];

	[data appendString:body];
	return data;
}

- (BOOL)generateCsv:(NSMutableString *)data
{
	DataModel *dm = [CashFlowAppDelegate theDataModel];

	int max = [dm getTransactionCount];

	NSDateFormatter *datefmt = [[[NSDateFormatter alloc] init] autorelease];
	[datefmt setDateStyle:NSDateFormatterMediumStyle];
	[datefmt setTimeStyle:NSDateFormatterShortStyle];

	/* トランザクション */
	int i = 0;
	if (firstDate != nil) {
		i = [dm firstTransactionByDate:firstDate];
		if (i < 0) {
			return NO; // do nothing
		}
	}
	for (; i < max; i++) {
		Transaction *t = [dm getTransactionAt:i];

		if (firstDate != nil && [t.date compare:firstDate] == NSOrderedAscending) continue;
		
		NSMutableString *d = [[NSMutableString alloc] init];
		[d appendFormat:@"%d,", t.serial];
		[d appendFormat:@"%@,", [datefmt stringFromDate:t.date]];
		[d appendFormat:@"%.2f,", t.value];
		[d appendFormat:@"%.2f,", t.balance];
		[d appendFormat:@"%@", t.description];
		[d appendString:@"\n"];
		[data appendString:d];
		[d release];
	}
	return YES;
}

@end
