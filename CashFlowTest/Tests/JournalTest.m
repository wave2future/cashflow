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
    ASSERT_EQUAL_INT(0, [journal.entries count]);
    [journal reload];
    ASSERT_EQUAL_INT(0, [journal.entries count]);
    
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    ASSERT_EQUAL_INT(6, [journal.entries count]);

    [journal reload];
    ASSERT_EQUAL_INT(6, [journal.entries count]);
}

- (void)testFastEnumeration
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    
    int i = 1;
    for (Transaction *t in journal) {
        ASSERT_EQUAL_INT(i, t.pkey);
        i++;
    }
}

- (void)testInsertTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];

    // 途中に挿入する
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.pkey = 7;
    t.asset = 1;
    t.type = 0;
    t.value = 100;
    t.date = [TestCommon dateWithString:@"200901030000"];
    
    [journal insertTransaction:t];
    ASSERT_EQUAL_INT(7, [journal.entries count]);
    Transaction *tt = [journal.entries objectAtIndex:2];
    ASSERT_EQUAL(t, tt);
    ASSERT_EQUAL_INT(t.pkey, tt.pkey);
}

- (void)testReplaceTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];

    // 途中に挿入する
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.pkey = 999;
    t.asset = 3;
    t.type = 0;
    t.value = 100;
    t.date = [TestCommon dateWithString:@"200902010000"]; // last
    
    Transaction *orig = [journal.entries objectAtIndex:3];
    [orig retain];
    ASSERT_EQUAL_INT(4, orig.pkey);

    [journal replaceTransaction:orig withObject:t];

    ASSERT_EQUAL_INT(6, [journal.entries count]); // 数は変更なし
    Transaction *tt = [journal.entries objectAtIndex:5];
    //ASSERT_EQUAL(t, tt);
    ASSERT_EQUAL_INT(t.pkey, tt.pkey);

    [orig release];
}

- (void)testDeleteTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];

    Transaction *t = [journal.entries objectAtIndex:3];
    [journal deleteTransaction:t];

    ASSERT_EQUAL_INT(5, [journal.entries count]);
    t = [journal.entries objectAtIndex:2];
    ASSERT_EQUAL_INT(3, t.pkey);
    t = [journal.entries objectAtIndex:3];
    ASSERT_EQUAL_INT(5, t.pkey);
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
