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

#import "AppDelegate.h"
#import "ConfigViewController.h"
#import "Config.h"
#import "GenSelectListVC.h"
#import "CategoryListVC.h"
#import "Pin.h"

@implementation ConfigViewController

- (id)init
{
    self = [super initWithNibName:@"ConfigView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Config", @"");

    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

#if 0
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Config", @"");
}
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
        
    return 1;
}

#define ROW_DATE_TIME_MODE 0
#define ROW_CUTOFF_DATE 1

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellid = @"ConfigCell";

    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    Config *config = [Config instance];

    NSString *text;
    NSString *detailText = @"";

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case ROW_DATE_TIME_MODE:
                    text = NSLocalizedString(@"Date style", @"");
                    if (config.dateTimeMode == DateTimeModeWithTime) {
                        detailText = NSLocalizedString(@"Date and time", @"");
                    } else {
                        detailText = NSLocalizedString(@"Date only", @"");
                    }
                    break;

                case ROW_CUTOFF_DATE:
                    text = NSLocalizedString(@"Cutoff date", @"");
                    if (config.cutoffDate == 0) {
                        detailText = NSLocalizedString(@"End of month", @"");
                    } else {
                        detailText = [NSString stringWithFormat:@"%d", config.cutoffDate];
                    }
                    break;
            }
            break;
            
        case 1:
            text = NSLocalizedString(@"Edit Categories", @"");
            break;
            
        case 2:
            text = NSLocalizedString(@"Set PIN Code", @"");
            break;
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Config *config = [Config instance];

    GenSelectListViewController *gt = nil;
    NSMutableArray *typeArray;
    CategoryListViewController *categoryVC;
    PinController *pinController;

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case ROW_DATE_TIME_MODE:
                    typeArray = [[[NSArray alloc] initWithObjects:
                                  NSLocalizedString(@"Date and time", @""),
                                  NSLocalizedString(@"Date only", @""),
                                  nil] autorelease];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:NSLocalizedString(@"Date style", @"")
                          identifier:ROW_DATE_TIME_MODE];
                    gt.selectedIndex = config.dateTimeMode;
                    break;

                case ROW_CUTOFF_DATE:
                    typeArray = [[[NSMutableArray alloc] init] autorelease];
                    [typeArray addObject:NSLocalizedString(@"End of month", @"")];
                    for (int i = 1; i <= 28; i++) {
                        [typeArray addObject:[NSString stringWithFormat:@"%d", i]];
                    }
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:NSLocalizedString(@"Cutoff date", @"")
                          identifier:ROW_CUTOFF_DATE];
                    gt.selectedIndex = config.cutoffDate;
                    break;
            }

            [self.navigationController pushViewController:gt animated:YES];
            break;
            
        case 1:
            categoryVC = [[[CategoryListViewController alloc] init] autorelease];
            categoryVC.isSelectMode = NO;
            [self.navigationController pushViewController:categoryVC animated:YES];
            break;
            
        case 2:
            pinController = [[[PinController alloc] init] autorelease];
            [pinController modifyPin:self];
            break;
    }

}

- (BOOL)genSelectListViewChanged:(GenSelectListViewController *)vc identifier:(int)id
{
    Config *config = [Config instance];

    switch (id) {
        case ROW_DATE_TIME_MODE:
            config.dateTimeMode = vc.selectedIndex;
            break;

        case ROW_CUTOFF_DATE:
            config.cutoffDate = vc.selectedIndex;
            break;
    }

    [config save];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
