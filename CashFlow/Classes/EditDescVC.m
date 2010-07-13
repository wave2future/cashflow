// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2010, Takuya Murakami, All rights reserved.

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
#import "DescLRUManager.h"

@implementation EditDescViewController

@synthesize delegate, description, category;

- (id)init
{
    self = [super initWithNibName:@"EditDescView" bundle:nil];
    if (self) {
        category = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;  // AdHoc : 480 にすると横画面の時に下に出てしまい、文字入力ができない
        self.contentSizeForViewInPopover = s;
    }
    
    self.title = NSLocalizedString(@"Name", @"Description");

    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction)] autorelease];

    // ここで textField を生成する
    textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 12, 300, 24)];
    textField.placeholder = NSLocalizedString(@"Description", @"");
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [textField addTarget:self action:@selector(onTextChange:)
               forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)onTextChange:(id)sender {
    // dummy func must exist for textFieldShouldReturn event to be called
}

- (void)dealloc
{
    [tableView release];
    [textField release];
    [description release];
    [super dealloc];
}

// 表示前の処理
//  処理するトランザクションをロードしておく
- (void)viewWillAppear:(BOOL)animated
{
    textField.text = self.description;
    [super viewWillAppear:animated];

    descArray = [DescLRUManager getDescLRUStrings:category];
    [descArray retain];

    // キーボードを消す ###
    [textField resignFirstResponder];

    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [descArray release];
}

- (void)doneAction
{
    self.description = textField.text;
    [delegate editDescViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

// キーボードを消すための処理
- (BOOL)textFieldShouldReturn:(UITextField*)t
{
    [t resignFirstResponder];
    return YES;
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1; // テキスト入力欄
    }

    return [descArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"] autorelease];

            [cell.contentView addSubview:textField];
        }
    } 
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descCell"] autorelease];
        }
        cell.textLabel.text = [descArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 1) {
        NSString *desc = [descArray objectAtIndex:indexPath.row];
        textField.text = desc;
        [self doneAction];
    }
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
