// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

// レポート(一件分)
public class Report {
    public Date date;
    public Date endDate;
    double totalIncome;
    double totalOutgo;

    ArrayList<CatReport> catReports;

    public void Report() {
        date = null;
        totalIncome = 0.0;
        totalOutgo = 0.0;
    }
}
