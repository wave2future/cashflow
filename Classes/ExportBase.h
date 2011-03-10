// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ExportServer.h"
#import "Asset.h"

#define REPLACE(from, to) \
  [str replaceOccurrencesOfString: from withString: to \
  options:NSLiteralSearch range:NSMakeRange(0, [str length])]
	
@interface ExportBase : NSObject <UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    NSDate *mFirstDate;
    Asset *mAsset;

    ExportServer *mWebServer;
}

@property(nonatomic,retain) NSDate *mFirstDate;
@property(nonatomic,assign) Asset *mAsset;

- (NSData*)generateBody;
- (BOOL)sendMail:(UIViewController*)parent;
- (BOOL)sendWithWebServer;

//- (void)EncodeMailBody:(NSMutableString*)str;
- (void)sendWithWebServer:(NSData *)contentBody contentType:(NSString *)contentType filename:(NSString *)filename;

@end

