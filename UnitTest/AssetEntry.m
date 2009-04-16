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
- (void)testAllocNew
{
    AssetEntry *e = [[[AssetEntry alloc] init] autorelease];
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pkey = 999;

    [e setAsset:a transaction:nil];

    STAssertTrue(e.asset == 999, nil);
    STAssertTrue(e.value == 0.0, nil);
    STAssertTrue(e.balance == 0.0, nil);
    STAssertTrue(e.transaction.asset == 999, nil);
    STAssertTrue(![e isDstAsset], nil);

    // 値設定
    e.value = 200.0;
    STAssertTrue(e.transaction.value == 200.0, nil);
}

// transaction 指定あり、通常
- (void)testAllocExisting
{
    AssetEntry *e = [[[AssetEntry alloc] init] autorelease];
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pkey = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.type = TYPE_TRANSFER;
    t.asset = 111;
    t.dst_asset = 222;
    t.value = 10000.0;

    [e setAsset:a transaction:t];

    STAssertTrue(e.asset == 111, nil);
    STAssertTrue(e.value == 10000.0, nil);
    STAssertTrue(e.balance == 0.0, nil);
    STAssertTrue(e.transaction.asset == 111, nil);
    STAssertTrue(![e isDstAsset], nil);

    // 値設定
    e.value = 200.0;
    STAssertTrue(e.transaction.value == 200.0, nil);
}

// transaction 指定あり、逆
- (void)testAllocExistingReverse
{
    AssetEntry *e = [[[AssetEntry alloc] init] autorelease];
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pkey = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.type = TYPE_TRANSFER;
    t.asset = 222;
    t.dst_asset = 111;
    t.value = 10000.0;

    [e setAsset:a transaction:t];

    STAssertTrue(e.asset == 111, nil);
    STAssertTrue(e.value == -10000.0, nil);
    STAssertTrue(e.balance == 0.0, nil);
    STAssertTrue(e.transaction.asset == 222, nil);
    STAssertTrue([e isDstAsset], nil);

    // 値設定
    e.value = 200.0;
    STAssertTrue(e.transaction.value == -200.0, nil);
}

- (void)testEvalueNormal
{
    AssetEntry *e = [[[AssetEntry alloc] init] autorelease];
    e.balance = 99999.0;
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pkey = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.asset = 111;
    t.dst_asset = -1;
    [e setAsset:a transaction:t];

    t.type = TYPE_INCOME;
    e.value = 10000;
    STAssertTrue(e.evalue == 10000, nil);
    e.evalue = 20000;
    STAssertTrue(t.value == 20000, nil);    

    t.type = TYPE_OUTGO;
    e.value = 10000;
    STAssertTrue(e.evalue == -10000, nil);
    e.evalue = 20000;
    STAssertTrue(t.value = -20000, nil);

    t.type = TYPE_ADJ;
    e.balance = 99999;
    STAssertTrue([e evalue] == 99999, nil);
    e.evalue = 88888;
    STAssertTrue(e.balance == 88888, nil);

    t.type = TYPE_TRANSFER;
    e.value = 10000;
    STAssertTrue([e evalue] == -10000, nil);
    e.evalue = 20000;
    STAssertTrue(t.value == -20000, nil);

}

@end
