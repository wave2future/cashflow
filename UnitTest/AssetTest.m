// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface AssetTest : SenTestCase {
    Asset *asset;
}
@end

@implementation AssetTest

- (void)setUp
{
    [TestCommon deleteDatabase];
}

- (void)tearDown
{
}

@end
