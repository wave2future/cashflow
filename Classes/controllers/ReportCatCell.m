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
        cell = [[[ReportCatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    mGraphView = [[[UIView alloc] initWithFrame:CGRectMake(100, 2, 210,20)] autorelease];
    mGraphView.backgroundColor = [UIColor greenColor];
    mGraphView.opaque = YES;
    [self.contentView addSubview:mGraphView];

    mNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 44)] autorelease];
    mNameLabel.font = [UIFont systemFontOfSize: 14.0];
    mNameLabel.textColor = [UIColor blackColor];
    mNameLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mNameLabel];

    mValueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 23, 130, 20)] autorelease];
    mValueLabel.font = [UIFont systemFontOfSize: 13.0];
    //valueLabel.textAlignment = UITextAlignmentRight;
    mValueLabel.textAlignment = UITextAlignmentLeft;
    mValueLabel.textColor = [UIColor blackColor];
    mValueLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mValueLabel];

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

- (void)setValue:(double)value maxValue:(double)maxValue
{
    mValue = value;
    mValueLabel.text = [CurrencyManager formatCurrency:mValue];
    if (mValue >= 0) {
        mValueLabel.textColor = [UIColor blackColor];
        mGraphView.backgroundColor = [UIColor blueColor];
        mValue = -mValue; // abs
    } else {
        mValueLabel.textColor = [UIColor blackColor];
        mGraphView.backgroundColor = [UIColor redColor];        
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

    ratio = mValue / maxValue;
    if (ratio > 1.0) ratio = 1.0;
    int width = fullWidth * ratio + 1;

    mGraphView.frame = CGRectMake(100, 2, width, 20);
}

@end
