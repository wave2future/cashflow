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


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

@class TransactionViewController;
@class EditValueViewController;

@protocol EditValueViewListener
- (void)editValueViewChanged:(EditValueViewController *)vc;
@end

@interface EditValueViewController : UIViewController {
    NSMutableString *numstr;

    IBOutlet UILabel *numLabel;
    IBOutlet UIButton *button_Clear;
    IBOutlet UIButton *button_BS;
    IBOutlet UIButton *button_inv;
    IBOutlet UIButton *button_Period;
    IBOutlet UIButton *button_0;
    IBOutlet UIButton *button_1;
    IBOutlet UIButton *button_2;
    IBOutlet UIButton *button_3;
    IBOutlet UIButton *button_4;
    IBOutlet UIButton *button_5;
    IBOutlet UIButton *button_6;
    IBOutlet UIButton *button_7;
    IBOutlet UIButton *button_8;
    IBOutlet UIButton *button_9;

    id<EditValueViewListener> listener;
    double value;
}

@property(nonatomic,assign) id<EditValueViewListener> listener;
@property(nonatomic,assign) double value;

- (IBAction)onNumButtonDown:(id)sender;
- (IBAction)onNumButtonPressed:(id)sender;

// private method
- (void)doneAction;
- (void)updateLabel;

@end
