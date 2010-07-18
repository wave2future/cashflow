//
//  AppTests.m
//  CashFlow
//
//  Created by 村上 卓弥 on 10/05/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppTests.h"


@implementation AppTests

- (void) testAppDelegate {
    NSLog(@"testAppDelegate");

    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}    

@end
