// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"

@interface DropboxBackup : NSObject <DBRestClientDelegate, DBLoginControllerDelegate>
{
    UIViewController *mViewController;
    DBRestClient *mRestClient;
    int mMode;
}

@property(readonly) DBRestClient *restClient;

- (void)doBackup:(UIViewController *)viewController;
- (void)doRestore:(UIViewController *)viewController;

- (void)_login;
- (void)_exec;

@end
