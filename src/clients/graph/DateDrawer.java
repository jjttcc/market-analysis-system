/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing date data
 */
public class DateDrawer extends TemporalDrawer {

	// mkd is the associated market drawer and is_ind specifies whether
	// this DateDrawer is associated with indicator data.
	DateDrawer(BasicDrawer d) {
		super(d);
	}

	// The data to be drawn
	public Object data() { return _market_drawer.dates(); }

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return 1; }

	public int[] x_values() {
		return _market_drawer.x_values();
	}

	protected final static int Max_months = 360, Max_years = 30;

	protected final static int Many_months = 28;

	protected int Year_x_offset;

	protected int Month_y, Year_y;

	protected int Month_x_offset;

	// length of the month name
	protected int month_ln;

	/**
	* Draw a vertical line for each month in `data' and years and month
	* names at the appropriate places.
	*/
	protected void draw_tuples(Graphics g, Rectangle b) {
		int mi, yi, i;
		int lastyear, lastmonth, year, month;
		Rectangle bounds = b;
		IntPair months[] = new IntPair[Max_months],
			years[] = new IntPair[Max_years];
		int[] _x_values = x_values();
		String[] data = (String[]) data();
		if (data == null) return;

		if (is_indicator()) {
			Month_y = label_y_value(bounds);
			Year_y = Month_y;
		}
		Month_x_offset = 10;
		month_ln = 3;
		// Determine the first month and year in `data'.
		year = Integer.valueOf(data[0].substring(0,4)).intValue();
		month = Integer.valueOf(data[0].substring(4,6)).intValue();
		// If the first date in `data' is not "yyyymm01", it is not the
		// first day of the month; thus the `month' needs to be incremented
		// to the next month in `data', since the first month is not complete.
		if (! data[0].substring(6,8).equals ("01")) {
			if (month == 12) {
				month = 1;
				++year;
			} else {
				++month;
			}
		}
		lastyear =
			Integer.valueOf(data[data.length-1].substring(0,4)).intValue();
		lastmonth =
			Integer.valueOf(data[data.length-1].substring(4,6)).intValue();
		mi = 0; yi = 0;
		while (! (year == lastyear && month == lastmonth)) {
			int date_index;
			date_index = Utilities.index_at_date(
				first_date_at(year, month), data, 1, 0, data.length - 1);
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
			Utilities.index_at_date(first_date_at(year, month), data, 1, 0,
				data.length - 1));
		if (month == 1) {
			years[yi] = new IntPair(year, months[mi].right());
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
			Month_x_offset = label_x_value(_x_values[months[0].right()],
				_x_values[months[1].right()]);
			Year_x_offset = Month_x_offset;
		}
		// Draw months and years.
		boolean do_months = true;
		if (mi > 1 && months[0].right() == months[1].right()) {
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
			boolean short_years = do_months && mi >= Many_months;
			if (is_indicator() && years[i].right() < _x_values.length) {
				draw_year(g, bounds, years[i], ! do_months, true, _x_values,
					short_years);
			} else if (! do_months && years[i].right() < _x_values.length) {
				draw_year(g, bounds, years[i], true, false, _x_values,
					short_years);
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
		int x, month_x, month;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, data_length());
		x = _x_values[p.right()];
		month_x = x + Month_x_offset;
		month = p.left();
		// Don't draw the line if it's close to the left border.
		if (x > Too_far_left) {
			g.setColor(conf.reference_line_color());
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (is_indicator() && month != 1) {
			g.setColor(conf.text_color());
			g.drawString(Utilities.month_at(month).substring(0, month_ln),
							month_x, Month_y);
		}
	}

	// Precondition:
	//    p.left() specifies the year
	//    p.right() specifies the index
	protected void draw_year(Graphics g, Rectangle bounds, IntPair p,
			boolean line, boolean year, int[] _x_values, boolean two_digit) {
		int year_x, x;
		final int Line_offset = -3;
		double width_factor;

		width_factor = width_factor_value(bounds, data_length());
		x = _x_values[p.right()];
		year_x = x + Year_x_offset;
		if (line && x > Too_far_left) {
			g.setColor(conf.reference_line_color());
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (year && is_indicator()) {
			int y = p.left();
			if (two_digit) y %= 100;
			String ys = String.valueOf(y);
			if (y < 10) ys += "0";

			g.setColor(conf.text_color());
			g.drawString(ys, year_x, Year_y);
		}
	}
}
