package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data tuples as points connected by lines
 */
public class DateDrawer extends Drawer {

	public int data_length() {
		int result;
		if (data != null) {
			result = data.length;
		} else {
			result = 0;
		}
		return result;
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return Stride; }

	DateDrawer () {
		conf = Configuration.instance();
	}

	public void set_data(Object d) {
		data = (String[]) d;
	}

	void set_x_values(int[] xv) {
		_x_values = xv;
	}

	protected final static int Max_months = 360, Max_years = 30;

	protected final static int Year_x_offset = 8, Year_y = 15;

	protected int Month_y;

	protected int Month_x_offset;
	
	// length of the month name
	protected int month_ln;

	/**
	* Draw a vertical line for each month in `data' and years and month
	* names at the appropriate places.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int mi, yi, i;
		int lastyear, lastmonth, year, month;
		IntPair months[] = new IntPair[Max_months],
			years[] = new IntPair[Max_years];

		Month_y = bounds.y + bounds.height - 15; Month_x_offset = 10;
		month_ln = 3;
		// Determine the beginning of each month and year in `data'.
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
			months[mi] = new IntPair(month,
				Utilities.index_at_date(first_date_at(year, month), data, 1));
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
			Utilities.index_at_date(first_date_at(year, month), data, 1));
		if (month == 1) {
			years[yi] = new IntPair(year, months[mi].left());
			++yi;
		}
		++mi;

		if (months.length > 1) {
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
		i = 0;
		while (i < mi) {
			draw_month(g, bounds, months[i]);
			++i;
		}

		i = 0;
		while (i < yi) {
			draw_year(g, bounds, years[i]);
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
	protected void draw_month(Graphics g, Rectangle bounds, IntPair p) {
		int x, month_x;
		double width_factor;

		width_factor = width_factor_value(bounds);
		x = _x_values[p.right()];
		month_x = x + Month_x_offset;
		//g.setXORMode(conf.stick_color());
		g.setXORMode(conf.line_color());
		//g.setColor(conf.line_color());
		g.drawLine(x, bounds.y, x, bounds.y + bounds.height);
		g.setColor(conf.text_color());
		//g.setXORMode(conf.stick_color());
		g.drawString(Utilities.month_at(p.left()).substring(0, month_ln),
			month_x, Month_y);
	}

	// Precondition:
	//    p.left() specifies the month
	//    p.right() specifies the index
	protected void draw_year(Graphics g, Rectangle bounds, IntPair p) {
		int year_x;
		double width_factor;

		width_factor = width_factor_value(bounds);
		year_x = (int)((p.right() - xmin) * width_factor + bounds.x) +
					Year_x_offset;
		g.setColor(conf.text_color());
		//g.setXORMode(conf.stick_color());
		g.drawString(String.valueOf(p.left()), year_x, Year_y);
	}

	// Do y-coordinate reference values need to be displayed for this data?
	protected boolean reference_values_needed() {
		return false;
	}

	private static final int Stride = 1;

	protected String[] data;

	protected Configuration conf;
}
