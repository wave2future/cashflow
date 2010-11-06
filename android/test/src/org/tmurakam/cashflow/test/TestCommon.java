// -*-  Mode:Java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
package org.tmurakam.cashflow.test;

import java.io.*;

import org.tmurakam.cashflow.models.DataModel;
import org.tmurakam.cashflow.ormapper.*;

import android.database.sqlite.*;
import android.content.*;
import android.util.*;

public class TestCommon {
	private final static String TAG = "cashflowTest";
	
	// データベースを削除する
	public static void deleteDatabase(Context context) {
		//DataModel.finalize();
		
		SQLiteDatabase db = Database.instance();
		String path = db.getPath();
		db.close();
		
		File file = new File(path);
		file.delete();
		
		Database.initialize(context);
		
		// DataModel.load(context);
	}

	// データベースをインストールする
	public static boolean installDatabase(Context context, int sqlResourceId) {
		deleteDatabase(context);

		// open SQL raw resource
		InputStream in = context.getResources().openRawResource(sqlResourceId);
		BufferedReader b = new BufferedReader(new InputStreamReader(in));
		
		// execute each sql
		SQLiteDatabase db = Database.instance();
		String sql;
		try {
			while ((sql = b.readLine()) != null) {
				db.execSQL(sql);
			}
			b.close();
			in.close();
		}
		catch (IOException e) {
			Log.d(TAG, "instalLDatabase failed : " + e.getMessage());
			return false;
		}

		// load database
		DataModel.instance.load(context);
		return true;
	}
}
