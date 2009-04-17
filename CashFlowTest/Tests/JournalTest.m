// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface JournalTest : IUTTest {
    Journal *journal;
}
@end

@implementation JournalTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    journal = [DataModel journal];
}

- (void)tearDown
{
    [super tearDown];
}

// Journal 上限数チェック
#if 0
- (void)testJournalInsertUpperLimit
{
    TEST([journal.entries count] == 0);

    Transaction *t;
    int i;

    for (i = 0; i < MAX_TRANSACTIONS; i++) {
        t = [[Transaction alloc] init];
        t.asset = 1; // cash
        [journal insertTransaction:t];
        [t release];

        TEST([journal.entries count] == i + 1);
    }

    Ledger *ledger = [DataModel ledger];
    [ledger rebuild];
    Asset *asset = [ledger assetAtIndex:0];
    TEST([asset entryCount] == MAX_TRANSACTIONS);
    
    // 上限数＋１個目
    t = [[Transaction alloc] init];
    t.asset = 1; // cash
    [journal insertTransaction:t];
    [t release];

    TEST([journal.entries count] == MAX_TRANSACTIONS);
}
#endif

@end
