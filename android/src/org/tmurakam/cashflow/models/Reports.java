// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

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

    public void Reports() {
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

        NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
        //	NSDate *firstDate = [[asset transactionAt:0] date];
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
        NSDateComponents *dc, *steps;
        NSDate *dd = nil;
	
        steps = [[[NSDateComponents alloc] init] autorelease];
        switch (type) {
        case MONTHLY:
            dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];

            // 締め日設定
            int cutoffDate = Config.instance().cutoffDate;
            if (cutoffDate == 0) {
                // 月末締め ⇒ 開始は同月1日から。
                [dc setDay:1];
            }
            else {
                // 一つ前の月の締め日翌日から開始
                int year = [dc year];
                int month = [dc month];
                month--;
                if (month < 1) {
                    month = 12;
                    year--;
                }
                [dc setYear:year];
                [dc setMonth:month];
                [dc setDay:cutoffDate + 1];
            }

            dd = [greg dateFromComponents:dc];
            [steps setMonth:1];
            break;
			
        case REPORT_WEEKLY:
            dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
            dd = [greg dateFromComponents:dc];
            int weekday = [dc weekday];
            [steps setDay:-weekday+1];
            dd = [greg dateByAddingComponents:steps toDate:dd options:0];
            [steps setDay:7];
            break;
        }
	
        int numCategories = DataModel.categories.categoryCount();
	
        while (dd <= lastDate) {
            // Report 生成
            Report r = new Report();
            reports.add(r);

            // 日付設定
            r.date = dd;
		
            // 次の期間開始時期を計算する
            dd = [greg dateByAddingComponents:steps toDate:dd options:0];
            r.endDate = dd;

            // 集計
            Filter filter;
            filter.init();

            filter.asset = assetKey;
            filter.start = r.date;
            filter.end = dd;

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
                Category c = DataModel.instance().categories.categoryAtIndex(i);
                CatReport cr = new CatReport();

                cr.catkey = c.pid;

                filter.category = c.pid;
                filter.start = r.date;
                filter.end = r.endDate;
                cr.value = calculateSum(filter);

                remain -= cr.value;

                r.catReports.add(cr);
            }
        }
		
        // 未分類項目
        CatReport cr = new CatReport();
        cr.catkey = -1;
        cr.value = remain;
        r.catReports.add(cr);
		
        // ソート
        Collection.sort(r.catReports, new Comparator() {
            public int compare(Object o1, Object o2) {
                CatReport xr = (CatReport)o1;
                CatReport yr = (CatReport)o2;

                if (xr.value > yr.value) return 1;
                if (xr.value < yr.value) return -1;
                return 0;
            }
        });
    }

    //////////////////////////////////////////////////////////////////////////////////
    // Report 処理

    private Date firstDateOfAsset(int asset) {
        Transaction t;
        for (t in DataModel.journal().entries) {
            if (asset < 0) break;
            if (t.asset == asset || t.dst_asset == asset) break;
        }
        if (t == nil) {
            return nil;
        }
        return t.date;
    }

    private Date lastDateOfAsset(int asset) {
        ArrayList<Transaction> entries = DataModel.journal().entries;
        Transaction t = nil;
        int i;

        for (i = entries.size() - 1; i >= 0; i--) {
            t = entries.get(i);
            if (asset < 0) break;
            if (t.asset == asset || t.dst_asset == asset) break;
        }
        if (i < 0) return nil;
        return t.date;
    }

    private double calculateSum(Filter filter) {
        Transaction t;

        double sum = 0.0;
        double value;

        for (t in DataModel.journal().entries) {
            // match filter
            if (filter.start) {
                if (t.date < filter.start) continue;
            }
            if (filter.end) {
                if (filter.end <= t.date) continue;
            }
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
