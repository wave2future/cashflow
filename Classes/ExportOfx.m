// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportOfx.h"
#import "AppDelegate.h"
#import "ExportServer.h"

@implementation ExportOfx

- (void)dealloc
{
    [mDateFormatter release];
    [mGregCalendar release];
    [super dealloc];
}

- (BOOL)sendMail:(UIViewController *)parent
{
    // generate OFX data
    NSData *data = [self generateBody];
    if (data == nil) {
        return NO;
    }
    
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:@"CashFlow OFX Data"];

    [vc addAttachmentData:data mimeType:@"application/x-ofx" fileName:@"CashFlow.ofx"];
    [parent presentModalViewController:vc animated:YES];
    [vc release];
    return YES;
}

#if 0 
// old : iPhone 2.0
- (BOOL)sendMail:(UIViewController*)parent
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
#endif

- (BOOL)sendWithWebServer
{
    NSData *body = [self generateBody];
    if (body == nil) {
        return NO;
    }
	
    [self sendWithWebServer:body contentType:@"application/x-ofx" filename:@"cashflow.ofx"];
    return YES;
}

- (NSData *)generateBody
{
    NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];

    int max = [mAsset entryCount];

    int firstIndex = 0;
    if (mFirstDate != nil) {
        firstIndex = [mAsset firstEntryByDate:mFirstDate];
        if (firstIndex < 0) {
            return nil;
        }
    }
	
    AssetEntry *first = [mAsset entryAt:firstIndex];
    AssetEntry *last  = [mAsset entryAt:max-1];

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
    [data appendFormat:@"<ACCTID>%d\n", mAsset.pid];
    [data appendString:@"<ACCTTYPE>SAVINGS\n"]; // ### Use asset.type?
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
        AssetEntry *e = [mAsset entryAt:i];
		
        [data appendString:@"<STMTTRN>\n"];
        [data appendFormat:@"<TRNTYPE>%@\n", [self typeString:e]];
        [data appendFormat:@"<DTPOSTED>%@\n", [self dateStr:e]];
        [data appendFormat:@"<TRNAMT>%.2f\n", e.value];

        /* トランザクションの ID は日付と取引番号で生成 */
        [data appendFormat:@"<FITID>%@\n", [self fitId:e]];
        [data appendFormat:@"<NAME>%@\n", [self encodeString:e.transaction.description]];
        if ([e.transaction.memo length] > 0) {
            [data appendFormat:@"<MEMO>%@\n", [self encodeString:e.transaction.memo]];
        }
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

    const char *p = [data UTF8String];
    //const unsigned char bom[3] = {0xEF, 0xBB, 0xBF};
    NSMutableData *d = [NSMutableData dataWithLength:0];
    //[d appendBytes:bom length:sizeof(bom)];
    [d appendBytes:p length:strlen(p)];
    return d;
}

- (NSString*)typeString:(AssetEntry*)e
{
    if (e.value >= 0) {
        return @"DEP";
    }
    return @"PAYMENT";
}

- (NSString*)dateStr:(AssetEntry *)e
{
    if (mGregCalendar == nil) {
        mGregCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        mDateFormatter = [[NSDateFormatter alloc] init];
    }
    NSTimeZone *tz = [mDateFormatter timeZone];
			  
    NSDateComponents *c = [mGregCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                            | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                fromDate:e.transaction.date];

    NSString *d = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d[%+d:%@]",
                            [c year], [c month], [c day], [c hour], [c minute], [c second], [tz secondsFromGMT]/3600, [tz abbreviation]];
    return d;
}

- (NSString*)fitId:(AssetEntry*)e
{
    NSDateComponents *c = [mGregCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:e.transaction.date];
    NSString *f = [NSString stringWithFormat:@"%04d%02d%02d%d", [c year], [c month], [c day], e.transaction.pid];
    return f;
}

- (NSString *)encodeString:(NSString *)s
{
    NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
    [str setString:s];
    REPLACE(@"&", @"&amp;");
    REPLACE(@"<", @"&lt;");
    REPLACE(@">", @"&gt;");
    return str;
}

@end
