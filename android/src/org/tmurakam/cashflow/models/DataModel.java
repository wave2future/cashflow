// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;
import android.content.Context;

import org.tmurakam.cashflow.ormapper.*;

public class DataModel {
	private Journal journal;
	private Ledger ledger;
	private Categories categories;

	public static Journal getJournal() { return instance.journal; }
	public static Ledger  getLedger() { return instance.ledger; }
	public static Categories getCategories() { return instance.categories; }

	// singleton
	public static DataModel instance = new DataModel();

	private DataModel() {
		journal = new Journal();
		ledger = new Ledger();
		categories = new Categories();
	}

	public void load(Context context) {
		Database.initialize(context);

		// migrate
		Transaction.migrate();
		Asset.migrate();
		Category.migrate();
		DescLRU.migrate();

		// Load all transactions
		journal.reload();

		// Load ledger
		ledger.load();
		ledger.rebuild();

		// Load categories
		categories.reload();
	}

	////////////////////////////////////////////////////////////////////////////
	// Utility

	// 摘要からカテゴリを推定する
	//
	// note: 本メソッドは Asset ではなく DataModel についているべき
	//
	int categoryWithDescription(String desc) {
		String[] param = { desc };
		ArrayList<Object> ary = Transaction.instance.find_cond("WHERE description = ? ORDER BY date DESC LIMIT 1", param);
	
		int category = -1;
		if (ary.size() > 0) {
			Transaction t = (Transaction)ary.get(0);
			category = t.category;
		}
		return category;
	}
}
