// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <SenTestingKit/SenTestingKit.h>

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET STFail(@"not yet")

// IUTest compatibility
#undef ASSERT
#define ASSERT(x) STAssertTrue(x, @"")
#define ASSERT_EQUAL_INT(a, b) STAssertEquals(a, b, @"")
#define ASSERT_EQUAL_DOUBLE(a, b) STAssertEquals(a, b, @"")

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)deleteDatabase;
+ (BOOL)installDatabase:(NSString *)sqlFileName;

@end

