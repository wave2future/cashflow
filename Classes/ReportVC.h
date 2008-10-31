//
//  ReportViewController.h
//  CashFlow
//
//  Created by 村上 卓弥 on 08/10/31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface ReportViewController : UITableViewController
{
    Reports *reports;

    NSDateFormatter *dateFormatter;
}

- (void)generateReport:(int)type;
- (UITableViewCell *)reportCell:(Report*)report;

@end
