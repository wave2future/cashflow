//
//  HogeTest.m
//  CashFlow
//
//  Created by 村上 卓弥 on 09/04/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HogeTest.h"


@implementation HogeTest

#if TARGET_IPHONE_SIMULATOR     // all "code under test" must be linked into the Unit Test bundle

- (void) testMath {

    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );

}

#else                           // all "code under test" is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIAppliation failed to find the AppDelegate");
    
}

#endif


@end
