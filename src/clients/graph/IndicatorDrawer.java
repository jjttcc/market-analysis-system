/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.util.*;
import support.*;

/**
 *  Abstraction for drawing indicator tuples
 */
abstract public class IndicatorDrawer extends BasicDrawer {

	IndicatorDrawer(MarketDrawer mktd) {
		_market_drawer = mktd;
		lower_indicator = false;
	}

	public int drawing_stride() { return 1; }

	public Vector data() { return data; }

	public Vector dates() { return _market_drawer.dates(); }

	public Vector times() { return _market_drawer.times(); }

	public MarketDrawer market_drawer() { return _market_drawer; }

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

	public void set_dates(Vector d) { indicator_dates = d; }

	public void set_times(Vector t) { indicator_times = t; }

	public void set_data(Vector d) { data = d; }

	public void set_reference_values_needed(boolean b) {
		ref_values_needed = b;
	}

	public void set_lower(boolean b) {
		lower_indicator = b;
	}

	protected boolean is_lower() { return lower_indicator; }

	protected boolean reference_lines_needed() {
		return false;
	}

	public int[] x_values() {
		return _market_drawer.x_values();
	}

	// Precondition: _market_drawer != null
	protected int bar_width() {
		return _market_drawer.bar_width();
	}

	protected int first_date_index() {
		int result;
		Vector dates = dates();
		Vector times = times();

		if (indicator_dates.elementAt(0).equals(dates.elementAt(0))) {
			result = 0;
		} else {
			result = Utilities.index_at_date((String)
				indicator_dates.elementAt(0), dates, 1, 0, dates.size() - 1);
		}
		if (
				indicator_times != null && indicator_times.size() > 0) {
			// Since the data is intraday, there are duplicate dates in
			// the dates array.  Find the first element of dates that
			// matches indicator_dates.elementAt(0).
			while (result > 0 && dates.elementAt(result-1).equals(
					indicator_dates.elementAt(0))) {
				--result;
			}
			if (! indicator_times.elementAt(0).equals(
					times.elementAt(result))) {
				// If indicator_times.elementAt(0) is less than
				// times.elementAt(result), increment result until
				// times.elementAt(result) is the first time of the
				// following day.
				while (result < times.size() &&
						((String) indicator_times.elementAt(0)).compareTo(
							times.elementAt(result)) < 0) {
					++result;
				}
				result = first_time_match(indicator_times.elementAt(0),
					times, result);
			}
		}
		return result;
	}

	// The index of the first element of `times' beginning at
	// times.elementAt(startix) that matches `time'
	protected int first_time_match(Object time, Vector times, int startix) {
		int result = 0;
		for (int i = startix; i < times.size(); ++i) {
			if (((String) times.elementAt(i)).compareTo((String) time) == 0) {
				result = i;
				break;
			}
		}
		return result;
	}

// Hook routine implementations

	protected boolean reference_values_needed() {
		return ref_values_needed;
	}

// Implementation - attributes

	protected Vector data;				// double
	protected Vector indicator_dates;	// String
	protected Vector indicator_times;	// String
	protected MarketDrawer _market_drawer;
	protected boolean ref_values_needed;
	protected boolean lower_indicator;
}
