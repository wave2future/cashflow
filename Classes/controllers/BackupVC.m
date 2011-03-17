// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "BackupVC.h"
#import "DropboxBackup.h"
#import "WebServerBackup.h"

@implementation BackupViewController

+ (BackupViewController *)backupViewController
{
    BackupViewController *vc =
        [[[BackupViewController alloc] initWithNibName:@"BackupView" bundle:nil] autorelease];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [mDropboxBackup release];
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
            return 3;
            
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
                    cell.textLabel.text = NSLocalizedString(@"Backup", @"");
                    break;
                    
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Restore", @"");
                    break;
                    
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Unlink dropbox account", @"");
                    break;
            }
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                   NSLocalizedString(@"Backup", @""),
                                   NSLocalizedString(@"Restore", @"")];
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    WebServerBackup *webBackup;
    UIAlertView *alertView;
    
    switch (indexPath.section) {
        case 0:
            // dropbox
            if (mDropboxBackup == nil) {
                mDropboxBackup = [[DropboxBackup alloc] init:self];
            }
            switch (indexPath.row) {
                case 0: // backup
                    [self _showActivityIndicator];
                    [mDropboxBackup doBackup:self];
                    break;
                    
                case 1: //restore
                    alertView = [[[UIAlertView alloc] initWithTitle:@"Confirm" 
                                                            message:@"This will overwrite all current data." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"OK", nil] autorelease];
                    [alertView show];
                    break;
                    
                case 2: // unlink dropbox account
                    [mDropboxBackup unlink];
                    break;
            }
            break;

        case 1:
            // internal web server
            webBackup = [[[WebServerBackup alloc] init] autorelease];
            [webBackup execute];
            break;
    }
}

#pragma mark UIAlertViewDelegate protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // OK
        [self _showActivityIndicator];
        [mDropboxBackup doRestore:self];
    }
}

#pragma mark DropboxBackupDelegate

- (void)dropboxBackupFinished
{
    [self _dismissActivityIndicator];
}

#pragma mark utils

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)_showActivityIndicator
{
    // ActivityIndicator を表示させる
    UIView *parent;
    if (IS_IPAD) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        parent = appDelegate.splitViewController.view;
    } else {
        parent = self.navigationController.view;
    }
    
    CGRect frame = [parent frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    mLoadingView = [[UIView alloc] initWithFrame:frame];
    [mLoadingView setBackgroundColor:[UIColor blackColor]];
    [mLoadingView setAlpha:0.5];
    mLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parent addSubview:mLoadingView];
    
    UIActivityIndicatorView *ai = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [mLoadingView addSubview:ai];
    [ai setFrame:CGRectMake ((frame.size.width / 2) - 20, (frame.size.height/2)-60, 40, 40)];
    ai.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [ai startAnimating];
}

- (void)_dismissActivityIndicator
{
    [mLoadingView removeFromSuperview];
    mLoadingView = nil;
}

@end
