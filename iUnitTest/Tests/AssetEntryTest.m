// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "AssetEntryTest.h"

@implementation AssetEntryTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark -
#pragma mark Helpers


#pragma mark -
#pragma mark Tests

// transaction 指定なし
- (void)testAllocNew
{
    AssetEntry *e;
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pid = 999;

    e = [[[AssetEntry alloc] initWithTransaction:nil withAsset:a] autorelease];

    ASSERT(e.assetKey == 999);
    ASSERT(e.value == 0.0);
    ASSERT(e.balance == 0.0);
    ASSERT(e.transaction.asset == 999);
    ASSERT(![e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    ASSERT(e.transaction.value == 200.0);
}

// transaction 指定あり、通常
- (void)testAllocExisting
{
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pid = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.type = TYPE_TRANSFER;
    t.asset = 111;
    t.dst_asset = 222;
    t.value = 10000.0;

    AssetEntry *e = [[[AssetEntry alloc] initWithTransaction:t withAsset:a] autorelease];

    ASSERT(e.assetKey == 111);
    ASSERT(e.value == 10000.0);
    ASSERT(e.balance == 0.0);
    ASSERT(e.transaction.asset == 111);
    ASSERT(![e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    ASSERT(e.transaction.value == 200.0);
}

// transaction 指定あり、逆
- (void)testAllocExistingReverse
{
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pid = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.type = TYPE_TRANSFER;
    t.asset = 222;
    t.dst_asset = 111;
    t.value = 10000.0;

    AssetEntry *e = [[[AssetEntry alloc] initWithTransaction:t withAsset:a] autorelease];

    ASSERT(e.assetKey == 111);
    ASSERT(e.value == -10000.0);
    ASSERT(e.balance == 0.0);
    ASSERT(e.transaction.asset == 222);
    ASSERT([e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    ASSERT(e.transaction.value == -200.0);
}

- (void)testEvalueNormal
{
    Asset *a = [[[Asset alloc] init] autorelease];
    a.pid = 111;
    Transaction *t = [[[Transaction alloc] init] autorelease];
    t.asset = 111;
    t.dst_asset = -1;

    AssetEntry *e = [[[AssetEntry alloc] initWithTransaction:t withAsset:a] autorelease];
    e.balance = 99999.0;

    t.type = TYPE_INCOME;
    e.value = 10000;
    ASSERT(e.evalue == 10000);
    e.evalue = 20000;
    ASSERT(e.transaction.value == 20000);    

    t.type = TYPE_OUTGO;
    e.value = 10000;
    ASSERT(e.evalue == -10000);
    e.evalue = 20000;
    ASSERT(e.transaction.value = -20000);

    t.type = TYPE_ADJ;
    e.balance = 99999;
    ASSERT([e evalue] == 99999);
    e.evalue = 88888;
    ASSERT(e.balance == 88888);

    t.type = TYPE_TRANSFER;
    e.value = 10000;
    ASSERT([e evalue] == -10000);
    e.evalue = 20000;
    ASSERT(e.transaction.value == -20000);
}

@end
