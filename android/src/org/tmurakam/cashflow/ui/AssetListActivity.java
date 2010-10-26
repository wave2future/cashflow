// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.app.*;
import android.os.*;

import org.tmurakam.cashflow.*;
import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class AssetListActivity extends Activity
    implements AdapterView.OnItemClickListner, AdapterView.OnItemLongClickListener 
{
    private ListView listView = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.assetList);

        // initialization
        Config.initialize(this);
        DataModel.load();


        // setup ListView
        listView = (ListView)findViewById(R.id.listView);
        listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);

        arrayAdapter = new AssetArrayAdapter(this, hogelayout);
        listView.setAdapter(arrayAdapter);
        listView.setOnItemClickListenr(this);
        listView.setOnItemLongClickListener(this);

        // setup menu
        // TBD

        reload();
    }

    public void reload() {
        DataModel.getLedger().rebuild();

        arrayAdapter.clear();
        for (Asset as in DataModel.getLedger().assets) { 
            arrayAdapter.add(as);
        }
    }

    // OnItemClickListener
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
    }

    public void OnItemLongClick(AdapterView<?> parent, View view, int position, long id) {
    }
}

class AssetArrayAdapter extends ArrayAdapter<Asset> {
    private LayoutInflater inflater;

    public AssetArrayAdapter(Context context, List<Asset> items) {
        super(context, 0, items);
        inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public View getView(final int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.xxx, null);

            final Asset as = this.getItem(position);
            if (as != null) {
                TextView tv;

                tv = (TextView)convertView.findViewById(R.id.assetRowName);
                tv.setText(as.name);
                
                // ...
            }
        }
        return convertView;
    }
}
