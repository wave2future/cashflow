// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface TransactionTest : SenTestCase {
    Transaction *transaction;
}
@end

@implementation TransactionTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    [DataModel instance];
}

- (void)tearDown
{
    [super tearDown];
}

// 日付のアップグレードテスト (ver 3.2.1 -> 3.3 へのアップグレード)
- (void)testMigrateDate
{
    Database *db = [Database instance];
    
    // 旧バージョンのフォーマットでデータを作成
    [db exec:@"INSERT INTO Transactions VALUES(NULL, 0, 0, 200901011256, 0, 0, 0, '', '');"];
    
    // Migrate 実行
    [DataModel finalize];
    [DataModel instance];
    
    // チェック
    dbstmt *stmt = [db prepare:@"SELECT date FROM Transactions;"];
    STAssertTrue([stmt step] == SQLITE_ROW, @"select failed.");
    STAssertTrue([[stmt colString:0] isEqualToString:@"20090101125600"], @"date migration failed");
}

@end
