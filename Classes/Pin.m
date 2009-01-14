// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Pin.h"
#import "PinVC.h"
#import "AppDelegate.h"

@implementation PinController

- (void)firstPinCheck:(UIViewController *)currentVc
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pin = [defaults stringForKey:@"PinCode"];
    if (pin == nil || pin.length == 0) return; // do nothing

    PinViewControlelr *vc = [self _getPinViewController];

    vc.title = NSLocalizedString(@"Enter PIN", @"");
    vc.enableCancel = NO;
    vc.pin = pin;
    vc.delegate = self;

    state = ENTER_FIRST_PIN;

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:nv animated:NO];
    [nv release];
}

- (void)modifyPin:(UIViewController *)currentVc
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.pin = [defaults stringForKey:@"PinCode"];

    vc = [self _getPinViewController];
    vc.delegate = self;

    if (pin != nil && pin.length > 0) {
        // check current pin
        state = ENTER_CURRENT_PIN;
        vc.title = NSLocalizedString(@"Enter PIN", @"");
        vc.pin = pin;
    } else {
        // enter 1st pin
        state = ENTER_NEW_PIN1;
        vc.title = NSLocalizedString(@"Enter new PIN", @"");
    }
        
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:nv animated:YES];
    [nv release];
}

- (BOOL)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    BOOL retry = NO;

    if (isCancel) return result;

    PinViewController *newvc = nil;

    switch (state) {
    case ENTER_FIRST_PIN:
        if (![vc.value isEqualToString:self.pin]) {
            // invalid pin
            UIAlertView *v = [[UIAlertView alloc]
                                 initWithTitle:@"Invalid PIN"
                                 message:NSLocalizedString(@"PIN code does not match.", @"")
                                 delegate:nil
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles:nil];
            retry = YES;
        }
        break;

    case ENTER_CURRENT_PIN:
        state = ENTER_NEW_PIN1;
        newvc = [self _getPinViewController];        
        newvc.title = NSLocalizedString(@"Enter new PIN", @"");
        break;

    case ENTER_NEW_PIN1:
        newPin = vc.value;
        state = ENTER_NEW_PIN2;
        newvc = [self _getPinViewController];        
        newvc.title = NSLocalizedString(@"Retype new PIN", @"");
        break;

    case ENTER_NEW_PIN2:
        if ([vc.value isEqualToString:newPin]) {
            // set new pin
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:newPin forKey:@"PinCode"];
        } else {
            // invalid pin
            UIAlertView *v = [[UIAlertView alloc]
                                 initWithTitle:@"Invalid PIN"
                                 message:NSLocalizedString(@"PIN code does not match.", @"")
                                 delegate:nil
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles:nil];
        }
        break;
    }

    if (retry) {
        return;
    }

    // close current view if needed
    if ([vc.navigationController.rootViewController != vc]) {
        [vc popViewControllerAnimated:NO];
    }

    // show new vc if needed
    if (newvc) {
        newvc.delegate = self;
        [vc.navigationController pushViewController:newvc animated:YES];
    }

    // all done?
    if (state == ENTER_FIRST_PIN || state == ENTER_NEW_PIN2) {
        [vc.navigationController dismissModalViewControllerAnimated:YES];
    }

    return result;
}


- (PinViewController *)_getPinViewController
{
    PinViewController *vc = [[PinViewController alloc] initWithNibName:@"PinView.xib" bundle:nil];
    [vc autorelease];
    return vc;
}

- (void)dismiss
{
    if (self.navigationController.rootViewController == self) {
        [self.navigationController dismissModalViewControllerAnimated:NO];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
