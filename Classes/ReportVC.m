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

#import "ReportVC.h"

@implementation ReportViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title = NSLocalizedString(@"Report", @"");

	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy/MM"];
}

- (void)dealloc
{
    if (reports) {
        [reports release];
    }
	[dateFormatter release];
    [super dealloc];
}

- (void)generateReport
{
    if (reports == nil) {
        reports = [[Reports alloc] init];
    }
    [reports generate];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [reports.reports count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Report *report = [reports.reports objectAtIndex:[reports.reports count] - indexPath.row - 1];

	UITableViewCell *cell = [self reportCell:report];
	return cell;
}

- (UITableViewCell *)reportCell:(Report*)report
{
	NSString *cellid = @"reportCell";

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
	UILabel *dateLabel, *incomeLabel, *outgoLabel;

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellid] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
		dateLabel.tag = 0;
		dateLabel.font = [UIFont systemFontOfSize: 18.0];
		dateLabel.textColor = [UIColor blackColor];
		dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:dateLabel];

		incomeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(180, 0, 130, 22)] autorelease];
		incomeLabel.tag = 1;
		incomeLabel.font = [UIFont systemFontOfSize: 17.0];
		incomeLabel.textAlignment = UITextAlignmentRight;
		incomeLabel.textColor = [UIColor blueColor];
		incomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:incomeLabel];

		outgoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(180, 24, 130, 22)] autorelease];
		outgoLabel.tag = 2;
		outgoLabel.font = [UIFont systemFontOfSize: 17.0];
		outgoLabel.textAlignment = UITextAlignmentRight;
		outgoLabel.textColor = [UIColor redColor];
		outgoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:outgoLabel];
	} else {
		dateLabel = (UILabel *)[cell.contentView viewWithTag:0];
		incomeLabel = (UILabel *)[cell.contentView viewWithTag:1];
		outgoLabel = (UILabel *)[cell.contentView viewWithTag:2];
	}

	dateLabel.text = [dateFormatter stringFromDate:report.date];

	incomeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Income", @""), 
								 [DataModel currencyString:report.totalIncome]];
	outgoLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Outgo", @""), 
								[DataModel currencyString:report.totalOutgo]];

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
