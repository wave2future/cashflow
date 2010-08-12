// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatCell.m
//

#import "ReportCatCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCatCell

@synthesize name, value, maxAbsValue;

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

    graphView = [[[UIView alloc] initWithFrame:CGRectMake(100, 2, 210,20)] autorelease];
    graphView.backgroundColor = [UIColor greenColor];
    graphView.opaque = YES;
    [self.contentView addSubview:graphView];

    nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 44)] autorelease];
    nameLabel.font = [UIFont systemFontOfSize: 14.0];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:nameLabel];

    valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 23, 130, 20)] autorelease];
    valueLabel.font = [UIFont systemFontOfSize: 13.0];
    //valueLabel.textAlignment = UITextAlignmentRight;
    valueLabel.textAlignment = UITextAlignmentLeft;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:valueLabel];

    return self;
}

- (void)dealloc {
    [name release];
    [super dealloc];
}

- (void)setName:(NSString *)n
{
    if (name == n) return;

    [name release];
    name = [n retain];

    nameLabel.text = name;
}

- (void)setValue:(double)v
{
    value = v;
    valueLabel.text = [CurrencyManager formatCurrency:value];
    if (value >= 0) {
        valueLabel.textColor = [UIColor blackColor];
    } else {
        valueLabel.textColor = [UIColor blackColor];
    }
    [self updateGraph];
}

- (void)setMaxAbsValue:(double)mav
{
    maxAbsValue = mav;
    if (maxAbsValue < 0.0000001) {
        maxAbsValue = 0.0000001; // for safety
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
        fullWidth = 200;
    }
    
    ratio = value / maxAbsValue;
    if (ratio > 1.0) ratio = 1.0;

    if (ratio > 0.0) {
        graphView.backgroundColor = [UIColor blueColor];
    } else {
        graphView.backgroundColor = [UIColor redColor];        
        ratio = -ratio;
    }
    int width = fullWidth * ratio + 6;

    graphView.frame = CGRectMake(100, 2, width, 20);
}

@end
