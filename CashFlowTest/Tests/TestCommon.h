// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import "IUTTest.h"
#import "Database.h"
#import "DataModel.h"

#define NOTYET ASSERT_FAIL(@"not yet")

@interface TestCommon : NSObject
{
}


+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end

