// Generated by O/R mapper generator ver 0.1(cashflow)

package org.tmurakam.cashflow.ormapper;

import java.util.*;
import android.content.ContentValues;
import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.ORRecord;
import org.tmurakam.cashflow.models.*;

public class AssetBase extends ORRecord {
    public final static String tableName = "Assets";

	public int pid;
	protected boolean isInserted = false;

	public String name;
	public int type;
	public double initialBalance;
	public int sorder;


	/**
	  @brief Migrate database table
	  @return YES - table was newly created, NO - table already exists
	*/
	public static boolean migrate() {
		String[] columnTypes = {
		"name", "TEXT",
		"type", "INTEGER",
		"initialBalance", "REAL",
		"sorder", "INTEGER",
		};

		return migrate(tableName, columnTypes);
	}

	// Read operations

	/**
	  @brief get the record matches the id

	  @param pid Primary key of the record
	  @return record
	*/
	public Asset find(int pid) {
		SQLiteDatabase db = Database.instance();

		String[] param = { Integer.toString(pid) };
		Cursor cursor = db.rawQuery("SELECT * FROM " + tableName + " WHERE key = ?;", param);

		Asset e = null;
		cursor.moveToFirst();
		if (!cursor.isAfterLast()) {
			e = new Asset();
			e._loadRow(cursor);
		}
		cursor.close();
 
		return e;
	}

	/**
	   @brief get all records
	   @return array of all record
	*/
	public static ArrayList<Asset> find_all() {
		return find_cond(null, null);
	}

	/**
	   @brief get all records matches the conditions

	   @param cond Conditions (WHERE phrase and so on)
	   @return array of records
	*/
	public static ArrayList<Asset> find_cond(String cond) {
		return find_cond(cond, null);
	}

	/**
	   @brief get all records match the conditions

	   @param cond Conditions (WHERE phrase and so on)
	   @return array of records
	*/
	public static ArrayList<Asset> find_cond(String cond, String[] param) {
		String sql;
		sql = "SELECT * FROM " + tableName;
		if (cond != null) {
			sql += " ";
			sql += cond;
		}
		SQLiteDatabase db = Database.instance();
		Cursor cursor = db.rawQuery(sql, param);
		cursor.moveToFirst();

		ArrayList<Asset> array = new ArrayList<Asset>();

		while (!cursor.isAfterLast()) {
			Asset e = new Asset();
			e._loadRow(cursor);
			array.add(e);
			cursor.moveToNext();
		}
		cursor.close();

		return array;
	}

	protected void _loadRow(Cursor cursor) {
		this.pid = cursor.getInt(0);
		this.name = cursor.getString(1);
		this.type = cursor.getInt(2);
		this.initialBalance = cursor.getDouble(3);
		this.sorder = cursor.getInt(4);

		isInserted = true;
	}

	// Create operations

	public void insert() {
		super.insert();

		SQLiteDatabase db = Database.instance();

		// TBD: pid should be long?
		this.pid = (int)db.insert(tableName, "key", getContentValues());

		isInserted = true;
	}

	// Update operations

	public void update() {
		SQLiteDatabase db = Database.instance();
		db.beginTransaction();

		ContentValues cv = getContentValues();

		String[] whereArgs = { Long.toString(pid) };
		db.update(tableName, cv, "WHERE key = ?", whereArgs);

		db.endTransaction();
	}

	private ContentValues getContentValues()
	{
		ContentValues cv = new ContentValues(4);
		cv.put("name", this.name);
		cv.put("type", this.type);
		cv.put("initialBalance", this.initialBalance);
		cv.put("sorder", this.sorder);

		return cv;
	}

	// Delete operations

	/**
	   @brief Delete record
	*/
	public void delete() {
		SQLiteDatabase db = Database.instance();

		String[] whereArgs = { Long.toString(pid) };
		db.delete(tableName, "WHERE key = ?", whereArgs);
	}

	/**
	   @brief Delete all records
	*/
	public void delete_cond(String cond) {
		SQLiteDatabase db = Database.instance();

		if (cond == null) {
			cond = "";
		}
		String sql = "DELETE FROM " + tableName + " " + cond;
		db.execSQL(sql);
	}
}
