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


#import "ExportOfx.h"
#import "CashFlowAppDelegate.h"
#import "WebServer.h"

@implementation ExportOfx

- (BOOL)sendMail
{
	NSMutableString *data = [[[NSMutableString alloc] init] autorelease];
	[data appendString:@"mailto:?Subject=CashFlow%20OFX&body="];

	NSMutableString *tmp = [[[NSMutableString alloc] init] autorelease];
	[tmp setString:NSLocalizedString(@"OFXHeadString", @"OFX header notification")];
	[tmp appendString:@"\n\n--- BEGIN ---\n"];
	[self EncodeMailBody:tmp];
	[data appendString:tmp];
	
	NSMutableString *body = [self generateBody];
	if (body == nil) {
		return NO;
	}

	[self EncodeMailBody:body];

	[data appendString:body];

	[tmp setString:@"--- END ---\n"];
	[self EncodeMailBody:tmp];
	[data appendString:tmp];
	
	NSLog(@"%@", data);

	NSURL *url = [NSURL URLWithString:data];

	[[UIApplication sharedApplication] openURL:url];
	
	// not reach here...
	return YES;
}

- (BOOL)sendWithWebServer
{
	NSMutableString *body = [self generateBody];
	if (body == nil) {
		return NO;
	}
	
	[self sendWithWebServer:body contentType:@"application/x-ofx" filename:@"cashflow.ofx"];
	return YES;
}

- (NSMutableString *)generateBody
{
	NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];

	Asset *asset = theDataModel.selAsset;
	int max = [asset transactionCount];

	int firstIndex = 0;
	if (firstDate != nil) {
		firstIndex = [asset firstTransactionByDate:firstDate];
		if (firstIndex < 0) {
			return nil;
		}
	}
	
	Transaction *first = [asset transactionAt:firstIndex];
	Transaction *last  = [asset transactionAt:max-1];

	[data appendString:@"OFXHEADER:100\n"];
	[data appendString:@"DATA:OFXSGML\n"];
	[data appendString:@"VERSION:102\n"];
	[data appendString:@"SECURITY:NONE\n"];
	[data appendString:@"ENCODING:UTF-8\n"];
	[data appendString:@"CHARSET:CSUNICODE\n"];
	[data appendString:@"COMPRESSION:NONE\n"];
	[data appendString:@"OLDFILEUID:NONE\n"];
	[data appendString:@"NEWFILEUID:NONE\n"];
	[data appendString:@"\n"];

	/* 金融機関情報(サインオンレスポンス) */
	[data appendString:@"<OFX>\n"];
	[data appendString:@"<SIGNONMSGSRSV1>\n"];
	[data appendString:@"<SONRS>\n"];
	[data appendString:@"<STATUS>\n"];
	[data appendString:@"<CODE>0\n"];
	[data appendString:@"<SEVERITY>INFO\n"];
	[data appendString:@"</STATUS>\n"];
	[data appendString:@"<DTSERVER>"];
	[data appendString:[self dateStr:last]];
	[data appendString:@"\n"];
	
	[data appendString:@"<LANGUAGE>JPN\n"];
	[data appendString:@"<FI>\n"];
	[data appendString:@"<ORG>000\n"];
	[data appendString:@"</FI>\n"];
	[data appendString:@"</SONRS>\n"];
	[data appendString:@"</SIGNONMSGSRSV1>\n"];

	/* 口座情報(バンクメッセージレスポンス) */
	[data appendString:@"<BANKMSGSRSV1>\n"];

	/* 預金口座型明細情報作成 */
	[data appendString:@"<STMTTRNRS>\n"];
	[data appendString:@"<TRNUID>0\n"];
	[data appendString:@"<STATUS>\n"];
	[data appendString:@"<CODE>0\n"];
	[data appendString:@"<SEVERITY>INFO\n"];
	[data appendString:@"</STATUS>\n"];

	[data appendString:@"<STMTRS>\n"];
	
	NSNumberFormatter *fmt = [[[NSNumberFormatter alloc] init] autorelease];
	NSString *ccode = [fmt currencyCode];
	[data appendFormat:@"<CURDEF>%@\n", ccode];

	[data appendString:@"<BANKACCTFROM>\n"];
	[data appendString:@"<BANKID>CashFlow\n"];
	[data appendString:@"<BRANCHID>000\n"];
	[data appendString:@"<ACCTID>0000000\n"];
	[data appendString:@"<ACCTTYPE>SAVINGS\n"];
	[data appendString:@"</BANKACCTFROM>\n"];

	/* 明細情報開始(バンクトランザクションリスト) */
	[data appendString:@"<BANKTRANLIST>\n"];
	[data appendString:@"<DTSTART>"];
	[data appendString:[self dateStr:first]];
	[data appendString:@"\n"];
	[data appendString:@"<DTEND>"];
	[data appendString:[self dateStr:last]];
	[data appendString:@"\n"];
	/* トランザクション */
	int i;
	for (i = firstIndex; i < max; i++) {
		Transaction *t = [asset transactionAt:i];
		
		[data appendString:@"<STMTTRN>\n"];
		[data appendFormat:@"<TRNTYPE>%@\n", [self transTypeString:t]];
		[data appendFormat:@"<DTPOSTED>%@\n", [self dateStr:t]];
		[data appendFormat:@"<TRNAMT>%.2f\n", t.value];

		/* トランザクションの ID は日付と取引番号で生成 */
		[data appendFormat:@"<FITID>%@\n", [self fitId:t]];
		[data appendFormat:@"<NAME>%@\n", t.description];
		[data appendFormat:@"<MEMO>%@\n", t.memo];
		[data appendString:@"</STMTTRN>\n"];
	}

	[data appendString:@"</BANKTRANLIST>\n"];

	/* 残高 */
	[data appendString:@"<LEDGERBAL>\n"];
	[data appendFormat:@"<BALAMT>%.2f\n", last.balance];
	[data appendFormat:@"<DTASOF>%@\n", [self dateStr:last]];
	[data appendString:@"</LEDGERBAL>\n"];

	/* OFX 終了 */
	[data appendString:@"</STMTRS>\n"];
	[data appendString:@"</STMTTRNRS>\n"];
	[data appendString:@"</BANKMSGSRSV1>\n"];
	[data appendString:@"</OFX>\n"];

	return data;
}

- (NSString*)transTypeString:(Transaction*)t
{
	if (t.value >= 0) {
		return @"DEP";
	}
	return @"PAYMENT";
}

- (NSString*)dateStr:(Transaction*)t
{
	if (greg == nil) {
		greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		df = [[NSDateFormatter alloc] init];
	}
	NSTimeZone *tz = [df timeZone];
			  
	NSDateComponents *c = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
											| NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
								  fromDate:t.date];

	NSString *d = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d[%+d:%@]",
				   [c year], [c month], [c day], [c hour], [c minute], [c second], [tz secondsFromGMT]/3600, [tz abbreviation]];
	return d;
}

- (NSString*)fitId:(Transaction*)t
{
	NSDateComponents *c = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:t.date];
	NSString *f = [NSString stringWithFormat:@"%04d%02d%02d%d", [c year], [c month], [c day], t.pkey];
	return f;
}

@end
