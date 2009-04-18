// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import "IUTTest.h"
#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET ASSERT_FAIL(@"not yet")

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end

