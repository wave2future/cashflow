// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "CurrencyManager.h"

@synthesize baseCurrency;
@synthesize currencies;

@implementation CurrencyManager

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
    numberFormatterSystem = nf;

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

        [[NSUserDefaults standradUserDefaults] setObject:baseCurrency forKey:@"BaseCurrency"];
    }
}

- (NSString *)fomatCurrencyString:(double)value
{
    BOOL withFraction = YES;
    NSString *symbol = nil;

    NSNumber *n = [NSNumber numberWithDouble:value];

    if (baseCurrency == nil) {
        return [currencyFormatter stringFromNumber:n];
    }

    if ([currency isEqual:@"USD"]) {
        symbol = @"$";
    }
    else if ([currency isEqual:@"EUR"]) {
        symbol = @"€";
    }
    else if ([currency isEqual:@"JPY"]) {
        symbol = @"¥";
        withFraction = NO;
    }
    else if ([currency isEqual:@"GBP"]) {
        symbol = @"£";
    }

    NSNumberFormatter *numFormatter;
    if (withFraction) {
        numFormatter = numFormatterWithFraction;
    } else {
        numFormatter = numFormatterWithoutFraction;
    }
    NSString *number = [numFormatter stringFromNumber:n];

    NSString *fmted;
    if (symbol != nil) {
        fmted = [NSString stringWithFormat:@"%@%@", symbol, number];
    } else {
        fmted = [NSString stringWithFormat:@"%@ %@", number, currency];
    }
    return fmted;
}

@end
        

