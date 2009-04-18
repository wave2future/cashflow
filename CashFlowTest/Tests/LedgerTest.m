// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface LedgerTest : IUTTest {
    Ledger *ledger;
}
@end

@implementation LedgerTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    ledger = [DataModel ledger];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitial
{
    // 現金のみがあるはず
    ASSERT([ledger.assets count] == 1);
    [ledger load];
    [ledger rebuild];
    ASSERT([ledger.assets count] == 1);

    Asset *asset = [ledger assetAtIndex:0];
    ASSERT_EQUAL_INT(0, [asset entryCount]);
}

- (void)testNormal
{
    [TestCommon installDatabase:@"testdata1"];
    ledger = [DataModel ledger];
    
    // 現金のみがあるはず
    ASSERT([ledger.assets count] == 3);
    [ledger load];
    [ledger rebuild];
    ASSERT([ledger.assets count] == 3);

    ASSERT_EQUAL_INT(4, [[ledger assetAtIndex:0] entryCount]);
    ASSERT_EQUAL_INT(2, [[ledger assetAtIndex:1] entryCount]);
    ASSERT_EQUAL_INT(1, [[ledger assetAtIndex:2] entryCount]);
}

@end
