// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "ConfigViewController.h"
#import "Config.h"
#import "GenSelectListVC.h"
#import "CategoryListVC.h"
#import "PinController.h"

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
        return 3;
    }
        
    return 1;
}

#define ROW_DATE_TIME_MODE 0
#define ROW_CUTOFF_DATE 1
#define ROW_CURRENCY 2

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

    NSString *text = nil;
    NSString *detailText = @"";

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case ROW_DATE_TIME_MODE:
                    text = NSLocalizedString(@"Date style", @"");
                    switch (config.dateTimeMode) {
                        case DateTimeModeWithTime:
                            detailText = NSLocalizedString(@"Date and time (1 min)", @"");
                            break;
                        case DateTimeModeWithTime5min:
                            detailText = NSLocalizedString(@"Date and time (5 min)", @"");
                            break;
                        default:
                            detailText = NSLocalizedString(@"Date only", @"");                            
                            break;
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
                    
                case ROW_CURRENCY:
                    text = NSLocalizedString(@"Currency", @"");
                    NSString *currency = [[CurrencyManager instance] baseCurrency];
                    if (currency == nil) {
                        currency = @"System";
                    }
                    detailText = currency;
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
                                  NSLocalizedString(@"Date and time (1 min)", @""),
                                  NSLocalizedString(@"Date and time (5 min)", @""),
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
                    
                case ROW_CURRENCY:
                    typeArray = [[[NSMutableArray alloc] initWithArray:[[CurrencyManager instance] currencies]] autorelease];
                    [typeArray insertObject:@"System" atIndex:0];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:NSLocalizedString(@"Currency", @"")
                          identifier:ROW_CURRENCY];
                    NSString *currency = [[CurrencyManager instance] baseCurrency];
                    gt.selectedIndex = 0;
                    if (currency != nil) {
                        for (int i = 1; i < [typeArray count]; i++) {
                            if ([currency isEqualToString:[typeArray objectAtIndex:i]]) {
                                gt.selectedIndex = i;
                                break;
                            }
                        }
                    }
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
    NSString *currency = nil;
    
    switch (id) {
        case ROW_DATE_TIME_MODE:
            config.dateTimeMode = vc.selectedIndex;
            break;

        case ROW_CUTOFF_DATE:
            config.cutoffDate = vc.selectedIndex;
            break;

        case ROW_CURRENCY:
            if (vc.selectedIndex > 0) {
                currency = [vc.items objectAtIndex:vc.selectedIndex];
            }
            [CurrencyManager instance].baseCurrency = currency;
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
