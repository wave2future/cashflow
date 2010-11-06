// -*-  Mode:Java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
package org.tmurakam.cashflow.test;

import org.tmurakam.cashflow.ormapper.*;

import android.test.AndroidTestCase;

import java.util.*;

public class DatabaseTest extends AndroidTestCase {
	
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	public void testStr2Date() {
		long d = Database.str2date("20101231123456"); // GMT
		
		Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		cal.set(2010, Calendar.DECEMBER, 31, 12, 34, 56); // GMT
		cal.set(Calendar.MILLISECOND, 0);
		assertEquals(cal.getTimeInMillis(), d);
	}
	
	public void testDate2Str() {
		Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		cal.set(2010, Calendar.DECEMBER, 31, 12, 34, 56); // GMT
		cal.set(Calendar.MILLISECOND, 0);
		long d = cal.getTimeInMillis();
		
		assertEquals("20101231123456", Database.date2str(d));
	}
}
