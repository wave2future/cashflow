// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "DataModelTest.h"

@implementation DataModelTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    dm = [DataModel instance];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark -
#pragma mark Helpers


#pragma mark -
#pragma mark Tests

// データベースがないときに、初期化されること
- (void)testInitial
{
    // 初期データチェック
    ASSERT(dm != nil);
    ASSERT(dm.journal != nil);
    ASSERT(dm.ledger != nil);
    ASSERT(dm.categories != nil);
}

// データベースがあるときに、正常に読み込めること
- (void)testNotInitial
{
    [TestCommon installDatabase:@"testdata1"];
    dm = [DataModel instance];

    ASSERT([dm.journal.entries count] == 6);
    ASSERT([dm.ledger.assets count] == 3);
    ASSERT([dm.categories categoryCount] == 3);
}

@end
