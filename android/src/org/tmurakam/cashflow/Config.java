// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

class Config {
    public static final int DateTimeModeWithTime 0  // 日＋時
    public static final int DateTimeModeWithTime5min 1  // 日＋時
    public static final int DateTimeModeDateOnly 2  // 日のみ

    public int dateTimeMode;

    // 締め日 (1～29)、月末を指定する場合は 0
    public int cutoffDate;

    private static Config theConfig = null;

    public Config instance() {
        if (theConfig == null) {
            theConfig = new Config();
        }
        return theConfig;
    }

    private Config() {
        throw new exception("TBD");
    }

    public void save() {
        throw new exception("TBD");
    }
}
