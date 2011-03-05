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
        cell = [[[ReportCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    mNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
    mNameLabel.font = [UIFont systemFontOfSize: 14.0];
    mNameLabel.textColor = [UIColor grayColor];
    mNameLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:mNameLabel];

    mIncomeGraph = [[[UIView alloc] initWithFrame:CGRectMake(120, 22, 170, 16)] autorelease];
    mIncomeGraph.backgroundColor = [UIColor blueColor];
    mIncomeGraph.opaque = YES;
    [self.contentView addSubview:mIncomeGraph];

    mIncomeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 20, 130, 20)] autorelease];
    mIncomeLabel.font = [UIFont systemFontOfSize: 14.0];
    mIncomeLabel.textAlignment = UITextAlignmentRight;
    mIncomeLabel.textColor = [UIColor blueColor];
    //incomeLabel.lineBreakMode = UILineBreakModeWordWrap;
    mIncomeLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:mIncomeLabel];

    mOutgoGraph = [[[UIView alloc] initWithFrame:CGRectMake(120, 42, 170, 16)] autorelease];
    mOutgoGraph.backgroundColor = [UIColor redColor];
    mOutgoGraph.opaque = YES;
    [self.contentView addSubview:mOutgoGraph];

    mOutgoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 40, 130, 20)] autorelease];
    mOutgoLabel.font = [UIFont systemFontOfSize: 14.0];
    mOutgoLabel.textAlignment = UITextAlignmentRight;
    mOutgoLabel.textColor = [UIColor redColor];
    //outgoLabel.lineBreakMode = UILineBreakModeWordWrap;
    mOutgoLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:mOutgoLabel];
    
    mMaxAbsValue = 0.000001;

    return self;
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
    [self updateGraph];
}

- (void)setOutgo:(double)v
{
    mOutgo = v;
    mOutgoLabel.text = [CurrencyManager formatCurrency:mOutgo];
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
