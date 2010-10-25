// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.ormapper;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class Database extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "CashFlow";
    private static final int VERSION = 1;

    private static SQLiteDatabase db = null;

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

}
