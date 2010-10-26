// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public  class Transaction extends TransactionBase implements Cloneable {
    public final static int OUTGO = 0;
    public final static int INCOME = 1;
    public final static int ADJ = 2;
    public final static int TRANSFER = 3;

    private boolean hasBalance;
    private double balance;

    public static TransactionBase allocator() {
	return new Transaction();
    }

    public Transaction() {
        this(new Date(), "", 0.0);

	if (Config.instance().dateTimeMode == Config.DateTimeModeDateOnly) {
	    // 時刻を 0:00:00 に設定
	    this.date.setHours(0);
	    this.date.setMinutes(0);
	    this.date.setSeconds(0);
	}
    }

    public Transaction(Date date, String description, double value) {
	this.asset = -1;
	this.dst_asset = -1;
	this.date = date;
	this.description = description;
	this.memo = "";
	this.value = value;
	this.type = 0;
	this.category = -1;
	this.pid = 0; // init
	this.hasBalance = false;
    }

    // deep copy
    @Override
    public Object clone() {
	try {
	    return super.clone();
	}
	catch (CloneNotSupportedException e) {
	    throw new InternalError(e.toString());
	}
    }

    public void insert() {
	super.insert();
	DescLRUManager.addDescLRU(description, category);
    }

    public void update() {
	super.update();
	DescLRUManager.addDescLRU(description, category);
    }

    public void updateWithoutUpdateLRU() {
	super.update();
    }
}

	
	
