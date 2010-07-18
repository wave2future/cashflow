// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <SenTestingKit/SenTestingKit.h>
#import "IUTTest.h"

#import "UINavigationBarBasedTest.h"
#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET ASSERT_FAIL(@"not yet")

// Simplefied macros
#if 1
#define Assert(x) ASSERT(x)
#define AssertNil(x) ASSERT_FAIL(x)
#define AssertNotNil(x) ASSERT_NOT_NIL(x)
#define AssertEqual(a, b) ASSERT_EQUAL(a, b)
#define AssertEqualObjects(a, b) ASSERT_SAME(a, b)
#define AssertEqualInt(a, b) ASSERT_EQUAL_INT(a, b)
#define AssertEqualDouble(a, b) ASSERT_EQUAL_DOUBLE(a, b)

#else // SenTestingKit
#define Assert(x) STAssertTrue(x, @"")
#define AssertNil(x) STAssertNil(x, @"")
#define AssertNotNil(x) STAssertNotNil(x, @"")
#define AssertEqualObjects(a, b) STAssertEqualObjects(a, b, @"")
#define AssertEqualInt(a, b) STAssertEquals((int)(a), (int)(b), @"")
#define AssertEqualDouble(a, b) STAssertEquals((double)(a), (double)(b), @"")
#endif

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)deleteDatabase;
+ (BOOL)installDatabase:(NSString *)sqlFileName;

@end

