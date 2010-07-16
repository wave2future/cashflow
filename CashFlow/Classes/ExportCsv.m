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
    
    int max = [asset entryCount];

    /* トランザクション */
    int i = 0;
    if (firstDate != nil) {
        i = [asset firstEntryByDate:firstDate];
        if (i < 0) {
            return nil;
        }
    }
    for (; i < max; i++) {
        AssetEntry *e = [asset entryAt:i];

        if (firstDate != nil && [e.transaction.date compare:firstDate] == NSOrderedAscending) continue;
		
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
