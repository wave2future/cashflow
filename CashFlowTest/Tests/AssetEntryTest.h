//
//  AssetEntryTest.h
//  CashFlowTest
//
//  Created by 村上 卓弥 on 09/04/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// See Also: http://developer.apple.com/documentation/developertools/Conceptual/UnitTesting/UnitTesting.html
//           file:///Developer/Library/Frameworks/SenTestingKit.framework/Resources/IntroSenTestingKit.html


#import <UIKit/UIKit.h>
#import "IUTTest.h"
//#import "application_headers" as required


@interface AssetEntryTest : IUTTest {

}

#if TARGET_IPHONE_SIMULATOR
- (void) testMath;              // simple standalone test
#else
- (void) testAppDelegate;       // simple test on application
#endif

@end
