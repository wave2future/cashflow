// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;

// レポート(一件分)
public class Report {
	public long date;
	public long endDate;
	double totalIncome;
	double totalOutgo;

	ArrayList<CatReport> catReports;

	public Report() {
		date = 0;
		totalIncome = 0.0;
		totalOutgo = 0.0;
	}
}
