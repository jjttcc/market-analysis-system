/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.util.*;

/**
 *  Drawer of market basic data - open, high, low, close, etc.
 */
abstract public class MarketDrawer extends BasicDrawer {

// Access

	// Number of fields in each tuple
	public int drawing_stride() {
		return Stride;
	}

	public ArrayList data() { return data; }

	// The dates associated with the principle (market) data
	public ArrayList dates() { return dates; }

	// The times associated with the principle (market) data
	public ArrayList times() { return times; }

	public MarketDrawer market_drawer() { return this; }

	// Number of elements in the data
	public int data_length() {
		int result;
		if (data() != null) {
			result = data.size();
		} else {
			result = 0;
		}
//!!!!!:
System.out.println("MKT DRW returning data length() of " + result);
		return result;
	}

	// Postcondition: result != null
	public int[] x_values() {
		int[] result;
		if (x_values == null || x_values.length != tuple_count()) {
			initialize_x_values();
		}
		result = x_values;
		return result;
	}

// Element change

	// Set the dates.
	public void set_dates(ArrayList d) {
		dates = d;
//!!!!:
System.out.println("MD dates set with size: " + d.size());
		}

	// Set the times.
	public void set_times(ArrayList t) { times = t; }

	// Set data to `d'.
	public void set_data(ArrayList d) { data = d; }

	public void set_reference_values_needed(boolean b) {
		ref_values_needed = b;
	}

// Implementation

	// Initialize `x_values'.
	// Postcondition: x_values != null && x_values.length == tuple_count()
	protected void initialize_x_values() {
		x_values = new int[tuple_count()];
//!!!:
System.out.println("In " + getClass().getName() +
", initialize_x_values called;\nx_values.length, data.size():" +
x_values.length + ", " + data.size());
System.out.println("dates.size(): " + dates.size());
System.out.println("times.size(): " + times.size());
		if (! (x_values != null && x_values.length == tuple_count())) {
			throw new Error("Postcondition violated:\n" +
				"x_values != null && x_values.length == tuple_count()");
		}
	}

	protected int bar_width() {
		return bar_width;
	}

	protected boolean reference_values_needed() {
		return ref_values_needed;
	}

	protected boolean reference_lines_needed() {
		return true;
	}

// Implementation - attributes

	protected int x_values[];
	protected int bar_width;
	protected ArrayList data;		// Double
	protected ArrayList dates;		// String
	protected ArrayList times;		// String
	protected final int Stride = 4;
	boolean ref_values_needed;
}
