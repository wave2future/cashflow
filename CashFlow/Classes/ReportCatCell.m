// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatCell.m
//

#import "ReportCatCell.h"
#import "DataModel.h"

@implementation ReportCatCell

@synthesize name, value, maxAbsValue;

+ (ReportCatCell *)reportCatCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCatCell";

    ReportCatCell *cell = (ReportCatCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[ReportCatCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:identifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    graphView = [[[UILabel alloc] initWithFrame:CGRectMake(160, 2, 130,20)] autorelease];
    graphView.backgroundColor = [UIColor greenColor];
    graphView.opaque = YES;
    [self.contentView addSubview:graphView];

    nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 160, 44)] autorelease];
    nameLabel.font = [UIFont systemFontOfSize: 18.0];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:nameLabel];

    valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(160, 23, 130, 20)] autorelease];
    valueLabel.font = [UIFont systemFontOfSize: 12.0];
    //valueLabel.textAlignment = UITextAlignmentRight;
    valueLabel.textAlignment = UITextAlignmentLeft;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    valueLabel.text = [DataModel currencyString:value];
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
    [self updateGraph];
}

- (void)updateGraph
{
    double ratio = value / maxAbsValue;
    if (ratio > 0) {
        graphView.backgroundColor = [UIColor redColor];
    } else {
        graphView.backgroundColor = [UIColor blueColor];        
        ratio = -ratio;
    }

    graphView.frame = CGRectMake(160, 2, 130.0 * ratio, 20);
}

@end
