//  AssetTests.m

#import "TestCommon.h"

@interface AssetTests : SenTestCase {
    Asset *asset;
}
@end

@implementation AssetTests

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWithData
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;

    asset = [ledger assetAtIndex:0];
    STAssertEquals(1, asset.pid, @"pid mismatch");
    STAssertEquals(0, asset.type, @"type mismatch");
    STAssertTrue([asset.name isEqualToString:@"Cash"], @"Asset name mismatch (%@ != Cash)", asset.name);
    STAssertEquals(0, asset.sorder, @"sorder mismatch");
    STAssertEquals(5000.0, asset.initialBalance, @"initial balance");
    
    STAssertEquals(4, [asset entryCount], @"# of entries");
    e = [asset entryAt:0];
    STAssertEquals(-100.0, e.value, @"value");
    STAssertEquals(4900.0, e.balance, @"balance");
    e = [asset entryAt:1];
    STAssertEquals(-800.0, e.value, @"value");
    STAssertEquals(4100.0, e.balance, @"balance");
    e = [asset entryAt:2];
    STAssertEquals(-100.0, e.value, @"value");
    STAssertEquals(4000.0, e.balance, @"balance");
    e = [asset entryAt:3];
    STAssertEquals(5000.0, e.value, @"value");
    STAssertEquals(9000.0, e.balance, @"balance");

    asset = [ledger assetAtIndex:1];
    STAssertEquals(2, asset.pid, @"pid");
    STAssertEquals(1, asset.type, @"asset type");
    STAssertTrue([asset.name isEqualToString:@"Bank"], @"name");
    STAssertEquals(1, asset.sorder, @"sorder");
    STAssertEquals(100000.0, asset.initialBalance, @"initial balance");

    STAssertEquals(2, [asset entryCount], @"# of entries");
    e = [asset entryAt:0];
    STAssertEquals(-5000.0, e.value, @"value");
    STAssertEquals(95000.0, e.balance, @"balance");
    e = [asset entryAt:1];
    STAssertEquals(100000.0, e.value, @"value");
    STAssertEquals(195000.0, e.balance, @"balance");

    asset = [ledger assetAtIndex:2];
    STAssertEquals(3, asset.pid, @"pid");
    STAssertEquals(2, asset.type, @"type");
    ASSERT([asset.name isEqualToString:@"Card"]);
    STAssertEquals(2, asset.sorder, @"sorder");
    STAssertEquals(-10000.0, asset.initialBalance, @"initial balance");
    
    STAssertEquals(1, [asset entryCount], @"# of entries");

    e = [asset entryAt:0];
    STAssertEquals( -2100.0, e.value, @"value");
    STAssertEquals(-12100.0, e.balance, @"balance");
}

// 支払い取引の追加
- (void)testInsertOutgo
{
    // not yet
}

// 入金取引の追加
- (void)testInsertIncome
{
    // not yet
}

// 残高調整の追加
- (void)testInsertAdjustment
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];
    
    STAssertEquals(9000.0, [asset lastBalance], @"last balance");

    // 新規エントリ
    AssetEntry *ae = [[[AssetEntry alloc] initWithTransaction:nil withAsset:asset] autorelease];

    ae.assetKey = asset.pid;
    ae.transaction.type = TYPE_ADJ;
    [ae setEvalue:10000.0];
    ae.transaction.date = [TestCommon dateWithString:@"20090201000000"];

    [asset insertEntry:ae];
    STAssertEquals(10000.0, [asset lastBalance], [NSString stringWithFormat:@"last balance (%f)", [asset lastBalance]]);
}

// 資産間移動の追加
- (void)testInsertTransfer
{
    // not yet
}

// 初期残高変更処理
- (void)testChangeInitialBalance
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];

    STAssertEquals(5000.0, [asset initialBalance], @"initial balance");
    STAssertEquals(9000.0, [asset lastBalance], @"last balance");
    
    asset.initialBalance = 0.0;
    [asset rebuild];
    STAssertEquals(0.0, [asset initialBalance], @"initial balance");

    AssetEntry *e;
    e = [asset entryAt:0];
    STAssertEquals(e.balance, -100.0, @"balance");
    e = [asset entryAt:1];
    STAssertEquals(e.balance, -900.0, @"balance");    
    e = [asset entryAt:2];
    STAssertEquals(e.balance, 4000.0, @"balance");    // 残高調整のため、balance 変化なし
    STAssertEquals(e.value, 4900.0, @"balance");
    
    STAssertEquals(9000.0, [asset lastBalance], @"last balance");
}

// 取引削除
- (void)testDeleteEntryAt
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    
    asset = [ledger assetAtIndex:0];
    STAssertEquals(5000.0, asset.initialBalance, @"initial balance");

    [asset deleteEntryAt:3]; // 資産間移動取引を削除する

    STAssertEquals(3, [asset entryCount], @"# of entries");
    STAssertEquals(5000.0, asset.initialBalance, @"initial balance");

    // 別資産の取引数が減って「いない」ことを確認(置換されているはず)
    STAssertEquals(2, [[ledger assetAtIndex:1] entryCount], @"# of trans. of other asset");

    // データベースが更新されていることを確認する
    [DataModel load];
    STAssertEquals(3, [asset entryCount], @"# of entries");
    STAssertEquals(2, [[ledger assetAtIndex:1] entryCount], @"# of entries");
}

// 先頭取引削除
-(void)testDeleteFirstEntry
{
    // not yet
}

// 古い取引削除
- (void)testDeleteOldEntriesBefore
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;
    NSDate *date;

    asset = [ledger assetAtIndex:0];
    STAssertEquals(4, [asset entryCount], @"# of entries");

    // 最初よりも早い日付の場合に何も削除されないこと
    date = [TestCommon dateWithString:@"20081231000000"];
    [asset deleteOldEntriesBefore:date];
    STAssertEquals(4, [asset entryCount], @"# of entries");    

    // 途中削除
    e = [asset entryAt:2];
    [asset deleteOldEntriesBefore:e.transaction.date];
    STAssertEquals(2, [asset entryCount], @"# of entries");    

    // 最後の日付の後で削除
    date = [TestCommon dateWithString:@"20090201000000"];
    [asset deleteOldEntriesBefore:date];
    STAssertEquals(0, [asset entryCount], [NSString stringWithFormat:@"invalid # of entries (%d)", [asset entryCount]]);

    // 残高チェック
    STAssertEquals(9000.0, asset.initialBalance, @"initial balance");

    // データベースが更新されていることを確認する
    [DataModel load];
    STAssertEquals(0, [asset entryCount], @"# of entries");
    STAssertEquals(9000.0, asset.initialBalance, @"initial balance");
}

// replace : 日付変更、種別変更なし
// replace : 通常から資産間移動に変更
// replace : 資産間移動のままだけど相手資産変更
// replace : 資産間移動のままだけど相手資産変更(dstAsset側)
// replace : 資産間移動から通常に変更
// replace : 資産間移動から通常に変更(dstAsset側)

@end
