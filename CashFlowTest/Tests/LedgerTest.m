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
    TEST([ledger.assets count] == 1);
}

@end
