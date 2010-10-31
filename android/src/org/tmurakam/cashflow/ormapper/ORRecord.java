// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ormapper;

import java.util.ArrayList;
import android.database.sqlite.SQLiteDatabase;
import android.database.Cursor;

import org.tmurakam.cashflow.ormapper.Database;

public abstract class ORRecord {
	private static final String pkey = "key";

	private int pid; // primary key
	private boolean isInserted;

	public int pid() {
		return this.pid;
	}
	public void setPid(int pid) {
		this.pid = pid;
	}

	// constructor
	ORRecord() {
		isInserted = false;
	}

	/**
	   @brief Migrate database table
	*/
	static protected boolean migrate(String tableName, String[] array) {
		SQLiteDatabase db = Database.instance();
		boolean ret;
		String tablesql;

		// check if table exists.
		String sql = "SELECT sql FROM sqlite_master WHERE type='table' AND name='?'";
		String[] params = {tableName};
		Cursor cursor = db.rawQuery(sql, params);
		cursor.moveToFirst();

		// create table
		if (cursor.getCount() == 0) {
			sql = "CREATE TABLE " + tableName + " (" + pkey + 
				" INTEGER PRIMARY KEY);";
			db.execSQL(sql);
			tablesql = sql;
			ret = true;
		} else {
			cursor.moveToFirst();
			tablesql = cursor.getString(0);
			ret = false;
		}
		cursor.close();

		// add columns
		int count = array.length / 2;

		for (int i = 0; i < count; i++) {
			String column = array[i * 2];
			String type = array[i * 2 + 1];

			if (tablesql.indexOf(" " + column + " ") < 0) {
				sql = "ALTER TABLE " + tableName + " ADD COLUMN " + 
					column + " " + type + ";";
				db.execSQL(sql);
			}
		}
		return ret;
	}

	/**
	   @brief get all records
	   @return array of all record
	*/
	public ArrayList<Object> find_all() {
		return find_cond(null);
	}

	/**
	   @brief get all records matches the conditions

	   @param cond Conditions (WHERE phrase and so on)
	   @return array of records

	   You must override this.
	*/
	public abstract ArrayList<Object> find_cond(String cond);

	/**
	   @brief get the record matches the id
	   
	   @param id Primary key of the record
	   @return record
	*/
	public abstract ORRecord find(int pid);

	/**
	   @brief Save record
	*/
	public void save() {
		if (isInserted) {
			update();
		} else {
			insert();
		}
	}

	public void insert() {
		isInserted = true;
		return;
	}

	public void update() {
		return;
	}

	/**
	   @brief Delete record
	*/
	public abstract void delete();
	public abstract void delete_cond(String cond);
	
	public void delete_all() { delete_cond(null); }
}
