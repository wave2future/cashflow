// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportCsv.h"
#import "AppDelegate.h"

@implementation ExportCsv

- (BOOL)sendMail:(UIViewController *)parent
{
    // generate CSV data
    NSData *body = [self generateBody];
    if (body == nil) {
        return NO;
    }

    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
        
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:@"CashFlow CSV Data"];

    [vc addAttachmentData:body mimeType:@"text/comma-separeted-value" fileName:@"CashFlow.txt"];
    [parent presentModalViewController:vc animated:YES];
    [vc release];
    return YES;
}

- (BOOL)sendWithWebServer
{
    NSData *body = [self generateBody];
    if (body == nil) {
        return NO;
    }
	
    [self sendWithWebServer:body contentType:@"text/csv" filename:@"cashflow.txt"];
    return YES;
}

- (NSData *)generateBody
{
    NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];
    [data appendString:@"Serial,Date,Value,Balance,Description,Category,Memo\n"];
    
    int max = [mAsset entryCount];

    /* トランザクション */
    int i = 0;
    if (mFirstDate != nil) {
        i = [mAsset firstEntryByDate:mFirstDate];
        if (i < 0) {
            return nil;
        }
    }
    for (; i < max; i++) {
        AssetEntry *e = [mAsset entryAt:i];

        if (mFirstDate != nil && [e.transaction.date compare:mFirstDate] == NSOrderedAscending) continue;
		
        NSMutableString *d = [[NSMutableString alloc] init];
        [d appendFormat:@"%d,", e.transaction.pid];
        [d appendFormat:@"%@,", [[DataModel dateFormatter] stringFromDate:e.transaction.date]];
        [d appendFormat:@"%.2f,", e.value];
        [d appendFormat:@"%.2f,", e.balance];
        [d appendFormat:@"%@,", e.transaction.description];
        [d appendFormat:@"%@,", [[DataModel instance].categories categoryStringWithKey:e.transaction.category]];
        [d appendFormat:@"%@", e.transaction.memo];
        [d appendString:@"\n"];
        [data appendString:d];
        [d release];
    }

    // locale 毎の encoding を決める
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *lang = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([lang isEqualToString:@"ja"]) {
        // 日本語の場合は Shift-JIS にする
        encoding = NSShiftJISStringEncoding;
    }

    // バイナリ列に変換
    NSMutableData *d = [NSMutableData dataWithLength:0];
    const char *p = [data cStringUsingEncoding:encoding];
    if (!p) {
        encoding = NSUTF8StringEncoding;
        p = [data UTF8String]; // fallback
    }
    if (encoding == NSUTF8StringEncoding) {
        // UTF-8 BOM を追加
        const unsigned char bom[3] = {0xEF, 0xBB, 0xBF};
        [d appendBytes:bom length:sizeof(bom)];
    }
    [d appendBytes:p length:strlen(p)];

    return d;
}

@end
