/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.util.*;

/**
 *  Drawer of market basic data - open, high, low, close, etc.
 */
abstract public class MarketDrawer extends BasicDrawer {

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
		return result;
	}

	// Set the dates.
	public void set_dates(ArrayList d) { dates = d; }

	// Set the times.
	public void set_times(ArrayList t) { times = t; }

	// Set data to `d'.
	public void set_data(ArrayList d) { data = d; }

	public void set_reference_values_needed(boolean b) {
		ref_values_needed = b;
	}

	public int[] x_values() {
		return x_values;
	}

	protected int bar_width() {
		return _bar_width;
	}

	protected boolean reference_values_needed() {
		return ref_values_needed;
	}

	protected boolean reference_lines_needed() {
		return true;
	}

	protected int x_values[];
	protected int _bar_width;
	protected ArrayList data;		// double
	protected ArrayList dates;		// String
	protected ArrayList times;		// String
	protected final int Stride = 4;
	boolean ref_values_needed;
}
