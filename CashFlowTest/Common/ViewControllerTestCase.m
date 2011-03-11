// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "TestCommon.h"

@implementation ViewControllerTestCase

@synthesize viewController = mViewController;
@synthesize baseViewController = mBaseViewController;

static UIWindow *sKeyWindow;
- (void)setUp
{
    [super setUp];

    self.viewController = [self createViewController];
    self.baseViewController = [self createBaseViewController];

    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIWindow *window = sKeyWindow;
    if (window == nil) {
        //window = [[UIWindow alloc] init];
        window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [window makeKeyAndVisible];
        sKeyWindow = window;
    }
    
    [window addSubview:mBaseViewController.view];
    [window bringSubviewToFront:mBaseViewController.view];
}

- (void)tearDown
{
    [self.baseViewController.view removeFromSuperview];
    self.baseViewController = nil;
    self.viewController = nil;

    [super tearDown];
}    

- (UIViewController *)createViewController
{
    STFail(@"You must override createViewController!");
    return nil;
}

- (UIViewController *)createBaseViewController
{
    return self.viewController;
}

@end

////////////////////////////////////////////////////////////////////

@implementation ViewControllerWithNavBarTestCase

- (UIViewController *)createBaseViewController
{
    UINavigationController *vc = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    return vc;
}
    
@end
