// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ormapper;

import java.util.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.*;

import org.tmurakam.cashflow.models.DataModel;

import android.content.Context;
import android.database.sqlite.*;
import android.util.Log;

public class Database extends SQLiteOpenHelper {
	private static final String TAG = "cashflow";

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
	
	/// For test
	
	public static boolean installSqlFromResource(Context context, int sqlResourceId) {
		// open SQL raw resource
		InputStream in = context.getResources().openRawResource(sqlResourceId);
		BufferedReader b = new BufferedReader(new InputStreamReader(in));
		
		// execute each sql
		SQLiteDatabase db = instance;
		String sql;
		try {
			while ((sql = b.readLine()) != null) {
				db.execSQL(sql);
			}
			b.close();
			in.close();
		}
		catch (IOException e) {
			Log.d(TAG, "instalLSqlFromResource failed : " + e.getMessage());
			return false;
		}
		return true;
	}
}
