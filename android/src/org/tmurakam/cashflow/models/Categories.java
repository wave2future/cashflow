// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.models;

import java.util.*;

import org.tmurakam.cashflow.ormapper.*;

public class Categories {
	private ArrayList<Category> categories = null;

	public void reload() {
		categories = Category.find_cond("ORDER BY sorder");
	}

	public String[] getCategoryStrings() {
		int n = categories.size();
		String[] a = new String[n];
		int i = 0;
		for (Category c : categories) {
			a[i++] = c.name;
		}
		return a;
	}
	
	public int categoryCount() {
		return categories.size();
	}

	public Category categoryAtIndex(int n) {
		return (Category)categories.get(n);
	}

	public int categoryIndexWithKey(int key) {
		int i = 0;
		for (Category c : categories) {
			if (c.pid == key) {
				return i;
			}
			i++;
		}
		return -1;
	}


	public String categoryStringWithKey(int key) {
		int idx = categoryIndexWithKey(key);
		if (idx < 0) {
			return "";
		}
		Category c = (Category)categories.get(idx);
		return c.name;
	}

	public Category addCategory(String name) {
		Category c = new Category();
		c.name = name;
		categories.add(c);

		renumber();

		c.insert();
		return c;
	}

	public void updateCategory(Category category) {
		category.update();
	}

	public void deleteCategoryAtIndex(int index) {
		Category c = (Category)categories.get(index);
		c.delete();

		categories.remove(index);
	}

	public void reorderCategory(int from, int to) {
		Category c = (Category)categories.get(from);
		categories.remove(from);
		categories.add(to, c);

		renumber();
	}

	private void renumber() {
		int i, max = categories.size();

		for (i = 0; i < max; i++) {
			Category c = (Category)categories.get(i);
			c.sorder = i;
			c.update();
		}
	}
}
