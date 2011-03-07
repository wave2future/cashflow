// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCell.m
//

#import "ReportCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCell

@synthesize name = mName, income = mIncome, outgo = mOutgo, maxAbsValue = mMaxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCell";

    ReportCell *cell = (ReportCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        UIViewController *vc = [[UIViewController alloc] initWithNibName:@"ReportCell" bundle:nil];
        cell = (ReportCell *)vc.view;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [vc release];
    }
    return cell;
}

+ (CGFloat)cellHeight
{
    return 62;
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

- (void)setIncome:(double)v
{
    mIncome = v;
    mIncomeLabel.text = [CurrencyManager formatCurrency:mIncome];
}

- (void)setOutgo:(double)v
{
    mOutgo = v;
    mOutgoLabel.text = [CurrencyManager formatCurrency:mOutgo];
}

- (void)setMaxAbsValue:(double)mav
{
    mMaxAbsValue = mav;
    if (mMaxAbsValue < 0.0000001) {
        mMaxAbsValue = 0.0000001; // for safety
    }
}

- (void)updateGraph
{
    double ratio;
    int width;
    int fullWidth;
    
    if (IS_IPAD) {
        fullWidth = 500;
    } else {
        fullWidth = 170;
    }

    ratio = mIncome / mMaxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    width = fullWidth * ratio + 1;
    mIncomeGraph.frame = CGRectMake(120, 22, width, 16);

    ratio = -mOutgo / mMaxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    width = fullWidth * ratio + 1;
    mOutgoGraph.frame = CGRectMake(120, 42, width, 16);
}

@end
