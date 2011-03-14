// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportBase.h"

@implementation ExportBase

@synthesize firstDate = mFirstDate;
@synthesize assets = mAssets;

- (BOOL)sendMail:(UIViewController*)parent { return NO; }
- (BOOL)sendWithWebServer { return NO; }
- (NSData*)generateBody {	return nil; }

- (void)dealloc
{
    [mFirstDate release];
    [mWebServer release];
    [super dealloc];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

#if 0
/*
  変換規則:
    HTML への変換:
      &   =>  &amp;
      <   =>  &lt;
      >   =>  &gt;
      "   =>  &quot;
      \n  =>  <br>

    URLエンコーディング:
      &   =>  %26
      <   =>  %3C
      >   =>  %3E

      日本語  => NSUTF8StringEncoding でエンコード
*/

- (void)EncodeMailBody:(NSMutableString*)str
{
    // convert to HTML
    REPLACE(@"&", @"&amp;");
    REPLACE(@"<", @"&lt;");
    REPLACE(@">", @"&gt;");
    REPLACE(@"\"", @"&quot;");
    REPLACE(@" ", @"&nbsp;");
    REPLACE(@"\n", @"<br>");
    REPLACE(@"¥n", @"<br>");

    // URL encoding
    NSString *tmp = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [str setString:tmp];
	
    // encode for mail body
    REPLACE(@"&", @"%26");
}
#endif

- (void)sendWithWebServer:(NSData *)contentBody contentType:(NSString *)contentType filename:(NSString *)filename
{
    BOOL result = NO;
    NSString *message = nil;

    if (mWebServer == nil) {
        mWebServer = [[ExportServer alloc] init];
    }
    mWebServer.contentBody = contentBody;
    mWebServer.contentType = contentType;
    mWebServer.filename = filename;
	
    NSString *url = [mWebServer serverUrl];
    if (url != nil) {
        result = [mWebServer startServer];
    } else {
        message = NSLocalizedString(@"Network is unreachable.", @"");
    }

    UIAlertView *v;
    if (!result) {
        if (message == nil) {
            NSLocalizedString(@"Cannot start web server.", @"");
        }

        // error!
        v = [[UIAlertView alloc]
                initWithTitle:@"Error"
                message:message
                delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"WebExportNotation", @""), url];
	
        v = [[UIAlertView alloc] 
                initWithTitle:NSLocalizedString(@"Export", @"")
                message:message
                delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
    }

    [v show];
    [v release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [mWebServer stopServer];
}

@end
