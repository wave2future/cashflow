// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatCell.m
//

#import "ReportCatCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCatCell

@synthesize name = mName, value = mValue, maxAbsValue = mMaxAbsValue;

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

- (void)setValue:(double)v
{
    mValue = v;
    mValueLabel.text = [CurrencyManager formatCurrency:mValue];
    if (mValue >= 0) {
        mValueLabel.textColor = [UIColor blackColor];
    } else {
        mValueLabel.textColor = [UIColor blackColor];
    }
    [self updateGraph];
}

- (void)setMaxAbsValue:(double)mav
{
    mMaxAbsValue = mav;
    if (mMaxAbsValue < 0.0000001) {
        mMaxAbsValue = 0.0000001; // for safety
    }
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

    if (ratio > 0.0) {
        mGraphView.backgroundColor = [UIColor blueColor];
    } else {
        mGraphView.backgroundColor = [UIColor redColor];        
        ratio = -ratio;
    }
    int width = fullWidth * ratio + 6;

    mGraphView.frame = CGRectMake(100, 2, width, 20);
}

@end
