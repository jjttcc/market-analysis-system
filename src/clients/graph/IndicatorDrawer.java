package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data tuples
 */
abstract public class IndicatorDrawer extends Drawer {

	IndicatorDrawer(Drawer mktd) { _market_drawer = mktd; }

	public int drawing_stride() { return 1; }

	public Object data() { return _data; }

	public String[] dates() { return _market_drawer.dates(); }

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

	public void set_data(Object d) { _data = (double[]) d; }

	protected int[] x_values() {
		return _market_drawer.x_values();
	}

	protected int first_date_index() {
		return Utilities.index_at_date(_indicator_dates[0], dates(), 1);
	}

	protected double _data[];
	protected String[] _indicator_dates;
	protected Drawer _market_drawer;
}
x
