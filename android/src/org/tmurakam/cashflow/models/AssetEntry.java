// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

//
// 各資産（勘定）のエントリ
//

class AssetEntry implements Cloneable {
    public int assetKey;
    public double value;
    public double balance;

    public Transaction transaction;

    public AssetEntry() {
        transaction = null;
        assetKey = -1;
        value = 0.0;
        balance = 0.0;
    }

    public AssetEntry(Transaction t, Asset asset) {
        assetKey = asset.pid;
        if (t == null) {
            // 新規エントリ生成
            transaction = new Transaction();
            transaction.asset = assetKey;
        } else {
            transaction = t;

            if (isDstAsset()) {
                value = -t.value;
            } else {
                value = t.value;
            }
        }
    }

    //
    // 資産間移動の移動先取引なら YES を返す
    //
    public boolean isDstAsset() {
        if (transaction.type == Transaction.TRANSFER && assetKey == transaction.dst_asset) {
            return true;
        }
        return false;
    }

    public Transaction getTransaction() {
        _setupTransaction();
        return transaction;
    }


    // 値を Transaction に書き戻す
    private void _setupTransaction() {
        if (transaction.type == Transaction.ADJ) {
            transaction.balance = balance;
            transaction.hasBalance = true;
        } else {
            transaction.hasBalance = false;
            if (isDstAsset()) {
                transaction.value = -value;
            } else {
                transaction.value = value;
            }
        }
    }

    // TransactionViewController 用の値を返す
    public double evalue() {
        double ret = 0.0;

        switch (transaction.type) {
        case Transaction.INCOME:
            ret = value;
            break;
        case Transaction.OUTGO:
            ret = -value;
            break;
        case Transaction.ADJ:
            ret = balance;
            break;
        case Transaction.TRANSFER:
            if (isDstAsset()) {
                ret = value;
            } else {
                ret = -value;
            }
            break;
        }
	
        if (ret == 0.0) {
            ret = 0.0;	// avoid '-0'
        }
        return ret;
    }

    // 編集値をセット
    public void setEvalue(double v) {
        switch (transaction.type) {
        case Transaction.INCOME:
            value = v;
            break;
        case Transaction.OUTGO:
            value = -v;
            break;
        case Transaction.ADJ:
            balance = v;
            break;
        case Transaction.TRANSFER:
            if (isDstAsset()) {
                value = v;
            } else {
                value = -v;
            }
            break;
        }
    }

    // 種別変更
    //   type のほか、transaction の dst_asset, asset, value も調整する
    public boolean changeType(int type, int assetKey, int dstAssetKey) {
        if (type == Transaction.TRANSFER) {
            if (dstAssetKey == this.assetKey) {
                // 自分あて転送は許可しない
                // ### TBD
                return false;
            }

            transaction.type = Transaction.TRANSFER;
            setDstAsset(dstAssetKey);
        } else {
            // 資産間移動でない取引に変更した場合、強制的に指定資産の取引に変更する
            double ev = evalue();
            transaction.type = type;
            transaction.asset = assetKey;
            transaction.dst_asset = -1;
            setEvalue(ev);
        }
        return true;
    }

    // 転送先資産のキーを返す
    public int dstAsset() {
        if (transaction.type != Transaction.TRANSFER) {
            //ASSERT(false);
            return -1;
        }

        if (isDstAsset()) {
            return transaction.asset;
        }

        return transaction.dst_asset;
    }

    public void setDstAsset(int assetKey) {
        if (transaction.type != Transaction.TRANSFER) {
            //ASSERT(false);
            return;
        }

        if (isDstAsset()) {
            transaction.asset = assetKey;
        } else {
            transaction.dst_asset = assetKey;
        }
    }

    public Object clone() {
        AssetEntry e = new AssetEntry();
        e.assetKey = assetKey;
        e.value = value;
        e.balance = balance;
        e.transaction = (Transaction)transaction.clone();
        return e;
    }
}
