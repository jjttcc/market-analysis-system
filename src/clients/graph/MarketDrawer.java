/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Drawer of market data
 */
abstract public class MarketDrawer extends Drawer {

	// Number of fields in each tuple
	public int drawing_stride() {
		return Stride;
	}

	public Object data() { return _data; }

	// The dates associated with the principle (market) data
	public String[] dates() { return _dates; }

	public Drawer market_drawer() { return this; }

	// Number of elements in the data
	public int data_length() {
		int result;
		if (data() != null) {
			result = _data.length;
		} else {
			result = 0;
		}
		return result;
	}

	// Set the dates.
	public void set_dates(String[] d) { _dates = d; }

	// Set data to `d'.
	public void set_data(Object d) { _data = (double[]) d; }

	protected int[] x_values() {
		return _x_values;
	}

	protected int _x_values[];
	protected double _data[];
	protected String[] _dates;
	protected final int Stride = 4;
}
