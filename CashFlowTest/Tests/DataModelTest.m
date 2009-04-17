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
    TEST(dm != nil);
    TEST(dm.journal != nil);
    TEST(dm.ledger != nil);
    TEST(dm.categories != nil);
}

// データベースがあるときに、正常に読み込めること
- (void)testNotInitial
{
    [TestCommon installDatabase:@"testdata1"];
    dm = [DataModel instance];

    TEST([dm.journal.entries count] == 6);
    TEST([dm.ledger.assets count] == 3);
    TEST([dm.categories categoryCount] == 3);
}

@end
