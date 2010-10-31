// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;

import org.tmurakam.cashflow.ormapper.*;

public class DescLRUManager {
	public static void addDescLRU(String description, int category) {
		Date now = new Date();
		addDescLRU(description, category, now);
	}

	public static void addDescLRU(String description, int category, Date date) {
		if (description == null || description.length() == 0) {
			return;
		}

		// find desc LRU from history
		String[] param = { description };
		ArrayList<Object> ary = DescLRU.instance.find_cond("WHERE description = ?", param);

		DescLRU lru;
		if (ary.size() > 0) {
			// update date
			lru = (DescLRU)ary.get(0);
		} else {
			lru = new DescLRU();
			lru.description = description;
		}
		lru.category = category;
		lru.lastUse = date;
		lru.save();
	}

	public static ArrayList<DescLRU> getDescLRUs(int category) {
		ArrayList<Object> a;

		if (category < 0) {
			// 全検索
			a = DescLRU.instance.find_cond("ORDER BY lastUse DESC LIMIT 100", null);
		} else {
			String[] param = { Integer.toString(category) };
			a = DescLRU.instance.find_cond("WHERE category = ? ORDER BY lastUse DESC LIMIT 100", param);
		}
		ArrayList<DescLRU> ary = new ArrayList<DescLRU>();
		for (Object o : a) {
			ary.add((DescLRU)o);
		}
		return ary;
	}

	/*
	  public static void gc() {
	  ArrayList<DescLRU> ary;

	  ary = DescLRU.find_cond("ORDER BY lastUse DESC LIMIT 1 OFFSET 100", null);
	  if (ary.size() > 0) {
	  DescLRU lru = ary.get(0);
	  String[] param = { date2str(lru.date) };
	  DescLRU.delete_cond("WHERE lastUse < ?", param);
	  }
	  }
	*/
}
