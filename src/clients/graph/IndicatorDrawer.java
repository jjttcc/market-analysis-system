/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing indicator tuples
 */
abstract public class IndicatorDrawer extends Drawer {

	IndicatorDrawer(Drawer mktd) { _market_drawer = mktd; }

	public int drawing_stride() { return 1; }

	public Object data() { return _data; }

	public String[] dates() { return _market_drawer.dates(); }

	public String[] times() { return _market_drawer.times(); }

	public Drawer market_drawer() { return _market_drawer; }

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

	public void set_dates(String[] d) { _indicator_dates = d; }

	public void set_times(String[] t) { _indicator_times = t; }

	public void set_data(Object d) { _data = (double[]) d; }

	public void set_reference_values_needed(boolean b) {
		ref_values_needed = b;
	}

	protected boolean reference_lines_needed() {
		return false;
	}

	protected int[] x_values() {
		return _market_drawer.x_values();
	}

	protected int bar_width() {
		return _market_drawer.bar_width();
	}

	protected int first_date_index() {
		int result;
		String[] dates = dates();
		String[] times = times();

		result = Utilities.index_at_date(_indicator_dates[0], dates, 1, 0,
			dates.length - 1);
		if (result > 0 &&
				_indicator_times != null && _indicator_times.length > 0) {
			// Since the data is intraday, there are duplicate dates in
			// the dates array.  Find the first element of dates that
			// matches _indicator_dates[0].
			while (result > 0 && dates[result-1].equals(_indicator_dates[0])) {
				--result;
			}
			if (! _indicator_times[0].equals(times[result])) {
				// If _indicator_times[0] is less than times[result],
				// increment result until times[result] is the first time
				// of the following day.
				while (result < times.length &&
						_indicator_times[0].compareTo(times[result]) < 0) {
					++result;
				}
				result = Utilities.index_at_date(_indicator_times[0], times,
					1, result, times.length - 1);
			}
		}
		return result;
	}

	protected boolean reference_values_needed() {
		return ref_values_needed;
	}

	protected double _data[];
	protected String[] _indicator_dates;
	protected String[] _indicator_times;
	protected Drawer _market_drawer;
	boolean ref_values_needed;
}
