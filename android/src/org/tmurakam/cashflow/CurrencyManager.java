// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

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
		numberFormat = NumberFormat.getCurrencyInstance();

		// TBD
		baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"BaseCurrency"];
		setBaseCurrency(baseCurrency);
    }

    public static String systemCurrency() {
		return Currency.getInstance(Locale.getDefault()).getCurrencyCode();
    }

    public void setBaseCurrency(String currencyCode) {
		baseCurrency = currencyCode;
        
		Currency currency;
        if (currencyCode == null) {
			currency = Currency.getInstance(Locale.getDefault());
		} else {
			currency = Currency.getInstance(currencyCode);
		}
		numberFormat.setCurrency(currency);
        
        [[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"BaseCurrency"];
    }

    public static String formatCurrency(double value) {
        return CurrencyManager.instance()._formatCurrency(value);
    }

    private String _formatCurrency(double value) {
        return numberFormat.format(value);
    }
}
