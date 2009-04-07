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


#import "TransactionVC.h"
#import "EditDescVC.h"
#import "AppDelegate.h"

@implementation EditDescViewController

@synthesize listener, description, category;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        category = -1;
    }
    return self;
}

-(void)onTextChange:(id)sender {
    // dummy func must exist for textFieldShouldReturn event to be called
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Name", @"Description");
    textField.placeholder = NSLocalizedString(@"Name", @"Description");
	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];

    [textField addTarget:self action:@selector(onTextChange:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)dealloc
{
    [description release];
    [super dealloc];
}

// 表示前の処理
//  処理するトランザクションをロードしておく
- (void)viewWillAppear:(BOOL)animated
{
    textField.text = self.description;
    [super viewWillAppear:animated];

    descArray = [theDataModel descLRUWithCategory:category];
    [descArray retain];
    [descArray insertObject:@"" atIndex:0];  // dummy entry
    [picker reloadAllComponents];

    // キーボードを消す ###
    [textField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [descArray release];
}

- (void)doneAction
{
    self.description = textField.text;
    [listener editDescViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

// キーボードを消すための処理
- (BOOL)textFieldShouldReturn:(UITextField*)t
{
    [t resignFirstResponder];
    return YES;
}

// Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)v
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)v numberOfRowsInComponent:(NSInteger)c
{
    return [descArray count];
}

- (NSString *)pickerView:(UIPickerView *)v titleForRow:(NSInteger)row forComponent:(NSInteger)comp
{
    return [descArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)v didSelectRow:(NSInteger)row inComponent:(NSInteger)comp
{
    textField.text = [descArray objectAtIndex:row];
}

@end
