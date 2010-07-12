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
    [TestCommon deleteDatabase];
}

- (void)tearDown
{
}

- (void) testInit {
    NSMutableArray *ary = [DescLRUManager getDescLRUs:-1];
    STAssertTrue([ary count] == 0, @"LRU count must be 0.");
}

- (void)testAnyCategory
{
    [DescLRUManager addDescLRU:@"test0" category:0];
    [DescLRUManager addDescLRU:@"test1" category:1];
    [DescLRUManager addDescLRU:@"test2" category:2];
    [DescLRUManager addDescLRU:@"test3" category:0];
    [DescLRUManager addDescLRU:@"test4" category:1];
    [DescLRUManager addDescLRU:@"test5" category:2];

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:-1];
    STAssertTrue([ary count] == 6, @"LRU count must be 6.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test5"], @"first entry");
    s = [ary objectAtIndex:5];
    STAssertTrue([s isEqualToString:@"test0"], @"last entry");
}

- (void)testCategory
{
    [DescLRUManager addDescLRU:@"test0" category:0];
    [DescLRUManager addDescLRU:@"test1" category:1];
    [DescLRUManager addDescLRU:@"test2" category:2];
    [DescLRUManager addDescLRU:@"test3" category:0];
    [DescLRUManager addDescLRU:@"test4" category:1];
    [DescLRUManager addDescLRU:@"test5" category:2];

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    STAssertTrue([ary count] == 2, @"LRU count must be 2.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test4"], @"first entry");
    s = [ary objectAtIndex:1];
    STAssertTrue([s isEqualToString:@"test1"], @"last entry");
}

- (void)testUpdate
{
    [DescLRUManager addDescLRU:@"test0" category:0];
    [DescLRUManager addDescLRU:@"test1" category:1];
    [DescLRUManager addDescLRU:@"test2" category:2];
    [DescLRUManager addDescLRU:@"test3" category:0];
    [DescLRUManager addDescLRU:@"test4" category:1];
    [DescLRUManager addDescLRU:@"test5" category:2];

    [DescLRUManager addDescLRU:@"test1" category:1]; // same name/cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    STAssertTrue([ary count] == 2, @"LRU count must be 2.");

    NSString *s;
    s = [ary objectAtIndex:0];
    STAssertTrue([s isEqualToString:@"test1"], @"first entry");
    s = [ary objectAtIndex:1];
    STAssertTrue([s isEqualToString:@"test4"], @"last entry");
}

@end
