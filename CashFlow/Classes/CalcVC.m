// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2009, Takuya Murakami, All rights reserved.

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
#import <math.h>

#import "TransactionVC.h"
#import "CalcVC.h"
#import "AppDelegate.h"

@implementation CalculatorViewController

@synthesize delegate, value;

- (id)init
{
    self = [super initWithNibName:@"CalculatorView" bundle:nil];
    if (self) {
        [self allClear];
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
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    [delegate calculatorViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)allClear
{
    value = 0.0;
    state = ST_DISPLAY;
    decimalPlace = 0;
    storedOperator = OP_NONE;
    storedValue = 0.0;
}

- (IBAction)onButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onButtonPressed:(id)sender
{
    if (sender == button_Clear) {
        [self allClear];
        [self updateLabel];
        return;
    }

    if (sender == button_BS) {
        // バックスペース
        if (state == ST_INPUT) {
            if (decimalPlace > 0) {
                decimalPlace--;
                [self roundInputValue]; // TBD
            } else {
                value = floor(value / 10);
            }

            [self updateLabel];
        }
        return;
    }

    if (sender == button_inv) {
        value = -value;
        [self updateLabel];
        return;
    }

    // 演算子入力
    calcOperator op = OP_NONE;
    if (sender == button_Plus) op = OP_PLUS;
    else if (sender == button_Minus) op = OP_MINUS;
    else if (sender == button_Multiply) op = OP_MULTIPLY;
    else if (sender == button_Divide) op = OP_DIVIDE;
    else if (sender == button_Equal) op = OP_EQUAL;

    if (op != OP_NONE) {
        [self onInputOperator:op];
        return;
    }
		
    // 数値入力
    int num = -99;
    if (sender == button_0) num = 0;
    else if (sender == button_1) num = 1;
    else if (sender == button_2) num = 2;
    else if (sender == button_3) num = 3;
    else if (sender == button_4) num = 4;
    else if (sender == button_5) num = 5;
    else if (sender == button_6) num = 6;
    else if (sender == button_7) num = 7;
    else if (sender == button_8) num = 8;
    else if (sender == button_9) num = 9;
    else if (sender == button_Period) num = -1;
    
    if (num != -99) {
        [self onInputNumeric:num];
    }
}

- (void)onInputOperator:(calcOperator)op
{
    if (state == ST_INPUT || op == OP_EQUAL) {
        // 数値入力中に演算ボタンが押された場合、
        // あるいは = が押された場合 (5x= など)
        // メモリしてある式を計算する
        switch (storedOperator) {
        case OP_PLUS:
            value = storedValue + value;
            break;

        case OP_MINUS:
            value = storedValue - value;
            break;

        case OP_MULTIPLY:
            value = storedValue * value;
            break;

        case OP_DIVIDE:
            if (value == 0.0) {
                // divided by zero error
                value = 0.0;
            } else {
                value = storedValue / value;
            }
            break;
        }

        // 表示中の値を記憶
        storedValue = value;

        // 表示状態に遷移
        state = ST_DISPLAY;
        [self updateLabel];
    }
        
    // 表示中の場合は、operator を変えるだけ

    if (op == OP_EQUAL) {
        // '=' を押したら演算終了
        storedOperator = OP_NONE;
    } else {
        storedOperator = op;
    }
}

- (void)onInputNumeric:(int)num
{
    if (state == ST_DISPLAY) {
        state = ST_INPUT; // 入力状態に遷移

        storedValue = value;

        value = 0; // 表示中の値をリセット
        decimalPlace = 0;
    }

    if (num == -1) { // 小数点
        if (decimalPlace == 0) {
            decimalPlace = 1;
        }
    }
    else { // 数値
        if (decimalPlace == 0) {
            // 整数入力
            value = value * 10 + num;
        } else {
            // 小数入力
            double v = (double)num * pow(10, -decimalPlace);
            value += v;

            decimalPlace++;
        }
    }
         
    [self updateLabel];
}

- (void)roundInputValue
{
    double v;
    BOOL isMinus = NO;

    v = value;
    if (v < 0.0) {
        isMinus = YES;
        v = -v;
    }

    value = floor(v);
    v -= value; // 小数点以下

    if (decimalPlace >= 2) {
        // decimalPlace 桁以下を落とす
        double k = pow(10, decimalPlace - 1);
        v = floor(v * k) / (double)k;
        value += v;
    }

    if (isMinus) {
        value = -value;
    }
}

- (void)updateLabel
{
    NSMutableString *numstr = [[NSMutableString alloc] initWithCapacity:16];

    // 表示すべき小数点以下の桁数を求める
    int dp;
    double vtmp;

    switch (state) {
    case ST_INPUT:
        dp = decimalPlace - 1;
        break;

    case ST_DISPLAY:
        dp = -1;
        vtmp = value;
        if (vtmp < 0) vtmp = -vtmp;
        vtmp -= (int)vtmp;
        for (int i = 1; i <= 6; i++) {
            vtmp *= 10;
            if ((int)vtmp % 10 != 0) {
                dp = i;
            }
        }
        break;
    }

    if (dp <= 0) {
        [numstr appendFormat:@"%.0f", value];
    } else {
        NSString *fmt = [NSString stringWithFormat:@"%%.%df", dp];
        [numstr appendFormat:fmt, value];
    }

    // カンマを３桁ごとに挿入
    NSRange range = [numstr rangeOfString:@"."];
    int i;
    if (range.location == NSNotFound) {
        i = numstr.length;
    } else {
        i = range.location;
    }

    for (i -= 3 ; i > 0; i -= 3) {
        if (value < 0 && i <= 1) break;
        [numstr insertString:@"," atIndex:i];
    }
	
    numLabel.text = numstr;
    [numstr release];
}

@end
