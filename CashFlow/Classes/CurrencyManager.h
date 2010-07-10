// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>

@interface CurrencyManager : NSObject
{
    NSString *baseCurrency;
    NSArray *currencies;

    NSNumberFormatter *numberFormatter;
    //NSNumberFormatter *numberFormatterWithFraction;
    //NSNumberFormatter *numberFormatterWithoutFraction;
}

@property(nonatomic,retain) NSString *baseCurrency;
@property(nonatomic,retain) NSArray *currencies;

+ (CurrencyManager *)instance;

- (NSString *)formatCurrencyString:(double)value;

@end

