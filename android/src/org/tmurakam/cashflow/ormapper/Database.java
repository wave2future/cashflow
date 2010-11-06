// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ormapper;

import java.util.*;
import java.text.*;

import android.content.Context;
import android.database.sqlite.*;

public class Database extends SQLiteOpenHelper {
	private static final String DATABASE_NAME = "CashFlow";
	private static final int VERSION = 1;

	private static SQLiteDatabase instance = null;

	private static SimpleDateFormat dateFormat;
	private static Date workDate;
	
	static {
		dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		dateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
		
		workDate = new Date();
	}

	public static void initialize(Context context) {
		instance = (new Database(context)).getWritableDatabase();
	}

	private Database(Context context) {
		super(context, DATABASE_NAME, null, VERSION);
	}

	public static SQLiteDatabase instance() {
		return instance;
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
	
	}
	
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
	
	}

	/**
	 * 	utilities
	 */
	public static String date2str(long d) {
		workDate.setTime(d);
		return dateFormat.format(d);
	}
	
	public static long str2date(String d) {
		try {
			return dateFormat.parse(d).getTime();
		}
		catch (ParseException ex) {
			return 0; // 1970/1/1 0:00:00 GMT
		}
	}
}
