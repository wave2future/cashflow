// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import "IUTTest.h"
#import "Database.h"
#import "DataModel.h"

#define TEST(x) ASSERT(x)

@interface TestCommon : NSObject
{
}


+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end

