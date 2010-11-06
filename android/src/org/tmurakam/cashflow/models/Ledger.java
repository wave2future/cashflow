// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

// Ledger : 総勘定元帳

package org.tmurakam.cashflow.models;

import java.util.*;

import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;

public class Ledger {
	public ArrayList<Asset> assets = null;

	public void load() {
		assets = Asset.find_cond("ORDER BY sorder");
	}

	public void rebuild() {
		for (Asset as : assets) {
			as.rebuild();
		}
	}

	public int assetCount() {
		return assets.size();
	}

	public Asset assetAtIndex(int n) {
		return assets.get(n);
	}

	public Asset assetWithKey(int pid) {
		for (Asset as : assets) {
			if (as.pid == pid) return as;
		}
		return null;
	}


	public int assetIndexWithKey(int pid) {
		int i;
		for (i = 0; i < assets.size(); i++) {
			Asset as = assets.get(i);
			if (as.pid == pid) return i;
		}
		return -1;	  
	}

	public void addAsset(Asset as) {
		assets.add(as);
		as.insert();
	}

	public void deleteAsset(Asset as) {
		as.delete();

		DataModel.getJournal().deleteAllTransactionsWithAsset(as);

		assets.remove(as);
		rebuild();
	}

	public void updateAsset(Asset asset) {
		asset.update();
	}

	public void reorderAsset(int from, int to) {
		Asset as = assets.get(from);
		assets.remove(from);
		assets.add(to, as);
	
		// renumbering sorder
		SQLiteDatabase db = Database.instance();
		db.beginTransaction();
		for (int i = 0; i < assets.size(); i++) {
			as = assets.get(i);
			as.sorder = i;
			as.update();
		}
		db.endTransaction();
	}
}
