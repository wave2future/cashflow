// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>

@interface CurrencyManager : NSObject
{
    NSString *baseCurrency;
    NSArray *currencies;

    NSNumberFormatter *numberFormatter;
}

@property(nonatomic,retain) NSString *baseCurrency;
@property(nonatomic,retain) NSArray *currencies;

+ (CurrencyManager *)instance;

+ (NSString *)systemCurrency;
+ (NSString *)formatCurrency:(double)value;

// private
- (NSString *)_formatCurrency:(double)value;


@end

