// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Backup.h"
#import "BackupServer.h"

@implementation Backup

- (void)execute
{
    BOOL result = NO;
    NSString *message = nil;
    
    mBackupServer = [[BackupServer alloc] init];
    NSString *url = [mBackupServer serverUrl];
    if (url != nil) {
        result = [mBackupServer startServer];
    } else {
        message = NSLocalizedString(@"Network is unreachable.", @"");
    }
    
    UIAlertView *v;
    if (!result) {
        if (message == nil) {
            message = NSLocalizedString(@"Cannot start web server.", @"");
        }
        
        [mBackupServer release];
        v = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:message
             delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
             otherButtonTitles:nil];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"BackupNotation", @""), url];
        
        v = [[UIAlertView alloc]
             initWithTitle:NSLocalizedString(@"Backup and restore", @"")
             message:message
             delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
             otherButtonTitles:nil];
    }
    [v show];
    [v release];
    
    [self retain]; // release in alert view delegate
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [mBackupServer stopServer];
    [mBackupServer release];
    mBackupServer = nil;

    [self release];
}

@end
