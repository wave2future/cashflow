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
//import android.widget.AdapterView.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.ui.AssetListActivity.AssetArrayAdapter;
import org.tmurakam.cashflow.models.*;

public class TransactionListActivity extends Activity
	implements AdapterView.OnItemClickListener, AdapterView.OnItemLongClickListener 
{
	private ListView listView;
	private Asset asset;
	private AssetEntryArrayAdapter arrayAdapter;
	private java.text.DateFormat dateFormat; 
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.transactionlist);
		
		int assetId = getIntent().getIntExtra("AssetIndex", -1);
		asset = DataModel.getLedger().assetWithKey(assetId);

		setTitle(asset.name);
	
		dateFormat = android.text.format.DateFormat.getDateFormat(getApplicationContext());
 		
		// setup ListView
		listView = (ListView)findViewById(R.id.TransactionList);
		listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
		
		arrayAdapter = new AssetEntryArrayAdapter(this);
		listView.setAdapter(arrayAdapter);
		listView.setOnItemClickListener(this);
		listView.setOnItemLongClickListener(this);
		
		reload();
	}
	
	public void reload() {
		updateBalance();

		int count = asset.entryCount();
		arrayAdapter.clear();
		for (int i = 0; i < count; i++) {
			arrayAdapter.add(asset.entryAt(i));
		}
		// test
		if (true) {
			Transaction t = new Transaction();
			t.description = "dinner";
			t.value = 2000;
			t.balance = 8000;
			t.date = new Date().getTime();
			AssetEntry e = new AssetEntry();
			e.transaction = t;
			e.value = 2000;
			e.balance = 8000;
			for (int i = 0; i < 30; i++) {
				arrayAdapter.add(e);
			}
		}
		
		// 初期残高セル
		AssetEntry e = new AssetEntry();
		e.transaction = null;
		e.value = asset.initialBalance;
		arrayAdapter.add(e);
	}
	
	class AssetEntryArrayAdapter extends ArrayAdapter<AssetEntry> {
		private LayoutInflater inflater;

		public AssetEntryArrayAdapter(Context context){
			super(context, R.layout.transactionlist_row, R.id.TransactionListRowText, new ArrayList<AssetEntry>());
			inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		}

		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = inflater.inflate(R.layout.transactionlist_row, parent, false);
			}

			final AssetEntry e = this.getItem(position);
			if (e == null) return convertView; // TBD
			
			TextView tv;
			tv = (TextView)convertView.findViewById(R.id.TransactionListRowText);
			if (e.transaction == null) {
				tv.setText("Initial balance");
			} else {
				tv.setText(e.transaction.description);
			}

			tv = (TextView)convertView.findViewById(R.id.TransactionListRowDate);
			if (e.transaction == null) {
				tv.setText("");
			} else {
				tv.setText(dateFormat.format(e.transaction.date));
			}
					
			tv = (TextView)convertView.findViewById(R.id.TransactionListRowValue);
			if (e.value >= 0) {
				tv.setTextColor(Color.BLUE);
			} else {
				tv.setTextColor(Color.RED);
			}
			tv.setText(CurrencyManager.formatCurrency(e.value));
			
			tv = (TextView)convertView.findViewById(R.id.TransactionListRowBalance);
			if (e.transaction == null) {
				tv.setText("");
			} else {
				tv.setText("balance " + CurrencyManager.formatCurrency(e.balance));
			}

			return convertView;
		}
	}

	private void updateBalance() {
		double lastBalance = asset.getLastBalance();
		//barBalanceLabel.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Balance", @""), bstr];
    }

	private void showHelp() {
		/*
		InfoVC *v = [[[InfoVC alloc] init] autorelease];
		//[self.navigationController pushViewController:v animated:YES];

		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:v];
		[self presentModalViewController:nc animated:YES];
		[nc release];
		*/
	}

	public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
		return true;
	}
	
	//
	// セルをクリックしたときの処理
	//
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		/*
	    int idx = [self entryIndexWithIndexPath:indexPath];
	    if (idx == -1) {
	        // initial balance cell
	        CalculatorViewController *v = [[[CalculatorViewController alloc] init] autorelease];
	        v.delegate = self;
	        v.value = asset.initialBalance;

	        UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:v] autorelease];
	        
	        if (!IS_IPAD) {
	            [self presentModalViewController:nv animated:YES];
	        } else {
	            if (self.popoverController) {
	                [self.popoverController dismissPopoverAnimated:YES];
	            }
	            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:nv] autorelease];
	            [self.popoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:self.view
	               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	        }
	    } else if (idx >= 0) {
	        // transaction view を表示
	        TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
	        vc.asset = self.asset;
	        [vc setTransactionIndex:idx];
	        [self.navigationController pushViewController:vc animated:YES];
	    }
	    */
	}

	// 初期残高変更処理
	private void calculatorViewChanged() {
		/*
		asset.initialBalance = vc.value;
		[asset updateInitialBalance];
		[asset rebuild];
		[self reload];
		*/
	}

	// 新規トランザクション追加
	private void addTransaction() {
		if (asset == null) return;

		/*
		TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
		vc.asset = self.asset;
		[vc setTransactionIndex:-1];
		[self.navigationController pushViewController:vc animated:YES];
		*/
	}
}

/*
// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (asset == nil) return;
    
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [tableView setEditing:editing animated:animated];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath];

    if (entryIndex < 0) {
        // initial balance cell : do not delete!
        return;
    }
	
    if (style == UITableViewCellEditingStyleDelete) {
        [asset deleteEntryAt:entryIndex];
	
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateBalance];
        [self.tableView reloadData];
    }

    if (IS_IPAD) {
        [splitAssetListViewController reload];
    }
}

#pragma mark Action sheet handling

// action sheet
- (void)doAction:(id)sender
{
    if (asDisplaying) return;
    asDisplaying = YES;
    
    UIActionSheet *as = 
        [[UIActionSheet alloc]
         initWithTitle:@"" 
         delegate:self 
         cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
         destructiveButtonTitle:nil otherButtonTitles:
         NSLocalizedString(@"Weekly Report", @""),
         NSLocalizedString(@"Monthly Report", @""),
         NSLocalizedString(@"Export", @""),
         NSLocalizedString(@"Backup", @""),
         NSLocalizedString(@"Config", @""),
         nil];
    if (IS_IPAD) {
        [as showFromBarButtonItem:barActionButton animated:YES];
    } else {
        [as showInView:[self view]];
    }
    [as release];
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ReportViewController *reportVC;
    ExportVC *exportVC;
    ConfigViewController *configVC;
    Backup *backup;
    
    UIViewController *vc;
    UIModalPresentationStyle modalPresentationStyle = UIModalPresentationPageSheet;
    
    asDisplaying = NO;
    
    switch (buttonIndex) {
        case 0:
        case 1:
            reportVC = [[[ReportViewController alloc] init] autorelease];
            if (buttonIndex == 0) {
                reportVC.title = NSLocalizedString(@"Weekly Report", @"");
                [reportVC generateReport:REPORT_WEEKLY asset:asset];
            } else {
                reportVC.title = NSLocalizedString(@"Monthly Report", @"");
                [reportVC generateReport:REPORT_MONTHLY asset:asset];
            }
            vc = reportVC;
            break;
			
        case 2:
            exportVC = [[[ExportVC alloc] initWithAsset:asset] autorelease];
            vc = exportVC;
            modalPresentationStyle = UIModalPresentationFormSheet;
            break;
            
        case 3:
            backup = [[Backup alloc] init];
            [backup execute];
            return; // do not release back instance here!
            
        case 4:
            configVC = [[[ConfigViewController alloc] init] autorelease];
            vc = configVC;
            modalPresentationStyle = UIModalPresentationFormSheet;
            break;
            
        default:
            return;
    }

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if (IS_IPAD) {
        nv.modalPresentationStyle = modalPresentationStyle;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentModalViewController:nv animated:YES];
    [nv release];
}
*/

