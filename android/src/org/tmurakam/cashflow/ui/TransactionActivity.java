// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ui;

//import java.lang.*;
import java.util.*;

import android.app.*;
import android.os.*;
import android.content.*;
import android.content.res.*;
//import android.text.format.DateFormat;
import android.view.*;
import android.widget.*;
//import android.graphics.*;
//import android.graphics.drawable.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class TransactionActivity extends Activity 
	implements DatePickerDialog.OnDateSetListener,
	AdapterView.OnItemSelectedListener
	
{
	private Asset asset;
	private int transactionIndex;
	private AssetEntry editingEntry;
	
	private boolean isModified;
	
	private Button dateButton;
	private Spinner typeSpinner;
	private Button amountButton;
	private AutoCompleteTextView descEdit;
	private Spinner categorySpinner;
	private AutoCompleteTextView memoEdit;

	private final int SET_AMOUNT = 0;
	private final int SET_DESC = 1;
	private final int SET_MEMO = 2;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.transaction);

		// Intent から asset, transaction を取り出しておく
		Intent intent = getIntent();
		int assetId = intent.getIntExtra("AssetId", -1);
		asset = DataModel.getLedger().assetWithKey(assetId);
		transactionIndex = intent.getIntExtra("TransactionIndex", -1);
		loadTransaction();

		// UI components
		dateButton = (Button)findViewById(R.id.DateButton);
		typeSpinner = (Spinner)findViewById(R.id.TypeSpinner);
		amountButton = (Button)findViewById(R.id.AmountButton);
		descEdit = (AutoCompleteTextView)findViewById(R.id.DescEdit);
		categorySpinner = (Spinner)findViewById(R.id.CategorySpinner);
		memoEdit = (AutoCompleteTextView)findViewById(R.id.MemoEdit);
		
		// category adapter
		String[] cs = DataModel.getCategories().getCategoryStrings();
		ArrayAdapter<String> aa = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, cs);
		aa.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		categorySpinner.setAdapter(aa);
		
		// TBD
		
		updateUI();
	}
	
	private void loadTransaction() {
		// 処理するトランザクションをロードしておく
		editingEntry = null;
		if (transactionIndex < 0) {
			// 新規トランザクション
			editingEntry = new AssetEntry(null, asset);
		} else {
			// 変更
			AssetEntry orig = asset.entryAt(transactionIndex);
			editingEntry = (AssetEntry)orig.clone();
		}
    }

	private void updateUI() {
		Transaction t = editingEntry.transaction();
		
		// date
		dateButton.setText(DataModel.dateFormat.format(t.date));

		// type
		typeSpinner.setSelection(t.type);
		
		// value
		double evalue = editingEntry.evalue();
		amountButton.setText(CurrencyManager.formatCurrency(evalue));
			
		// desc
		descEdit.setText(t.description);
				
	    // category
		int categoryIndex = DataModel.getCategories().categoryIndexWithKey(t.category);
		categorySpinner.setSelection(categoryIndex);

	    // memo
		memoEdit.setText(t.memo);
	}
	
	/**
	 * 日付設定
	 */
	public void onClickDate(View view) {
		Transaction t = editingEntry.transaction();
		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(t.date);
		
		DatePickerDialog d = new DatePickerDialog(this, this, cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DATE));
		d.show();
	}
	
	public void onDateSet(DatePicker view, int yy, int mm, int dd) {
		Transaction t = editingEntry.transaction();
		
		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(t.date);
		cal.set(Calendar.YEAR, yy);
		cal.set(Calendar.MONTH, mm);
		cal.set(Calendar.DATE, dd);
		t.date = cal.getTimeInMillis();

		isModified = true;
		updateUI();
	}
	
	/**
	 * 種別 / 費目(カテゴリ)選択コールバック
	 */
	public void onItemSelected(AdapterView<?> parent, View v, int position, long id) {
		if (v == typeSpinner) {
			// 種別
			Transaction t = editingEntry.transaction();
			t.type = position;
			switch (t.type) {
			case Transaction.ADJ:
				t.description = getResources().getString(R.string.adjustment);
				break;
				
			case Transaction.TRANSFER:
				// TBD : この場で移動先選択用のダイアログを出す必要がある。
				// 以下の処理は、そのあとで実施すべきもの
				/*
				Ledger ledger = DataModel.getLedger();
				Asset from = ledger.assetWithKey(editingEntry.transaction.asset);
	            Asset to = ledger.assetWithKey(editingEntry.transaction.dst_asset);

	            editingEntry.transaction.description =
	            	String.format("%s/%s", from.name, to.name);
	            	*/
	            break;
			}
			isModified = true;
		}
		else if (v == categorySpinner) {
			// カテゴリ
			Category c = DataModel.getCategories().categoryAtIndex(position);
			editingEntry.transaction().category = c.pid;
			isModified = true;
		}
	}
	public void onNothingSelected(AdapterView<?> parent) {
		// do nothing
	}
	
	/**
	 * 金額設定
	 */
	public void onClickAmount(View view) {
		Intent i = new Intent(this, CalculatorActivity.class);
		i.putExtra(CalculatorActivity.TAG_VALUE, editingEntry.evalue());
		startActivityForResult(i, SET_AMOUNT);
	}

	/**
	 * 子 Activity の終了通知
	 */
	protected void onActivityResult(int req, int result, Intent data) {
		if (result != RESULT_OK) return;

		switch (req) {
		case SET_AMOUNT:
			isModified = true;
			editingEntry.setEvalue(data.getDoubleExtra(CalculatorActivity.TAG_VALUE, 0));
			break;

		case SET_DESC:
		case SET_MEMO:
			// not yet
			break;
		}

		updateUI();
	}

	/**
	 * 保存処理
	 */
	public void onSave(View v) {
		getTextField();

	    if (transactionIndex < 0) {
	    	asset.insertEntry(editingEntry);
	    } else {
	    	asset.replaceEntryAtIndex(transactionIndex, editingEntry);
	        //[asset sortByDate];
	    }

	    editingEntry = null;
	    setResult(RESULT_OK);
	    finish();
	}

	public void onCancel(View v) {
		getTextField();

		if (isModified) {
			// 保存確認
			Resources res = getResources();

			AlertDialog.Builder b = new AlertDialog.Builder(this);
			//b.setTitle("");
			b.setMessage(res.getText(R.string.save_this_transaction));
			b.setPositiveButton(res.getText(R.string.yes), new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					setResult(RESULT_OK);
					finish();
				}
			});
			b.setNegativeButton(res.getText(R.string.no), new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					setResult(RESULT_CANCELED);
					finish();
				}
			});
			b.setCancelable(true);
			b.show();
	    } else {
	    	setResult(RESULT_CANCELED);
		    finish();
	    }
	}
	
	// back ボタンで閉じようとする場合の処理
	//@Override  // this requires API level 5!
	//public void onBackPressed() {  
	//	onCancel(null);
	//}
	
	private void getTextField() {
		Transaction t = editingEntry.transaction();

		String desc = descEdit.getText().toString();
		if (!desc.equals(t.description)) {
			t.description = desc;
			isModified = true;
		}
				
		String memo = memoEdit.getText().toString();
		if (!memo.equals(t.memo)) {
			t.memo = memo;
			isModified = true;
		}
	}
}

/*
#pragma mark EditView delegates

- (void)editDescViewChanged:(EditDescViewController *)vc
{
    isModified = YES;

    editingEntry.transaction.description = vc.description;

    if (editingEntry.transaction.category < 0) {
        // set category from description
        editingEntry.transaction.category = [[DataModel instance] categoryWithDescription:editingEntry.transaction.description];
    }
    [self _dismissPopover];
}

////////////////////////////////////////////////////////////////////////////////
// 削除処理

#pragma mark Deletion

- (void)delButtonTapped
{
    [asset deleteEntryAt:transactionIndex];
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)delPastButtonTapped
{
    asDelPast = [[UIActionSheet alloc]
                    initWithTitle:nil delegate:self
                    cancelButtonTitle:@"Cancel"
                    destructiveButtonTitle:NSLocalizedString(@"Delete with all past transactions", @"")
                    otherButtonTitles:nil];
    asDelPast.actionSheetStyle = UIActionSheetStyleDefault;
    [asDelPast showInView:self.view];
    [asDelPast release];
}

- (void)_asDelPast:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
         return; // cancelled;
    }

    AssetEntry *e = [asset entryAt:transactionIndex];
	
    NSDate *date = e.transaction.date;
    [asset deleteOldEntriesBefore:date];
	
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// 保存処理

#pragma mark Save action



- (void)_asCancelTransaction:(int)buttonIndex
{
    switch (buttonIndex) {
    case 0:
        // save
        [self saveAction];
        break;

    case 1:
        // do not save
        [self.navigationController popViewControllerAnimated:YES];
        break;

    case 2:
        // cancel
        break;
    }
}

#pragma mark ActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == asDelPast) {
        [self _asDelPast:buttonIndex];
    }
    else if (actionSheet == asCancelTransaction) {
        [self _asCancelTransaction:buttonIndex];
    }
}
*/
