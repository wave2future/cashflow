// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface DataModelTest : SenTestCase {
}
@end

@implementation DataModelTest

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

// データベースがないときに、初期化されること
- (void)testLoadDB
{
    [DataModel finalize];

    // テストデータを読み込ませる
    DataModel *dm = [DataModel instance];

    STAssertNotNil(dm, nil);

#if 0
    [dm loadDB];

    // 先頭に All Shelf があることを確認する
    STAssertTrue([dm shelvesCount] >= 1, nil); // TBD
    Shelf *shelf = [dm shelfAtIndex:0];
    STAssertNotNil(shelf, nil);
#endif
}

// データベースがあるときに、正常に読み込めること


@end
