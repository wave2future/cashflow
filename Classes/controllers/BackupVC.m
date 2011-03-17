// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "BackupVC.h"
#import "DropboxBackup.h"
#import "Backup.h"

@implementation BackupViewController

+ (BackupViewController *)backupViewController
{
    BackupViewController *vc =
        [[[BackupViewController alloc] initWithNibName:@"BackupView" bundle:nil] autorelease];
    return vc;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dropbox";

        case 1:
            return @"Internal web server";  // TODO:
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // dropbox : backup and restore
            return 2;
            
        case 1:
            // internal web backup
            return 1;
    }
    return 0;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"BackupViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }

    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Backup";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Restore";
                    break;
            }
            
        case 1:
            cell.textLabel.text = @"Backup / Restore";
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Backup *webBackup;
    DropboxBackup *dropboxBackup;
    
    switch (indexPath.section) {
        case 0:
            // dropbox
            dropboxBackup = [[[DropboxBackup alloc] init] autorelease];
            switch (indexPath.row) {
                case 0:
                    [dropboxBackup doBackup:self];
                    break;
                case 1:
                    [dropboxBackup doRestore:self];
                    break;
            }
            break;

        case 1:
            // internal web server
            webBackup = [[[Backup alloc] init] autorelease];
            [webBackup execute];
            break;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
