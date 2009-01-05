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


#import "ExportVC.h"
#import "AppDelegate.h"

@implementation ExportVC

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Localization
    [self setTitle:NSLocalizedString(@"Export", @"")];

    formatLabel.text = NSLocalizedString(@"Data format", @"");
    [formatControl setTitle:NSLocalizedString(@"OFX", @"") forSegmentAtIndex:1];

    rangeLabel.text = NSLocalizedString(@"Export data within", @"");
    [rangeControl setTitle:NSLocalizedString(@"7 days", @"") forSegmentAtIndex:0];
    [rangeControl setTitle:NSLocalizedString(@"30 days", @"") forSegmentAtIndex:1];
    [rangeControl setTitle:NSLocalizedString(@"90 days", @"") forSegmentAtIndex:2];
    [rangeControl setTitle:NSLocalizedString(@"All", @"") forSegmentAtIndex:3];
    
    methodLabel.text = NSLocalizedString(@"Export method", @"");
    [methodControl setTitle:NSLocalizedString(@"Mail", @"") forSegmentAtIndex:0];
    
    NSString *exportString = NSLocalizedString(@"Export", @"");
    [exportButton setTitle:exportString forState:UIControlStateNormal];
    [exportButton setTitle:exportString forState:UIControlStateHighlighted];

    UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
    [exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exportButton setBackgroundImage:bg forState:UIControlStateNormal];
	
#ifdef FREE_VERSION
    formatLabel.hidden = YES;
    formatControl.hidden = YES;
    methodLabel.hidden = YES;
    methodControl.hidden = YES;
#endif

    //noteTextView.font = [UIFont systemFontOfSize:12.0];

    // load defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    formatControl.selectedSegmentIndex = [defaults integerForKey:@"exportFormat"];
    rangeControl.selectedSegmentIndex = [defaults integerForKey:@"exportRange"];
    methodControl.selectedSegmentIndex = [defaults integerForKey:@"exportMethod"];	
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[NSNumber numberWithInt:formatControl.selectedSegmentIndex] 
              forKey:@"exportFormat"];
    [defaults setObject:[NSNumber numberWithInt:rangeControl.selectedSegmentIndex] 
              forKey:@"exportRange"];
    [defaults setObject:[NSNumber numberWithInt:methodControl.selectedSegmentIndex] 
              forKey:@"exportMethod"];
    [defaults synchronize];
}

- (IBAction)doExport
{
    //[theDataModel saveToStorage]; // for safety...
	
    int range;
    switch (rangeControl.selectedSegmentIndex) {
    case 0:
        range = 7;
        break;
    case 1:
        range = 30;
        break;
    case 2:
        range = 90;
        break;
    default:
        range = -1;
        break;
    }
	
    NSDate *date = nil;
    if (range > 0) {
        date = [[[NSDate alloc] init] autorelease];
        date = [date addTimeInterval:(- range * 24.0 * 60 * 60)];
    }
	
    BOOL result;
    ExportBase *ex;
    UIAlertView *v;

    switch (formatControl.selectedSegmentIndex) {
    case 0:
    default:
        if (csv == nil) {
            csv = [[ExportCsv alloc] init];
        }
        ex = csv;
        break;

#ifndef FREE_VERSION
    case 1:
        if (ofx == nil) {
            ofx = [[ExportOfx alloc] init];
        }
        ex = ofx;
        break;
#endif
    }
    ex.firstDate = date;
	
    switch (methodControl.selectedSegmentIndex) {
    case 0:
    default:
        result = [ex sendMail];
        break;
#ifndef FREE_VERSION
    case 1:
        result = [ex sendWithWebServer];
        break;
#endif
    }
	
    if (!result) {
        v = [[UIAlertView alloc] 
                initWithTitle:NSLocalizedString(@"No data", @"")
                message:NSLocalizedString(@"No data to be exported.", @"")
                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [v show];
        [v autorelease];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
