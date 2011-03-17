// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DropBoxBackup.h"
#import "Database.h"
#import "AppDelegate.h"

#define	BACKUP_FILENAME	@"cashflow.db"

#define MODE_BACKUP 0
#define MODE_RESTORE 1

@implementation DropBoxBackup

- (void)dealloc
{
    [mRestClient release];
    [super dealloc];
}

- (void)doBackup:(UIViewController *)viewController
{
    mMode = MODE_BACKUP;
    mViewController = viewController;
    [self _login];
}

- (void)doRestore:(UIViewController *)viewController
{
    mMode = MODE_RESTORE;
    mViewController = viewController;
    [self _login];
}

- (void)_login
{
    DBSession *session = [DBSession sharedSession];
    
    // ログイン処理
    if (![session isLinked]) {
        // 未ログイン
        DBLoginController *controller = [[DBLoginController new] autorelease];
        controller.delegate = self;
        [controller presentFromController:mViewController];
    } else {
        // ログイン済み
        [self _exec];
    }
}

- (void)_exec
{
    NSString *dbPath = [[Database instance] dbPath:DBNAME];

    switch (mMode) {
        case MODE_BACKUP:
            [self.restClient
             uploadFile:BACKUP_FILENAME
             toPath:@"/"
             fromPath:dbPath];
            break;

        case MODE_RESTORE:
            [self.restClient loadFile:@"/" BACKUP_FILENAME intoPath:dbPath];
            break;
    }
}

- (DBRestClient *)restClient
{
    if (mRestClient == nil) {
    	mRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	mRestClient.delegate = self;
    }
    return mRestClient;
}

#pragma mrk DBRestClientDelegate

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
}

// restore done
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
}

// restore failed
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    [self _exec];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
    // callback?
}

@end
