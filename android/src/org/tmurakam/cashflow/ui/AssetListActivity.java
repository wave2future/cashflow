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
//import android.widget.AdapterView.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class AssetListActivity extends Activity
	implements AdapterView.OnItemClickListener, AdapterView.OnItemLongClickListener 
{
	private ListView listView = null;
	AssetArrayAdapter arrayAdapter;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.assetlist);

		// initialization
		Config.init(getApplicationContext());
		DataModel.instance.load(getApplicationContext());

		// setup ListView
		listView = (ListView)findViewById(R.id.AssetList);
		listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);

		arrayAdapter = new AssetArrayAdapter(this);
		listView.setAdapter(arrayAdapter);
		listView.setOnItemClickListener(this);
		listView.setOnItemLongClickListener(this);

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
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
	}

	@Override
	public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
		return true;
	}

	class AssetArrayAdapter extends ArrayAdapter<Asset> {
		private LayoutInflater inflater;

		public AssetArrayAdapter(Context context){
			super(context, R.layout.assetlist_row);
			inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		}

		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = inflater.inflate(R.layout.assetlist_row, null);

				final Asset as = this.getItem(position);
				if (as != null) {
					TextView tv;

					tv = (TextView)convertView.findViewById(R.id.AssetListRowText);
					tv.setText(as.name);
				
					//...
				}
			}
			return convertView;
		}
	}
}
