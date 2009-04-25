// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCell.m
//

#import "ReportCell.h"
#import "DataModel.h"

@implementation ReportCell

@synthesize name, income, outgo, maxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCell";

    ReportCell *cell = (ReportCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[ReportCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:identifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)] autorelease];
    nameLabel.font = [UIFont systemFontOfSize: 14.0];
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:nameLabel];

    incomeGraph = [[[UIView alloc] initWithFrame:CGRectMake(120, 22, 170, 16)] autorelease];
    incomeGraph.backgroundColor = [UIColor blueColor];
    incomeGraph.opaque = YES;
    [self.contentView addSubview:incomeGraph];

    incomeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 20, 130, 20)] autorelease];
    incomeLabel.font = [UIFont systemFontOfSize: 14.0];
    incomeLabel.textAlignment = UITextAlignmentRight;
    incomeLabel.textColor = [UIColor blueColor];
    //incomeLabel.lineBreakMode = UILineBreakModeWordWrap;
    incomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:incomeLabel];

    outgoGraph = [[[UIView alloc] initWithFrame:CGRectMake(120, 42, 170, 16)] autorelease];
    outgoGraph.backgroundColor = [UIColor redColor];
    outgoGraph.opaque = YES;
    [self.contentView addSubview:outgoGraph];

    outgoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 40, 130, 20)] autorelease];
    outgoLabel.font = [UIFont systemFontOfSize: 14.0];
    outgoLabel.textAlignment = UITextAlignmentRight;
    outgoLabel.textColor = [UIColor redColor];
    //outgoLabel.lineBreakMode = UILineBreakModeWordWrap;
    outgoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:outgoLabel];
    
    maxAbsValue = 0.000001;

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

- (void)setIncome:(double)v
{
    income = v;
    incomeLabel.text = [DataModel currencyString:income];
    [self updateGraph];
}

- (void)setOutgo:(double)v
{
    outgo = v;
    outgoLabel.text = [DataModel currencyString:outgo];
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
    int width;


    ratio = income / maxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    width = 170.0 * ratio + 1;
    incomeGraph.frame = CGRectMake(120, 22, width, 16);

    ratio = -outgo / maxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    width = 170.0 * ratio + 1;
    outgoGraph.frame = CGRectMake(120, 42, width, 16);
}

@end
