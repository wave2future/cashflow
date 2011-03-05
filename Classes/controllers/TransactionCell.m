// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// TransactionCell.m
//

#import "TransactionCell.h"
#import "DataModel.h"
#import "CurrencyManager.h"

@implementation TransactionCell

+ (TransactionCell *)transactionCell:(UITableView *)tableView
{
    NSString *identifier = @"TransactionCell";

    TransactionCell *cell = (TransactionCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (void)dealloc {
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self == nil) return nil;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
    mDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 220, 24)] autorelease];
    mDescLabel.font = [UIFont systemFontOfSize: 18.0];
    mDescLabel.textColor = [UIColor blackColor];
    mDescLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mDescLabel];
		
    mValueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(190, 0, 120, 24)] autorelease];
    mValueLabel.font = [UIFont systemFontOfSize: 18.0];
    mValueLabel.textAlignment = UITextAlignmentRight;
    mValueLabel.textColor = [UIColor blueColor];
    mValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mValueLabel];
		
    mDateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 24, 160, 20)] autorelease];
    mDateLabel.font = [UIFont systemFontOfSize: 14.0];
    mDateLabel.textColor = [UIColor grayColor];
    mDateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mDateLabel];
		
    mBalanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150, 24, 160, 20)] autorelease];
    mBalanceLabel.font = [UIFont systemFontOfSize: 14.0];
    mBalanceLabel.textAlignment = UITextAlignmentRight;
    mBalanceLabel.textColor = [UIColor grayColor];
    mBalanceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:mBalanceLabel];

    return self;
}

- (TransactionCell *)updateWithAssetEntry:(AssetEntry *)entry
{
    [self setDescriptionLabel:entry.transaction.description];
    [self setDateLabel:entry.transaction.date];
    [self setValueLabel:entry.value];
    [self setBalanceLabel:entry.balance];
    return self;
}

- (void)setDescriptionLabel:(NSString *)desc
{
    mDescLabel.text = desc;
}

- (void)setDateLabel:(NSDate *)date
{
    mDateLabel.text = [[DataModel dateFormatter] stringFromDate:date];
}

- (void)setValueLabel:(double)value
{
    if (value >= 0) {
        mValueLabel.textColor = [UIColor blueColor];
    } else {
        value = -value;
        mValueLabel.textColor = [UIColor redColor];
    }
    mValueLabel.text = [CurrencyManager formatCurrency:value];
}

- (void)setBalanceLabel:(double)balance
{
    mBalanceLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), 
                          [CurrencyManager formatCurrency:balance]];
}

- (void)clearBalanceLabel
{
    mBalanceLabel.text = @"";
}

@end
