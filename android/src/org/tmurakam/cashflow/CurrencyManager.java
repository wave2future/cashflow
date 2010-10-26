// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow;

import java.lang.*;
import java.util.*;
import java.text.*;

public class CurrencyManager {
    public String baseCurrency;

    private NumberFormat numberFormat;

    private static CurrencyManager theInstance = null;

    private static final String[] currencies = {
         "AED",
         "AUD",
         "BHD",
         "BND",
         "BRL",
         "CAD", 
         "CHF",
         "CLP",
         "CNY",
         "CYP",
         "CZK",
         "DKK",
         "EUR",
         "GBP",
         "HKD",
         "HUF",
         "IDR",
         "ILS",
         "INR",
         "ISK",
         "JPY",
         "KRW",
         "KWD",
         "KZT",
         "LKR",
         "MTL",
         "MUR",
         "MXN",
         "MYR",
         "NOK",
         "NPR",
         "NZD",
         "OMR",
         "PKR",
         "QAR",
         "RUB",
         "SAR",
         "SEK",
         "SGD",
         "SKK",
         "THB",
         "TWD",
         "USD",
         "ZAR"
    };

    public static CurrencyManager instance() {
	if (theInstance == null) {
	    theInstance = new CurrencyManager();
	}
	return theInstance;
    }

    public CurrencyManager() {
	numberFormat = new NumberFormat.getCurrencyInstance();

	// TBD
	baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"BaseCurrency"];
	setBaseCurrency(baseCurrency);
    }

    public static String systemCurrency() {
	return Currency.getInstance().getCurrencyCode();
    }

    public void setBaseCurrency(String currencyCode) {
	baseCurrency = currencyCode;
        
	Currency currency;
        if (currencyCode == null) {
	    currency = Currency.getInstance();
	} else {
	    currency = Currency.getInstance(currencyCode);
	}
	numberFormatter.setCurrency(currency);
        
        [[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"BaseCurrency"];
    }
}

+ (NSString *)formatCurrency:(double)value
{
    return [[CurrencyManager instance] _formatCurrency:value];
}

- (NSString *)_formatCurrency:(double)value
{
    NSNumber *n = [NSNumber numberWithDouble:value];
    return [numberFormatter stringFromNumber:n];
}

@end
        

    
