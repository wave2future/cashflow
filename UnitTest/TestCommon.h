// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "GTMSenTestCase.h"
#import "Database.h"
#import "DataModel.h"

#define TEST(x) STAssertTrue(x, NULL)


@interface TestCommon : NSObject
{
}


+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end

