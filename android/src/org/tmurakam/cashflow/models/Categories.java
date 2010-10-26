// -*-  Mode:java; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

package org.tmurakam.cashflow.models;

import java.lang.*;
import java.util.*;

import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.*;
import org.tmurakam.cashflow.models.*;

public class Categories {
    private ArrayList<Category> categories = null;

    publci void Categories() {
        categories = null;
    }

    public void reload() {
        categories = Category.find_cond("ORDER BY sorder");
    }

    public int categoryCount() {
        return categories.size();
    }


    public Category categoryAtIndex(int n) {
        return categories.get(n);
    }

    public int categoryIndexWithKey(int key) {
        int i, max = categories.size();

        for (i = 0; i < max; i++) {
            Category c = categories.get(i);
            if (c.pid == key) {
                return i;
            }
        }
        return -1;
    }


    public String categoryStringWithKey(int key) {
        int idx = categoryIndexWithKey(key);
        if (idx < 0) {
            return "";
        }
        Category c = categories.get(idx);
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
        Category c = categories.get(index);
        c.delete();

        categories.remove(index);
    }

    public void reorderCategory(int from, int to) {
        Category c = categories.get(from);
        categories.remove(from);
        categories.add(to, c);

	renumber();
    }

    private void renumber() {
        int i, max = categories.size();

        for (i = 0; i < max; i++) {
            Category c = categories.get(i);
            c.sorder = i;
            c.update();
        }
    }
}
