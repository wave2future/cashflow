// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ui;

//import java.lang.*;
import java.util.*;

import android.app.*;
import android.os.*;
import android.content.*;
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
		// date
		dateButton.setText(DataModel.dateFormat.format(editingEntry.transaction.date));

		// type
		typeSpinner.setSelection(editingEntry.transaction.type);
		
		// value
		double evalue = editingEntry.evalue();
		amountButton.setText(CurrencyManager.formatCurrency(evalue));
			
		// desc
		descEdit.setText(editingEntry.transaction.description);
				
	    // category
		int categoryIndex = DataModel.getCategories().categoryIndexWithKey(editingEntry.transaction.category);
		categorySpinner.setSelection(categoryIndex);

	    // memo
		memoEdit.setText(editingEntry.transaction.memo);
	}
	
	/**
	 * 日付設定
	 */
	public void onClickDate(View view) {
		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(editingEntry.transaction.date);
		
		DatePickerDialog d = new DatePickerDialog(this, this, cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DATE));
		d.show();
	}
	
	public void onDateSet(DatePicker view, int yy, int mm, int dd) {
		Calendar cal = Calendar.getInstance();
		cal.setTimeInMillis(editingEntry.transaction.date);
		cal.set(Calendar.YEAR, yy);
		cal.set(Calendar.MONTH, mm);
		cal.set(Calendar.DATE, dd);
		editingEntry.transaction.date = cal.getTimeInMillis();

		isModified = true;
		updateUI();
	}
	
	/**
	 * 種別 / 費目(カテゴリ)選択コールバック
	 */
	public void OnItemSelected(AdapterView<?> parent, View v, int position, long id) {
		if (v == typeSpinner) {
			// 種別
			editingEntry.transaction.type = position;
			switch (editingEntry.transaction.type) {
			case Transaction.ADJ:
				editingEntry.transaction.description = getResources().getString(R.string.adjustment);
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
			editingEntry.transaction.category = c.pid;
			isModified = true;
		}
	}
	
	/**
	 * 金額設定
	 */
	public void onClickAmount(View view) {
		// TBD
	}
	
	/**
	 * 保存処理
	 */
	public void onSave(View v) {
	    //editingEntry.transaction.asset = asset.pkey;

	    if (transactionIndex < 0) {
	    	asset.insertEntry(editingEntry);
	    } else {
	    	asset.replaceEntryAtIndex(transactionIndex, editingEntry);
	        //[asset sortByDate];
	    }

	    editingEntry = null;
	    setResult(0); // ok
	}

	public void onCancel(View v) {
	    if (isModified) {
	    	// TBD
	    	/*
	        asCancelTransaction =
	            [[UIActionSheet alloc]
	                initWithTitle:NSLocalizedString(@"Save this transaction?", @"")
	                delegate:self
	             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
	                destructiveButtonTitle:nil
	                otherButtonTitles:NSLocalizedString(@"Yes", @""), NSLocalizedString(@"No", @""), nil];
	        asCancelTransaction.actionSheetStyle = UIActionSheetStyleDefault;
	        [asCancelTransaction showInView:self.view];
	        [asCancelTransaction release];
	        */
	    	setResult(-1);
	    } else {
	    	setResult(-1);
	    }
	}
}

/*
#pragma mark EditView delegates

- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    isModified = YES;

    [editingEntry setEvalue:vc.value];
    [self _dismissPopover];
}

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

- (void)editMemoViewChanged:(EditMemoViewController*)vc identifier:(int)id
{
    isModified = YES;

    editingEntry.transaction.memo = vc.text;
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

#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
*/
