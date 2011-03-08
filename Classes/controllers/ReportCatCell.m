// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatCell.m
//

#import "ReportCatCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCatCell

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

+ (CGFloat)cellHeight
{
    return 44;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)name
{
    return mNameLabel.text;
}

- (void)setName:(NSString *)name
{
    mNameLabel.text = name;
}

- (void)setValue:(double)value maxValue:(double)maxValue
{
    mValueLabel.text = [CurrencyManager formatCurrency:value];
    if (value >= 0) {
        mValueLabel.textColor = [UIColor blackColor];
        mGraphView.backgroundColor = [UIColor blueColor];
    } else {
        mValueLabel.textColor = [UIColor blackColor];
        mGraphView.backgroundColor = [UIColor redColor];        
        value = -value; // abs
    }

    if (maxValue < 0) maxValue = -maxValue; // abs
    if (maxValue < 0.001) maxValue = 0.001; // for safety

    double ratio;
    int fullWidth;
    if (IS_IPAD) {
        fullWidth = 500;
    } else {
        fullWidth = 170;
    }

    ratio = value / maxValue;
    if (ratio > 1.0) ratio = 1.0;
    int width = fullWidth * ratio + 1;

    CGRect frame = mGraphView.frame;
    frame.size.width = width;
    mGraphView.frame = frame;
}

@end
