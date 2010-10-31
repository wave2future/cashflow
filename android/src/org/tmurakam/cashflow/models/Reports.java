// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;

class Filter {
	public Date start;
	public Date end;
	public int asset;
	public int category;
	public boolean isOutgo;
	public boolean isIncome;

	public void init() {
		start = null;
		end = null;
		asset = -1;
		isOutgo = false;
		isIncome = false;
		category = -1;
	}
}

// レポート(集合)
public class Reports {
	public int type;
	public ArrayList<Report> reports;

	public static final int WEEKLY = 0;
	public static final int MONTHLY = 1;

	public Reports() {
		type = MONTHLY;
		reports = null;
	}

	/*
	  static int compareCatReport(id x, id y, void *context)
	  {
	  CatReport *xr = (CatReport *)x;
	  CatReport *yr = (CatReport *)y;
	
	  if (xr.value == yr.value) {
	  return NSOrderedSame;
	  }
	  if (xr.value > yr.value) {
	  return NSOrderedDescending;
	  }
	  return NSOrderedAscending;
	  }
	*/

	public void generate(int a_type, Asset asset) {
		type = a_type;
	
		reports = new ArrayList<Report>();

		int assetKey;
		if (asset == null) {
			assetKey = -1;
		} else {
			assetKey = asset.pid;
		}
		Date firstDate = firstDateOfAsset(assetKey);
		if (firstDate == null) return; // no data
		Date lastDate = lastDateOfAsset(assetKey);

		// レポート周期の開始時間および間隔を求める
		Calendar cal = Calendar.getInstance(); // local calendar
		cal.setTime(firstDate);
		cal.set(Calendar.HOUR, 0);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);

		switch (type) {
		case MONTHLY:
			// 締め日設定
			int cutoffDate = AppConfig.instance().cutoffDate;
			if (cutoffDate == 0) {
				// 月末締め ⇒ 開始は同月1日から。
				cal.set(Calendar.DATE, 1);
			}
			else {
				// 一つ前の月の締め日翌日から開始
				cal.add(Calendar.MONTH, -1);
				cal.set(Calendar.DATE, cutoffDate + 1);
			}
			break;
			
		case WEEKLY:
			cal.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 日曜日開始にする
			break;
		}
	
		int numCategories = DataModel.getCategories().categoryCount();
	
		while (cal.getTime().compareTo(lastDate) <= 0) {
			// Report 生成
			Report r = new Report();
			reports.add(r);

			// 日付設定
			r.date = cal.getTime();
		
			// 次の期間開始時期を計算する
			switch (type) {
			case MONTHLY:
				cal.add(Calendar.MONTH, 1);
				break;
			case WEEKLY:
				cal.add(Calendar.DATE, 7);
				break;
			}
			r.endDate = cal.getTime();

			// 集計
			Filter filter = new Filter();
			filter.init();

			filter.asset = assetKey;
			filter.start = r.date;
			filter.end = r.endDate;

			filter.isIncome = true;
			filter.isOutgo = false;
			r.totalIncome = calculateSum(filter);

			filter.isIncome = false;
			filter.isOutgo = true;
			r.totalOutgo = calculateSum(filter);

			// カテゴリ毎の集計
			int i;
			r.catReports = new ArrayList<CatReport>();
			double remain = r.totalIncome + r.totalOutgo;

			filter.init();
			filter.asset = assetKey;

			for (i = 0; i < numCategories; i++) {
				Category c = DataModel.getCategories().categoryAtIndex(i);
				CatReport cr = new CatReport();

				cr.catkey = c.pid;

				filter.category = c.pid;
				filter.start = r.date;
				filter.end = r.endDate;
				cr.value = calculateSum(filter);

				remain -= cr.value;

				r.catReports.add(cr);
			}

			// 未分類項目
			CatReport cr = new CatReport();
			cr.catkey = -1;
			cr.value = remain;
			r.catReports.add(cr);
		
			// ソート
			Collections.sort(r.catReports, new Comparator<CatReport>() {
				public int compare(CatReport xr, CatReport yr) {
					if (xr.value > yr.value) return 1;
					if (xr.value < yr.value) return -1;
					return 0;
				}
			});
		}
	}

	//////////////////////////////////////////////////////////////////////////////////
	// Report 処理

	private Date firstDateOfAsset(int asset) {
		for (Transaction t : DataModel.getJournal().getEntries()) {
			if (asset < 0) return t.date;
			if (t.asset == asset || t.dst_asset == asset) return t.date;
		}
		return null;
	}

	private Date lastDateOfAsset(int asset) {
		ArrayList<Transaction> entries = DataModel.getJournal().getEntries();
		for (int i = entries.size() - 1; i >= 0; i--) {
			Transaction t = entries.get(i);
			if (asset < 0) return t.date;
			if (t.asset == asset || t.dst_asset == asset) return t.date;
		}
		return null;
	}

	private double calculateSum(Filter filter) {
		double sum = 0.0;
		double value;

		for (Transaction t : DataModel.getJournal().getEntries()) {
			// match filter
			if (filter.start != null &&
				t.date.compareTo(filter.start) < 0) continue;
			
			if (filter.end != null &&
				filter.end.compareTo(t.date) <= 0) continue;
			
			if (filter.category >= 0 && t.category != filter.category) {
				continue;
			}

			if (filter.asset < 0) {
				// 資産指定なしの資産間移動は計上しない
				if (t.type == Transaction.TRANSFER) {
					continue;
				}
				value = t.value;
			}
			else {
				if (t.asset == filter.asset) {
					value = t.value;
				}
				else if (t.dst_asset == filter.asset) {
					value = -t.value;
				}
				else {
					continue;
				}
			}
			
			if (filter.isOutgo && value >= 0) {
				continue;
			}
			if (filter.isIncome && value <= 0) {
				continue;
			}
			sum += value;
		}
		return sum;
	}
}
