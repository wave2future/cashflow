// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "EditDescVC.h"
#import "DescLRU.h"
#import "DescLRUManager.h"

@interface EditDescViewControllerTest : SenTestCase <EditDescViewDelegate> {
    EditDescViewController *vc;
    NSString *description;
}
@end

@implementation EditDescViewControllerTest

#pragma mark EditDescViewDelegate

- (void)editDescViewChanged:(EditDescViewController*)v
{
    [description release];
    description = v.description;
    [description retain];
}

#pragma mark -

- (void)dealloc
{
    [description release];
    [super dealloc];
}

- (void)setUp
{
    [DataModel instance];
    description = nil;

    // erase all desc LRU data
    [DescLRU delete_cond:nil];

    vc = [[[EditDescViewController alloc] initWithNibName:@"EditDescView" bundle:nil] autorelease];

    vc.description = @"TEST";
    vc.category = 100;
    vc.delegate = self;

    [vc viewDidLoad];
    [vc viewWillAppear:YES];
}

- (void)tearDown
{
    [vc viewWillDisappear:YES];
    [description release];
}

- (UITableViewCell *)_cellForRow:(int)row section:(int)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [vc tableView:vc.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)testDescArea
{
    AssertEqualInt(2, [vc numberOfSectionsInTableView:vc.tableView]);
    AssertEqualInt(1, [vc tableView:vc.tableView numberOfRowsInSection:0]);
    
    UITableViewCell *cell = [self _cellForRow:0 section:0];
    Assert(cell != nil);

    [vc doneAction];
    Assert([description isEqualToString:@"TEST"]);
}

- (void)testEmptyLRU
{
    int n = [vc tableView:vc.tableView numberOfRowsInSection:1];
    AssertEqualInt(0, n);
}

- (void)testAnyCategory
{
    Database *db = [Database instance];
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
    Database *db = [Database instance];
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

- (void)testClickCell
{
    Database *db = [Database instance];
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    vc.category = -1;
    [vc viewWillAppear:YES]; // reload descArray

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    Assert([description isEqualToString:@"test4"]);
}

@end
