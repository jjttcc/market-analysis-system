/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing date-related data
 */
public class DateDrawer extends Drawer {

	// mkd is the associated market drawer and is_ind specifies whether
	// this DateDrawer is associated with indicator data.
	DateDrawer(Drawer mkd, boolean is_ind) {
		_market_drawer = mkd;
		is_indicator = is_ind;
		conf = Configuration.instance();
	}

	// The data to be drawn
	public Object data() { return _market_drawer.dates(); }

	// The dates associated with the principle (market) data
	public String[] dates() { return _market_drawer.dates(); }

	// The dates associated with the principle (market) data
	public String[] times() { return _market_drawer.times(); }

	public Drawer market_drawer() { return _market_drawer; }

	public int data_length() {
		int result;
		if (dates() != null) {
			result = dates().length;
		} else {
			result = 0;
		}
		return result;
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return 1; }

	public int[] x_values() {
		return _market_drawer.x_values();
	}

	protected final static int Max_months = 360, Max_years = 30;

	protected final static int Year_x_offset = 8, Year_y = 15;

	protected int Month_y;

	protected int Month_x_offset;

	// length of the month name
	protected int month_ln;

	/**
	* Draw a vertical line for each month in `_data' and years and month
	* names at the appropriate places.
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int mi, yi, i;
		int lastyear, lastmonth, year, month;
		IntPair months[] = new IntPair[Max_months],
			years[] = new IntPair[Max_years];
		int[] _x_values = x_values();
		String[] _data = dates();
		if (_data == null) return;

		Month_y = bounds.y + bounds.height - 15; Month_x_offset = 10;
		month_ln = 3;
		// Determine the first month and year in `_data'.
		year = Integer.valueOf(_data[0].substring(0,4)).intValue();
		month = Integer.valueOf(_data[0].substring(4,6)).intValue();
		// If the first date in `_data' is not "yyyymm01", it is not the
		// first day of the month; thus the `month' needs to be incremented
		// to the next month in `_data', since the first month is not complete.
		if (! _data[0].substring(6,8).equals ("01")) {
			if (month == 12) {
				month = 1;
				++year;
			} else {
				++month;
			}
		}
		lastyear =
			Integer.valueOf(_data[_data.length-1].substring(0,4)).intValue();
		lastmonth =
			Integer.valueOf(_data[_data.length-1].substring(4,6)).intValue();
		mi = 0; yi = 0;
		while (! (year == lastyear && month == lastmonth)) {
			int date_index;
			date_index = Utilities.index_at_date(
				first_date_at(year, month), _data, 1, 0, _data.length - 1);
			if (date_index < 0) {
				month = lastmonth;
				break;
			}
			months[mi] = new IntPair(month, date_index);
			if (month == 1) {
				years[yi] = new IntPair(year, months[mi].right());
				++yi;
			}
			if (month == 12) {
				month = 1;
				++year;
			} else {
				++month;
			}
			++mi;
		}
		// assert: year == lastyear && month == lastmonth
		months[mi] = new IntPair(month,
			Utilities.index_at_date(first_date_at(year, month), _data, 1, 0,
				_data.length - 1));
		if (month == 1) {
			years[yi] = new IntPair(year, months[mi].left());
			++yi;
		}
		++mi;

		if (months.length > 1 && _x_values.length > 1 &&
			months[0] != null && months[1] != null &&
			months[0].right() >= 0 && months[1].right() >= 0) {
			// Set the month name length and the month x offset according
			// to the distance between the x-value for the first month and
			// the x-value for the second month.
			if (_x_values[months[1].right()] -
					_x_values[months[0].right()] < 25) {
				month_ln = 1;
			}
			Month_x_offset = (int) ((_x_values[months[1].right()] -
								_x_values[months[0].right()]) * .10);
		}
		// Draw months and years.
		boolean do_months = true;
		if (months.length > 1 && months[0].right() == months[1].right()) {
			do_months = false;
		}
		if (do_months) {
		i = 0;
		while (i < mi) {
			if (months[i].right() < 0) {
				months[i].set_right(0);
			}
			draw_month(g, bounds, months[i], _x_values);
			++i;
		}
		}

		i = 0;
		while (i < yi) {
			if (! is_indicator) {
				draw_year(g, bounds, years[i], ! do_months, true);
			} else if (! do_months) {
				draw_year(g, bounds, years[i], true, false);
			}
			++i;
		}
	}

	// Date of first day of `year'/`month' - for example:
	// "20001101" for year = 2000 and month = 11
	protected String first_date_at (int year, int month) {
		String result;
		String monthstr;

		if (month < 10) {
			monthstr = "0" + String.valueOf(month);
		} else {
			monthstr = String.valueOf(month);
		}
		result = String.valueOf(year) + monthstr + "01";

		return result;
	}

	// Precondition:
	//    p.left() specifies the month
	//    p.right() specifies the index
	protected void draw_month(Graphics g, Rectangle bounds, IntPair p,
			int[] _x_values) {
		int x, month_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = _x_values[p.right()];
		month_x = x + Month_x_offset;
		g.setColor(Color.black);
		g.drawLine(x + Line_offset, bounds.y,
			x + Line_offset, bounds.y + bounds.height);
		g.setColor(conf.text_color());
		if (! is_indicator) {
			g.drawString(Utilities.month_at(p.left()).substring(0, month_ln),
							month_x, Month_y);
		}
	}

	// Precondition:
	//    p.left() specifies the year
	//    p.right() specifies the index
	protected void draw_year(Graphics g, Rectangle bounds, IntPair p,
			boolean line, boolean year) {
		int year_x, x;
		final int Line_offset = -3;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = (int)(p.right() * width_factor + bounds.x);
		year_x = x + Year_x_offset;
		g.setColor(conf.text_color());
		if (line) {
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (year) {
			g.drawString(String.valueOf(p.left()), year_x, Year_y);
		}
	}

	// Do y-coordinate reference values need to be displayed for this data?
	protected boolean reference_values_needed() {
		return false;
	}

	protected Configuration conf;

	protected Drawer _market_drawer;

	protected boolean is_indicator;
}
