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
