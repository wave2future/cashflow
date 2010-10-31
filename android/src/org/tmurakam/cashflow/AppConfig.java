// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow;

import java.lang.*;
import java.util.*;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class AppConfig {
    public static final int DateTimeModeWithTime = 0;  // 日＋時
    public static final int DateTimeModeWithTime5min = 1;  // 日＋時
    public static final int DateTimeModeDateOnly = 2;  // 日のみ

    public String baseCurrency;
    public int dateTimeMode;

    // 締め日 (1～29)、月末を指定する場合は 0
    public int cutoffDate;

    private static AppConfig theConfig = null;
    private SharedPreferences pref;

    public static AppConfig instance() {
        return theConfig;
    }

    public static void init(Context context) {
        theConfig = new AppConfig(context);
    }

    private AppConfig(Context context) {
        pref = PreferenceManager.getDefaultSharedPreferences(context);
        baseCurrency = pref.getString("baseCurrency", null);
        dateTimeMode = pref.getInt("dateTimeMode", DateTimeModeWithTime);
        cutoffDate = pref.getInt("cutoffDate", 0);
    }

    public void save() {
        SharedPreferences.Editor e = pref.edit();
        e.putString("baseCurrency", baseCurrency);
        e.putInt("dateTimeMode", dateTimeMode);
        e.putInt("cutoffDate", cutoffDate);
        e.commit();
    }
}
