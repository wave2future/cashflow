// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"

@interface AssetListViewControllerTest : IUTTest {
    AssetListViewController *vc;
}
@end

@implementation AssetListViewController

- (void)setUp
{
    [super setUp];
    [TestCommon installDatabase:@"testdata1"];
    vc = [[AssetListViewController alloc] initWithNibName:@"AssetListView"];
}

- (void)tearDown
{
    [super tearDown];
    [vc release];
}

- (void)testNormal
{
    ASSERT_EQUAL_INT(3, [vc tableView:vc.tableView numberOfRowsInSection:0]);
    ASSERT_EQUAL_INT(1, [vc tableView:vc.tableView numberOfRowsInSection:1]); // 合計
}

@end
