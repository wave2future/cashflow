// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.ormapper;

import java.util.*;
import java.text.*;

import android.content.Context;
import android.database.sqlite.*;

public class Database extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "CashFlow";
    private static final int VERSION = 1;

    private static SQLiteDatabase db = null;

    private static SimpleDateFormat dateFormat = null;

    public static void initialize(Context context) {
        db = (new Database(context)).getWritableDatabase();
    }

    public static SQLiteDatabase instance() {
        return db;
    }

    public Database(Context context) {
        super(context, DATABASE_NAME, null, VERSION);
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
    public static String date2str(Date d) {
    	return dateFormat().format(d);
    }
    
    public static Date str2date(String d) {
    	try {
    		return dateFormat().parse(d);
    	}
    	catch (ParseException ex) {
    		return null; // TBD
    	}
    }

    private static SimpleDateFormat dateFormat() {
        if (dateFormat == null) {
            dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
            dateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        }
        return dateFormat;
    }
}
