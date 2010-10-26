// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

class Asset extends AssetBase {
    public static final int CASH = 0;
    public static final int BANK = 1;
    public static final int CARD = 2;

    public static final int MAX_TRANSACTIONS = 5000;

    private ArrayList<AssetEntry> entries;
    private double lastBalance;

    public static AssetBase allocator() {
        return new Asset();
    }

    public void Asset() {
        entries = new ArrayList<AssetEntry>();
        type = CASH;
    }

    //
    // 仕訳帳(journal)から転記しなおす
    //
    public void rebuild{
        entries = new ArrayList<AssetEntry>();

        double balance = initialBalance;

        AssetEntry e;
        for (Transaction t in DataModel.journal.entries) {
            if (t.asset == this.pid || t.dst_asset == this.pid) {
                e = new AssetEntry(t, this);

                // 残高計算
                if (t.type == Transaction.ADJ && t.hasBalance) {
                    // 残高から金額を逆算
                    double oldval = t.value;
                    t.value = t.balance - balance;
                    if (t.value != oldval) {
                        // 金額が変更された場合、DBを更新
                        t.update();
                    }
                    balance = t.balance;

                    e.value = t.value;
                    e.balance = balance;
                }
                else {
                    balance = balance + e.value;
                    e.balance = balance;

                    if (t.type == Transaction.ADJ) {
                        t.balance = balance;
                        t.hasBalance = true;
                    }
                }

                entries.add(e);
            }
        }

        lastBalance = balance;
    }

    public void updateInitialBalance {
        update();
    }

    ////////////////////////////////////////////////////////////////////////////
    // AssetEntry operations

    public int entryCount() {
        return entries.size();
    }

    public AssetEntry entryAt(int n) {
        return entries.get(n);
    }

    public void insertEntry(AssetEntry e) {
        DataModel.journal.insertTransaction(e.transaction);
        DataModel.ledger.rebuild();
    }

    public void replaceEntryAtIndex(int index, AssetEntry e) {
        AssetEntry orig = entryAt(index);

        DataModel.journal.replaceTransaction(orig.transaction, e.transaction);
        DataModel.ledger.rebuild();
    }

    // エントリ削除
    // 注：entries からは削除されない。journal から削除されるだけ
    private void _deleteEntryAt(int index) {
        // 先頭エントリ削除の場合は、初期残高を変更する
        if (index == 0) {
            initialBalance = entryAt(0).balance;
            updateInitialBalance();
        }

        // エントリ削除
        AssetEntry e = entryAt(index);
        DataModel.journal.deleteTransaction(e.transaction, this);
    }

    // エントリ削除
    public void deleteEntryAt(int index) {
        _deleteEntryAt(index);
    
        // 転記し直す
        DataModel.ledger.rebuild();
    }

    // 指定日以前の取引をまとめて削除
    public void deleteOldEntriesBefore(Date date) {
        SQLiteDatabase db = Database.instance();

        db.beginTransaction();
        while (entries.size() > 0) {
            AssetEntry e = entries.get(0);
            if (e.transaction.date >= date) {
                break;
            }

            _deleteEntryAt(0);
            entries.removeObjectAtIndex(0);
        }
        db.commitTransaction();

        DataModel.ledger.rebuild();
    }

    public int firstEntryByDate(Date date) {
        for (int i = 0; i < entries.size(); i++) {
            AssetEntry e = entries.get(i);
            if (e.transaction.date >= date) {
                return i;
            }
        }
        return -1;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Balance operations
    public double lastBalance() {
        int max = entries.size();
        if (max == 0) {
            return initialBalance;
        }
        return entries.get(max - 1).balance;
    }

    //
    // Database operations
    //
    public static boolean migrate() {
        boolean ret = super.migrate();
    
        if (ret) {
            // newly created...
            Asset as = new Asset();
            as.name = NSLocalizedString("Cash", "");
            as.type = CASH;
            as.initialBalance = 0;
            as.sorder = 0;
            as.insert();
        }
        return ret;
    }
}
