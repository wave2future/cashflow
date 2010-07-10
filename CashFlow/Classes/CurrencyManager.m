// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "CurrencyManager.h"

@implementation CurrencyManager

@synthesize baseCurrency;
@synthesize currencies;

+ (CurrencyManager *)instance
{
    static CurrencyManager *theInstance = nil;
    if (theInstance == nil) {
        theInstance = [[CurrencyManager alloc] init];
    }
    return theInstance;
}

- (id)init
{
    [super init];

    NSNumberFormatter *nf;

    nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setLocale:[NSLocale currentLocale]];
    numberFormatter = nf;

#if 0
    nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits:1];
    numberFormatterWithFraction = nf;

    nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:0];
    [nf setMaximumFractionDigits:0];
    [nf setMinimumIntegerDigits:1];
    numberFormatterWithoutFraction = nf;
#endif
    
    self.currencies = [NSArray arrayWithObjects:
        @"USD", @"AUD", @"BHD", @"THB", @"BND",
        @"CLP", @"DKK", @"EUR", @"HUF", @"HKD", @"ISK", @"CAD",
        @"QAR", @"KWD", @"MYR", @"MTL", @"MUR", @"MXN",
        @"NPR", @"TWD", @"NZD", @"NOK", @"PKR", @"GBP",
        @"ZAR", @"BRL", @"CNY", @"OMR", @"IDR", @"RUB",
        @"SAR", @"ILS", @"SEK", @"CHF", @"SGD", @"SKK",
        @"LKR", @"KRW", @"KZT", @"CZK", @"AED", @"JPY",
        @"CYP", @"INR", nil];

    self.baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"BaseCurrency"];

    return self;
}

- (void)setBaseCurrency:(NSString *)currency
{
    if (baseCurrency != currency) {
        [baseCurrency release];
        baseCurrency = currency;
        [baseCurrency retain];
        
        if (currency != nil) {
            [numberFormatter setCurrencyCode:currency];
        } else {
            NSNumberFormatter *tmp = [[[NSNumberFormatter alloc] init] autorelease];
            [tmp setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setCurrencyCode:[tmp currencyCode]];
        }

        [[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"BaseCurrency"];
    }
}

- (NSString *)formatCurrencyString:(double)value
{
    BOOL withFraction = YES;
    NSString *symbol = nil;

    NSNumber *n = [NSNumber numberWithDouble:value];

    return [numberFormatter stringFromNumber:n];
    
#if 0
    if (baseCurrency == nil) {
        return [numberFormatterSystem stringFromNumber:n];
    }

    if ([baseCurrency isEqual:@"USD"]) {
        symbol = @"$";
    }
    else if ([baseCurrency isEqual:@"EUR"]) {
        symbol = @"€";
    }
    else if ([baseCurrency isEqual:@"JPY"]) {
        symbol = @"¥";
        withFraction = NO;
    }
    else if ([baseCurrency isEqual:@"GBP"]) {
        symbol = @"£";
    }

    NSNumberFormatter *numFormatter;
    if (withFraction) {
        numFormatter = numberFormatterWithFraction;
    } else {
        numFormatter = numberFormatterWithoutFraction;
    }
    NSString *number = [numFormatter stringFromNumber:n];

    NSString *fmted;
    if (symbol != nil) {
        fmted = [NSString stringWithFormat:@"%@%@", symbol, number];
    } else {
        fmted = [NSString stringWithFormat:@"%@ %@", number, baseCurrency];
    }
    return fmted;
#endif
}

@end
        

