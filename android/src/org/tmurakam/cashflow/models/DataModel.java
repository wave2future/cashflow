// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;
import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class DataModel {
    private Journal journal;
    private Ledger ledger;
    private Categories categories;

    public static Journal getJournal() { return instance().journal; }
    public static Ledger  getLedger() { return instance().ledger; }
    public static Categories getCategories() { return instance().categories; }

    // singleton
    private static DataModel theDataModel = null;

    public static DataModel instance() {
        if (theDataModel == null) {
            theDataModel = new DataModel();
        }
        return theDataModel;
    }

    private DataModel() {
        journal = new Journal();
        ledger = new Ledger();
        categories = new Categories();
    }

    public load(Context context) {
        Database db = Database.instance();
        db.initialize(context);

        // migrate
        Transaction.migrate();
        Asset.migrate();
        Category.migrate();
        DescLRU.migrate();

        DescLRUManager.migrate();

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
        ArrayList<Transaction> ary = Transaction.find_cond("WHERE description = ? ORDER BY date DESC LIMIT 1", param);
    
        int category = -1;
        if (ary.size > 0) {
            Transaction t = ary[0];
            category = t.category;
        }
        return category;
    }
}
