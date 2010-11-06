// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;

public class Journal {
	private ArrayList<Transaction> entries;

	public Journal() {
		entries = null;
	}

	public ArrayList<Transaction> getEntries() {
		return entries;
	}

	public void reload() {
		entries = Transaction.find_cond("ORDER BY date, key");
	}

	public void insertTransaction(Transaction tr) {
		int i;
		int max = entries.size();
		Transaction t = null;

		// 挿入位置を探す
		for (i = 0; i < max; i++) {
			t = entries.get(i);
			if (tr.date < t.date) {
				break;
			}
		}

		// 挿入
		entries.add(i, tr);
		tr.insert();

		// 上限チェック
		if (entries.size() > Asset.MAX_TRANSACTIONS) {
			// 最も古い取引を削除する
			// Note: 初期残高を調整するため、Asset 側で削除させる
			t = entries.get(0);
			Asset asset = DataModel.getLedger().assetWithKey(t.asset);
			asset.deleteEntryAt(0);
		}
	}

	public void replaceTransaction(Transaction from, Transaction to) {
		// copy key
		to.pid = from.pid;

		// update DB
		to.update();

		int idx = entries.indexOf(from);
		if (idx < 0) {
			// TBD: fatal
		} else {
			entries.set(idx, to);
			_sortByDate();
		}
	}

	// sort
	private void _sortByDate() {
		Collections.sort(entries, new Comparator<Transaction>() {
			public int compare(Transaction t1, Transaction t2) {
				return (int)(t1.date - t2.date);
			}
		});
	}

	/**
	   Transaction 削除処理
   
	   資産間移動取引の場合は、相手方資産残高が狂わないようにするため、
	   相手方資産の入金・出金処理に置換する。

	   @param t 取引
	   @param asset 取引を削除する資産
	   @return エントリが消去された場合は YES、置換された場合は NO。
	*/
	public boolean deleteTransaction(Transaction t, Asset asset) {
		if (t.type != Transaction.TRANSFER) {
			// 資産間移動取引以外の場合
			t.delete();
			entries.remove(t);
			return true;
		}

		// 資産間移動の場合の処理
		// 通常取引 (入金 or 出金) に変更する
		if (t.asset == asset.pid) {
			// 自分が移動元の場合、移動方向を逆にする
			// (金額も逆転する）
			t.asset = t.dst_asset;
			t.value = -t.value;
		}
		t.dst_asset = -1;

		// 取引タイプを変更
		if (t.value >= 0) {
			t.type = Transaction.INCOME;
		} else {
			t.type = Transaction.OUTGO;
		}

		// データベース書き換え
		t.update();
		return false;
	}

	/**
	   Asset に紐づけられた全 Transaction を削除する (Asset 削除用)
	*/
	public void deleteAllTransactionsWithAsset(Asset asset) {
		Transaction t;
		int max = entries.size();

		for (int i = 0; i < max; i++) {
			t = entries.get(i);
			if (t.asset != asset.pid && t.dst_asset != asset.pid) {
				continue;
			}

			if (deleteTransaction(t, asset)) {
				// エントリが削除された場合は、配列が一個ずれる
				i--;
				max--;
			}
		}

		// rebuild が必要!
	}
}
