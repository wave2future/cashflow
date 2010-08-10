// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2010, Takuya Murakami, All rights reserved.

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

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "SupportMail.h"
#import "UIDevice-Hardware.h"

@implementation SupportMail

- (BOOL)sendMail:(UIViewController *)parent
{
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    
    MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:@"[CashFlow Support]"];
    [vc setToRecipients:[NSArray arrayWithObject:@"cashflow-support@tmurakam.org"]];
    [vc setMessageBody:@"\n\n" isHTML:NO];
    
    NSMutableString *info = [NSMutableString stringWithString:@""];
#ifdef FREE_VERSION
    [info appendString:@"Version: CashFlow Free ver "];
#else
    [info appendString:@"Version: CashFlow Std. ver "];
#endif
    [info appendString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
    [info appendString:@"\n"];

    UIDevice *device = [UIDevice currentDevice];
    [info appendFormat:@"Device: %@\n", [device platform]];
    [info appendFormat:@"OS: %@\n", [device systemVersion]];

    DataModel *dm = [DataModel instance];
    [info appendFormat:@"# Assets: %d\n", [dm.ledger assetCount]];
    [info appendFormat:@"# Transactions: %d\n", [dm.journal.entries count]];
    
    NSMutableData *d = [NSMutableData dataWithLength:0];
    const char *p = [info UTF8String];
    [d appendBytes:p length:strlen(p)];

    [vc addAttachmentData:d mimeType:@"text/plain" fileName:@"SupportInfo.txt"];
    
    [parent presentModalViewController:vc animated:YES];
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
    [self release];
}

@end
