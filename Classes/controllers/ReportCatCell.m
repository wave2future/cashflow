// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatCell.m
//

#import "ReportCatCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCatCell

@synthesize name = mName;

+ (ReportCatCell *)reportCatCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCatCell";

    ReportCatCell *cell = (ReportCatCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        UIViewController *vc = [[UIViewController alloc] initWithNibName:@"ReportCatCell" bundle:nil];
        cell = (ReportCatCell *)vc.view;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [vc release];
    }
    return cell;
}

- (void)dealloc {
    [mName release];
    [super dealloc];
}

- (void)setName:(NSString *)n
{
    if (mName == n) return;

    [mName release];
    mName = [n retain];

    mNameLabel.text = mName;
}

- (void)setValue:(double)value maxAbsValue:(double)maxAbsValue
{
    mValue = value;
    mMaxAbsValue = maxAbsValue;
    if (mMaxAbsValue < 0.0000001) {
        mMaxAbsValue = 0.0000001; // for safety
    }
    
    mValueLabel.text = [CurrencyManager formatCurrency:mValue];

    [self updateGraph];
}

- (void)updateGraph
{
    double ratio;
    int fullWidth;
    if (IS_IPAD) {
        fullWidth = 500;
    } else {
        fullWidth = 170;
    }
    
    ratio = mValue / mMaxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    if (ratio < -1.0) ratio = -1.0;

    if (ratio > 0.0) {
        mGraphView.backgroundColor = [UIColor blueColor];
    } else {
        mGraphView.backgroundColor = [UIColor redColor];        
        ratio = -ratio;
    }
    int width = fullWidth * ratio + 1;

    CGRect frame = mGraphView.frame;
    frame.size.width = width;
    mGraphView.frame = frame; //CGRectMake(100, 2, width, 20);
}

@end
