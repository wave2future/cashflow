// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ui;

import java.lang.*;
import java.util.*;

import android.app.*;
import android.os.*;
import android.content.*;
import android.text.format.DateFormat;
import android.view.*;
import android.widget.*;
import android.graphics.*;
import android.graphics.drawable.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class TransactionActivity extends Activity
{
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.transaction);
		
		Intent intent = getIntent();
		int assetId = intent.getIntExtra("AssetId", -1);
		int transactionIndex = intent.getIntExtra("TransactionIndex", -1);
	}
	
	public void onClickDate(View view) {
		DatePickerDialog d = new DatePickerDialog(this, null, 2010, 1, 1);
		d.show();
	}
}