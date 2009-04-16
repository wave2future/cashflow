// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface AssetEntryTest : SenTestCase {
}
@end

@implementation AssetEntryTest

- (void)setUp
{
    //[DataModel initialize];
    //    db = [Database instance];
    //	[TestUtility initializeTestDatabase];
    //    dm = [DataModel sharedDataModel];
}

- (void)tearDown
{
    //	[dm release];
}

// transaction 指定なし
- (void)testNew
{
    AssetEntry *e = [[[AssetEntry alloc] init] autorelease];
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pkey = 999;

    [e setAsset:a transaction:nil];

    STAssertTrue(e.asset == 999, nil);
    STAssertTrue(e.value == 0.0, nil);
    STAssertTrue(e.balance == 0.0, nil);
    STAssertTrue(e.transaction.asset == 999, nil);
}

// データベースがあるときに、正常に読み込めること


@end
