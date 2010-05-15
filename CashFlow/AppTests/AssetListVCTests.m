// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"

@interface AssetListViewControllerTest : SenTestCase {
    AssetListViewController *vc;
}
@end

@implementation AssetListViewControllerTest

- (UIViewController *)rootViewController
{
    vc = [[[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:nil] autorelease];
    return vc;
}

- (void)setUp
{
    [TestCommon installDatabase:@"testdata1"];

    // AssetView を表示させないようにガードする
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:-1 forKey:@"firstShowAssetIndex"];
}

- (void)tearDown
{
}

- (NSString *)cellText:(int)row section:(int)section
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [vc tableView:vc.tableView cellForRowAtIndexPath:index];
    NSLog(@"'%@'", cell.textLabel.text);
    return cell.textLabel.text;
}

- (void)testNormal
{
    // test number of rows
    AssertEqualInt(3, [vc tableView:vc.tableView numberOfRowsInSection:0]);
    AssertEqualInt(1, [vc tableView:vc.tableView numberOfRowsInSection:1]); // 合計

    // test cell
    Assert([[self cellText:0 section:0] isEqualToString:@"Cash : ￥9,000"]);
    Assert([[self cellText:1 section:0] isEqualToString:@"Bank : ￥195,000"]);
    Assert([[self cellText:2 section:0] isEqualToString:@"Card : -￥12,100"]);
}

@end
