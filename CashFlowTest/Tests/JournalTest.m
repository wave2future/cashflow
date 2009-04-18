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


- (void)testReload
{
    NOTYET;
}

- (void)testFastEnumeration
{
    NOTYET;
}

- (void)testInsertTransaction
{
    NOTYET;
}

- (void)testReplaceTransaction
{
    NOTYET;
}

- (void)testDeleteTransaction
{
    NOTYET;
}

- (void)testADeleteTransactionWithAsset
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    Asset *asset = [[[Asset alloc] init] autorelease];

    ASSERT_EQUAL_INT(6, [journal.entries count]);

    asset.pkey = 4; // not exist
    [journal deleteTransactionsWithAsset:asset];
    ASSERT_EQUAL_INT(6, [journal.entries count]);
    
    asset.pkey = 1;
    [journal deleteTransactionsWithAsset:asset];
    ASSERT_EQUAL_INT(2, [journal.entries count]);
    
    asset.pkey = 2;
    [journal deleteTransactionsWithAsset:asset];
    ASSERT_EQUAL_INT(1, [journal.entries count]);

    asset.pkey = 3;
    [journal deleteTransactionsWithAsset:asset];
    ASSERT_EQUAL_INT(0, [journal.entries count]);
}

// Journal 上限数チェック
#if 0
- (void)testJournalInsertUpperLimit
{
    ASSERT([journal.entries count] == 0);

    Transaction *t;
    int i;

    for (i = 0; i < MAX_TRANSACTIONS; i++) {
        t = [[Transaction alloc] init];
        t.asset = 1; // cash
        [journal insertTransaction:t];
        [t release];

        ASSERT([journal.entries count] == i + 1);
    }

    Ledger *ledger = [DataModel ledger];
    [ledger rebuild];
    Asset *asset = [ledger assetAtIndex:0];
    ASSERT([asset entryCount] == MAX_TRANSACTIONS);
    
    // 上限数＋１個目
    t = [[Transaction alloc] init];
    t.asset = 1; // cash
    [journal insertTransaction:t];
    [t release];

    ASSERT([journal.entries count] == MAX_TRANSACTIONS);
}
#endif

@end
