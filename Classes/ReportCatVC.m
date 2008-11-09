// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
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
  "AS IS" ANDY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
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

#import "AppDelegate.h"
#import "DataModel.h"
#import "ReportCatVC.h"

@implementation CatReportViewController

@synthesize report;

- (void)viewDidLoad
{
	[super viewDidLoad];
    //self.title = NSLocalizedString(@"Report", @"");
}

- (void)dealloc
{
    if (report) {
        [report release];
    }
	//[dateFormatter release];
    [super dealloc];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [report.catReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellid = @"catReportCell";

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
	UILabel *nameLabel, *valueLabel;

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellid] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
		nameLabel.tag = 1;
		nameLabel.font = [UIFont systemFontOfSize: 16.0];
		nameLabel.textColor = [UIColor grayColor];
		nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:nameLabel];

		valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(180, 20, 130, 22)] autorelease];
		valueLabel.tag = 2;
		valueLabel.font = [UIFont systemFontOfSize: 16.0];
		valueLabel.textAlignment = UITextAlignmentRight;
		valueLabel.textColor = [UIColor redColor];
		valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:valueLabel];
	} else {
		nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
		valueLabel = (UILabel *)[cell.contentView viewWithTag:2];
	}

	CatReport *cr = [report.catReports objectAtIndex:indexPath.row];
	nameLabel.text = [theDataModel.categories categoryStringWithKey:cr.catkey];
	valueLabel.text = [DataModel currencyString:cr.value];
	return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
