// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "GTMSenTestCase.h"
#import "Database.h"
#import "DataModel.h"

@interface TestCommon : NSObject
{
}


+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end

