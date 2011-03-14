// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ExportBase.h"
#import "Transaction.h"
#import "ExportServer.h"
#import "Asset.h"

@interface ExportOfx : ExportBase <UIAlertViewDelegate> {
    NSDateFormatter *mDateFormatter;
    NSCalendar *mGregCalendar;
}

- (BOOL)sendMail:(UIViewController*)parent;
- (BOOL)sendWithWebServer;

// private
- (void)_bankMessageSetResponse:(NSMutableString *)data asset:(Asset *)asset;
- (NSString*)typeString:(AssetEntry*)t;
- (NSString*)dateStr:(NSDate*)date;
- (NSString*)fitId:(AssetEntry*)t;
- (NSString*)encodeString:(NSString *)s;
@end
