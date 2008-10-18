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

#import "ExportBase.h"

@implementation ExportBase

@synthesize firstDate;

- (BOOL)sendMail { return NO; }
- (BOOL)sendWithWebServer { return NO; }
- (NSMutableString*)generateBody {	return nil; }


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
#define REPLACE(from, to) \
  [str replaceOccurrencesOfString: from withString: to \
  options:NSLiteralSearch range:NSMakeRange(0, [str length])]
	
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


- (void)sendWithWebServer:(NSString *)contentBody contentType:(NSString *)contentType filename:(NSString *)filename
{

	if (webServer == nil) {
		webServer = [[WebServer alloc] init];
	}
	webServer.contentBody = contentBody;
	webServer.contentType = contentType;
	webServer.filename = filename;
	
	NSString *url = [webServer serverUrl];

	[webServer startServer];
	
	// Alert view
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"WebExportNotation", @""), url];
	
	UIAlertView *v = [[UIAlertView alloc] 
					  initWithTitle:NSLocalizedString(@"Export", @"")
					  message:message
					  delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
	[v show];
	[v release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[webServer stopServer];
}

@end
