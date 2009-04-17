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


#import <AudioToolbox/AudioToolbox.h>

#import "TransactionVC.h"
#import "EditValueVC.h"
#import "AppDelegate.h"

@implementation EditValueViewController

@synthesize listener, value;

- (id)init
{
    self = [super initWithNibName:@"EditValueView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Amount", @"金額");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];

    numstr = [[NSMutableString alloc] initWithCapacity:16];
}

- (void)dealloc
{
    [numstr release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    NSString *n;
    if (value == 0.0) {
        n = @"";
    } else if (value - (int)value == 0.0) {
        n = [NSString stringWithFormat:@"%.0f", value];
    } else {
        n = [NSString stringWithFormat:@"%.2f", value];
    }
    [numstr setString:n];
	
    [self updateLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    value = [numstr doubleValue];
    [listener editValueViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNumButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onNumButtonPressed:(id)sender
{
    NSString *ch = nil;
    int len;
	
    if (sender == button_Clear) {
        [numstr setString:@""];
    }
    else if (sender == button_BS) {
        // バックスペース
        len = numstr.length;
        if (len > 0) {
            [numstr deleteCharactersInRange:NSMakeRange(len-1, 1)];
            if ([numstr isEqualToString:@"0"]) {
                [numstr setString:@""];
            }
            if ([numstr isEqualToString:@"-"]) {
                [numstr setString:@""];
            }
        }
    }
    else if (sender == button_Period) {
        // ピリオド追加
        if ([numstr rangeOfString:@"."].location == NSNotFound) {
            ch = @".";
        }
    }
    else if (sender == button_inv) {
        // 符号反転
        if ([numstr length] == 0) {
            // do nothing
        } else if ([[numstr substringToIndex:1] isEqualToString:@"-"]) {
            [numstr deleteCharactersInRange:NSMakeRange(0, 1)];
        } else {
            [numstr insertString:@"-" atIndex:0];
        }
    }
		
    else if (sender == button_0) ch = @"0";
    else if (sender == button_1) ch = @"1";
    else if (sender == button_2) ch = @"2";
    else if (sender == button_3) ch = @"3";
    else if (sender == button_4) ch = @"4";
    else if (sender == button_5) ch = @"5";
    else if (sender == button_6) ch = @"6";
    else if (sender == button_7) ch = @"7";
    else if (sender == button_8) ch = @"8";
    else if (sender == button_9) ch = @"9";

    if (ch != nil) {
        if ([numstr isEqualToString:@""]) {
            // special case
            if ([ch isEqualToString:@"0"]) {
                // do nothing
            } else if ([ch isEqualToString:@"."]) {
                [numstr setString:@"0."];
            } else {
                [numstr appendString:ch];
            }
        } else {
            [numstr appendString:ch];
        }
    }
	
    [self updateLabel];
}

- (void)updateLabel
{
    if (numstr.length == 0) {
        numLabel.text = @"0";
        return;
    }

    NSMutableString *tmp = [numstr mutableCopy];
    BOOL isMinus = NO;
    if ([[tmp substringToIndex:1] isEqualToString:@"-"]) {
        isMinus = YES;
    }
		
    // ピリオドの位置を探す
    NSRange range = [tmp rangeOfString:@"."];
    int i;
    if (range.location == NSNotFound) {
        i = tmp.length;
    } else {
        i = range.location;
    }

    // カンマを３桁ごとに挿入
    for (i -= 3 ; i > 0; i -= 3) {
        if (isMinus && i <= 1) break;
        [tmp insertString:@"," atIndex:i];
    }
	
    numLabel.text = tmp;
    [tmp release];
}

@end
