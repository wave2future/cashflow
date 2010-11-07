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

public class TransactionActivity extends Activity implements DatePickerDialog.OnDateSetListener
{
	private Asset asset;
	private int transactionIndex;
	private AssetEntry editingEntry;
	
	private Button dateButton;
	private Spinner typeSpinner;
	private EditText amountEdit;
	private AutoCompleteTextView descEdit;
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
		amountEdit = (EditText)findViewById(R.id.AmountEdit);
		descEdit = (AutoCompleteTextView)findViewById(R.id.DescEdit);
		memoEdit = (AutoCompleteTextView)findViewById(R.id.MemoEdit);
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
		amountEdit.setText(CurrencyManager.formatCurrency(evalue));
			
		// desc
		descEdit.setText(editingEntry.transaction.description);
				
	    // category
		// DataModel.getCategories().categoryStringWithKey(editingEntry.transaction.category);

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

		updateUI();
	}
}

/*
    typeArray = [[NSArray alloc] initWithObjects:
                                     NSLocalizedString(@"Payment", @""),
                                 NSLocalizedString(@"Deposit", @""),
                                 NSLocalizedString(@"Adjustment", @"Balance adjustment"),
                                 NSLocalizedString(@"Transfer", @""),
                                 nil];

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL hideDelButton = (transactionIndex >= 0) ? NO : YES;
	
    delButton.hidden = hideDelButton;
    delPastButton.hidden = hideDelButton;
		
    [[self tableView] reloadData];
}



///////////////////////////////////////////////////////////////////////////////////
// 値変更処理

#pragma mark UITableViewDelegate

// セルをクリックしたときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = self.navigationController;

    UIViewController *vc = nil;
    EditDateViewController *editDateVC;
    EditTypeViewController *editTypeVC; // type
    CalculatorViewController *calcVC;
    EditDescViewController *editDescVC;
    EditMemoViewController *editMemoVC; // memo
    CategoryListViewController *editCategoryVC;

    // view を表示

    switch (indexPath.row) {
    case ROW_DATE:
        editDateVC = [[[EditDateViewController alloc] init] autorelease];
        editDateVC.delegate = self;
        editDateVC.date = editingEntry.transaction.date;
        vc = editDateVC;
        break;

    case ROW_TYPE:
        editTypeVC = [[[EditTypeViewController alloc] init] autorelease];
        editTypeVC.delegate = self;
        editTypeVC.type = editingEntry.transaction.type;
        editTypeVC.dst_asset = [editingEntry dstAsset];
        vc = editTypeVC;
        break;

    case ROW_VALUE:
        calcVC = [[[CalculatorViewController alloc] init] autorelease];
        calcVC.delegate = self;
        calcVC.value = editingEntry.evalue;
        vc = calcVC;
        break;

    case ROW_DESC:
        editDescVC = [[[EditDescViewController alloc] init] autorelease];
        editDescVC.delegate = self;
        editDescVC.description = editingEntry.transaction.description;
        editDescVC.category = editingEntry.transaction.category;
        vc = editDescVC;
        break;

    case ROW_MEMO:
        editMemoVC = [EditMemoViewController
                         editMemoViewController:self
                         title:NSLocalizedString(@"Memo", @"") 
                         identifier:0];
        editMemoVC.text = editingEntry.transaction.memo;
        vc = editMemoVC;
        break;

    case ROW_CATEGORY:
        editCategoryVC = [[[CategoryListViewController alloc] init] autorelease];
        editCategoryVC.isSelectMode = YES;
        editCategoryVC.delegate = self;
        editCategoryVC.selectedIndex = [[DataModel categories] categoryIndexWithKey:editingEntry.transaction.category];
        vc = editCategoryVC;
        break;
    }
    
    if (IS_IPAD) { // TBD
        nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        
        if (currentPopoverController != nil) {
            [currentPopoverController release];
        }
        currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = cell.frame;
        [currentPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [nc pushViewController:vc animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (IS_IPAD && currentPopoverController != nil) {
        [currentPopoverController release];
        currentPopoverController = nil;
    }
}

- (void)_dismissPopover
{
    if (IS_IPAD) {
        if (currentPopoverController != nil) {
            [currentPopoverController dismissPopoverAnimated:YES];
        }
        [self.tableView reloadData];
    }
}

#pragma mark EditView delegates

// delegate : 下位 ViewController からの変更通知
- (void)editDateViewChanged:(EditDateViewController *)vc
{
    isModified = YES;

    editingEntry.transaction.date = vc.date;
    [self _dismissPopover];
}

- (void)editTypeViewChanged:(EditTypeViewController*)vc
{
    isModified = YES;

    // autoPop == NO なので、自分で pop する
    [self.navigationController popToViewController:self animated:YES];

    if (![editingEntry changeType:vc.type assetKey:asset.pid dstAssetKey:vc.dst_asset]) {
        return;
    }

    switch (editingEntry.transaction.type) {
    case TYPE_ADJ:
        editingEntry.transaction.description = [typeArray objectAtIndex:editingEntry.transaction.type];
        break;

    case TYPE_TRANSFER:
        {
            Asset *from, *to;
            Ledger *ledger = [DataModel ledger];
            from = [ledger assetWithKey:editingEntry.transaction.asset];
            to = [ledger assetWithKey:editingEntry.transaction.dst_asset];

            editingEntry.transaction.description = 
                [NSString stringWithFormat:@"%@/%@", from.name, to.name];
        }
        break;

    default:
        break;
    }

    [self _dismissPopover];
}

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

- (void)categoryListViewChanged:(CategoryListViewController*)vc;
{
    isModified = YES;

    if (vc.selectedIndex < 0) {
        editingEntry.transaction.category = -1;
    } else {
        Category *c = [[DataModel categories] categoryAtIndex:vc.selectedIndex];
        editingEntry.transaction.category = c.pid;
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

- (void)saveAction
{
    //editingEntry.transaction.asset = asset.pkey;

    if (transactionIndex < 0) {
        [asset insertEntry:editingEntry];
    } else {
        [asset replaceEntryAtIndex:transactionIndex withObject:editingEntry];
        //[asset sortByDate];
    }

    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    if (isModified) {
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
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

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
