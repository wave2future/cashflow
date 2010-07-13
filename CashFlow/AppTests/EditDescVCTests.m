// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "EditDescVC.h"
#import "DescLRU.h"
#import "DescLRUManager.h"

@interface EditDescViewControllerTest : SenTestCase {
    EditDescViewController *vc;
}
@end

@implementation EditDescViewControllerTest

- (UIViewController *)rootViewController
{
    vc = [[[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:nil] autorelease];
    return vc;
}

- (void)setUp
{
    // erase all desc LRU data
    [DescLRU delete_cond:nil];

    vc = [[[EditDescViewController alloc] initWithNibName:@"EditDescView" bundle:nil] autorelease];

    vc.description = @"hoge";
    vc.category = 100;

    [vc viewDidLoad];
    [vc viewWillAppear:YES];
}

- (void)tearDown
{
    [vc viewWillDisappear:YES];
}

- (UITableViewCell *)_cellForRow:(int)row section:(int)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [vc tableView:vc.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)testDescArea
{
    AssertEqualInt(2, [vc tableView:vc.tableView numberOfSectionsInTableView]);
    AssertEqualInt(1, [vc tableView:vc.tableView numberOfRowsInSection:0]);
    
    UITableViewCell *cell = [self _cellForRow:0 section:0];
    Assert(cell != nil);

    // TBD: test textField
}

- (void)testEmptyLRU
{
    int n = [vc tableView:vc.tableView numberOfRowsInSection:1];
    AssertEqualInt(0, n);
}

- (void)testAnyCategory
{
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    vc.category = -1;
    [vc viewWillAppear:YES]; // reload descArray

    int n = [vc tableView:vc.tableView numberOfRowsInSection:1];
    AssertEqualInt(6, n);

    UITableViewCell *cell;
    cell = [self _cellForRow:0 section:1];
    Assert([cell.textLabel.text isEqualToString:@"test5"]);
    cell = [self _cellForRow:5 section:1];
    Assert([cell.textLabel.text isEqualToString:@"test0"]);
}

- (void)testSpecificCategory
{
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    vc.category = 1;
    [vc viewWillAppear:YES]; // reload descArray

    int n = [vc tableView:vc.tableView numberOfRowsInSection:1];
    AssertEqualInt(2, n);

    UITableViewCell *cell;
    cell = [self _cellForRow:0 section:1];
    Assert([cell.textLabel.text isEqualToString:@"test4"]);
    cell = [self _cellForRow:1 section:1];
    Assert([cell.textLabel.text isEqualToString:@"test1"]);
}

@end
