// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "DescLRUManager.h"

@interface DescLRUManagerTests : SenTestCase {
    DescLRUManager *manager;
}
@end

@implementation DescLRUManagerTests

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    DataModel *dm = [DataModel instance]; // re-create DataModel
}

- (void)tearDown
{
    [super tearDown];
}

- (void)setupTestData
{
    Database *db = [Database instance];
     
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"201001010000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"201001010001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"201001010002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"201001010003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"201001010004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"201001010005"]];
}

- (void) testInit {
    NSMutableArray *ary = [DescLRUManager getDescLRUs:-1];
    STAssertTrue([ary count] == 0, @"LRU count must be 0.");
}

- (void)testAnyCategory
{
    [self setupTestData];
    
    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUStrings:-1];
    STAssertTrue([ary count] == 6, @"LRU count must be 6.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test5"], @"first entry");
    s = [ary objectAtIndex:5];
    STAssertTrue([s isEqualToString:@"test0"], @"last entry");
}

- (void)testCategory
{
    [self setupTestData];

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUStrings:1];
    STAssertTrue([ary count] == 2, @"LRU count must be 2.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test4"], @"first entry");
    s = [ary objectAtIndex:1];
    STAssertTrue([s isEqualToString:@"test1"], @"last entry");
}

- (void)testUpdateSameCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:1]; // same name/cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUStrings:1];
    STAssertTrue([ary count] == 2, @"LRU count must be 2.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test1"], @"first entry");
    s = [ary objectAtIndex:1];
    STAssertTrue([s isEqualToString:@"test4"], @"last entry");
}

- (void)testUpdateOtherCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:2]; // same name/other cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUStrings:1];
    STAssertTrue([ary count] == 1, @"LRU count must be 2.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test4"], @"first entry");

    ary = [DescLRUManager getDescLRUStrings:2];
    STAssertTrue([ary count] == 3, @"LRU count must be 3.");
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test1"], @"new entry");
}

@end
