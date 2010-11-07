// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ui;

import java.lang.*;
import java.util.*;

import android.app.*;
import android.os.*;
import android.content.*;
import android.view.*;
import android.view.LayoutInflater;
import android.widget.*;
import android.graphics.drawable.*;
//import android.widget.AdapterView.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class AssetListActivity extends Activity
	implements AdapterView.OnItemClickListener, AdapterView.OnItemLongClickListener 
{
	private ListView listView = null;
	private AssetArrayAdapter arrayAdapter;
	
	private Drawable iconCash;
	private Drawable iconBank;
	private Drawable iconCard;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.assetlist);

		// initialization
		Context ctx = getApplicationContext();
		AppConfig.init(ctx);
		Database.initialize(ctx);
		DataModel.instance.load(ctx);
		
		// setup ListView
		listView = (ListView)findViewById(R.id.AssetList);
		listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);

		arrayAdapter = new AssetArrayAdapter(this);
		listView.setAdapter(arrayAdapter);
		listView.setOnItemClickListener(this);
		listView.setOnItemLongClickListener(this);

		// load icons
		iconCash = getResources().getDrawable(R.drawable.cash);
		iconBank = getResources().getDrawable(R.drawable.bank);
		iconCard = getResources().getDrawable(R.drawable.card);
		
		// setup menu
		// TBD

		reload();
	}

	public void reload() {
		DataModel.getLedger().rebuild();

		arrayAdapter.clear();
		for (Asset as : DataModel.getLedger().assets) { 
			arrayAdapter.add(as);
		}
	}

	// OnItemClickListener
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		Intent intent = new Intent(getApplicationContext(), TransactionListActivity.class);
		Asset as = DataModel.getLedger().assets.get(position);
		intent.putExtra("AssetId", as.pid);
		startActivity(intent);
	}

	public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
		return true;
	}

	class AssetArrayAdapter extends ArrayAdapter<Asset> {
		private LayoutInflater inflater;

		public AssetArrayAdapter(Context context){
			super(context, R.layout.assetlist_row, R.id.AssetListRowText, new ArrayList<Asset>());
			inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		}

		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = inflater.inflate(R.layout.assetlist_row, parent, false);
			}

			final Asset as = this.getItem(position);
			if (as == null) return convertView; // TBD
			
			TextView tv = (TextView)convertView.findViewById(R.id.AssetListRowText);
			tv.setText(as.name);
					
			ImageView iv = (ImageView)convertView.findViewById(R.id.AssetListRowIcon);
			Drawable d = iconCash;
			switch (as.type) {
			case Asset.CASH:
				d = iconCash;
				break;
			case Asset.BANK:
				d = iconBank;
				break;
			case Asset.CARD:
				d = iconCard;
				break;
			}
			iv.setImageDrawable(d);
			
			tv = (TextView)convertView.findViewById(R.id.AssetListRowBalance);
			tv.setText("¥0");

			return convertView;
		}
	}
}
