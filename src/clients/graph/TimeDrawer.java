/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing time-related data
 */
public class TimeDrawer extends Drawer {

	// mkd is the associated market drawer and is_ind specifies whether
	// this TimeDrawer is associated with indicator data.
	TimeDrawer(Drawer mkd, boolean is_ind) {
		_market_drawer = mkd;
		is_indicator = is_ind;
		conf = Configuration.instance();
		hour_table = new String[] {"0", "1", "2", "3", "4", "5", "6", "7",
			"8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18",
			"19", "20", "21", "22", "23"};
	}

	// The data to be drawn
	public Object data() { return _market_drawer.times(); }

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

	protected final static int Max_hours = 720, Max_days = 30;

	protected final static int Day_x_offset = 8, Day_y = 15;

	protected int Hour_y;

	protected int Hour_x_offset;

	// length of the hour name
	protected int hour_ln = 2;

	/**
	* Draw a vertical line for each hour in `_times' and days and hour
	* names at the appropriate places.
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int hi, yi, i;
		int lastday, lasthour, day, hour;
		IntPair hours[] = new IntPair[Max_hours],
			days[] = new IntPair[Max_days];
		int[] _x_values = x_values();
		String[] _times = times();
		String[] dates = dates();
System.out.println("time drawer - draw tuples was called - times:");
System.out.println(_times);
		if (_times == null || _times.length == 0) return;

System.out.println("time drawer.draw tuples A");
		Hour_y = bounds.y + bounds.height - 15; Hour_x_offset = 10;
		// Determine the first hour in `_times'.
		String hs = _times[0].substring(0,2);
		hour = Integer.valueOf(hs).intValue();
		hi = 0; yi = 0;
		hours[hi] = new IntPair(hour, 0);
		++hi;
System.out.println("Added hour " + hours[hi-1].left() + ", " +
hours[hi-1].right() + " for " + _times[0]);
		String old_hs = hs;
System.out.println("time drawer.draw tuples B");
		for (i = 1; i < _times.length; ++i) {
			hs = _times[i].substring(0,2);
			if (! hs.equals(old_hs)) {
				hour = Integer.valueOf(hs).intValue();
				hours[hi++] = new IntPair(hour, i);
				old_hs = hs;
System.out.println("Added hour " + hours[hi-1].left() + ", " +
hours[hi-1].right() + " for " + _times[i]);
			}
		}

System.out.println("time drawer.draw tuples C");
		if (hours.length > 1 && _x_values.length > 1 &&
			hours[0] != null && hours[1] != null &&
			hours[0].right() >= 0 && hours[1].right() >= 0) {
			// Set the hour x offset according to the distance between
			// the x-value for the first hour and the x-value for
			// the second hour.
			Hour_x_offset = (int) ((_x_values[hours[1].right()] -
								_x_values[hours[0].right()]) * .10);
		}
System.out.println("time drawer.draw tuples D - Hour_x_offset" + Hour_x_offset);
		// Draw hours and days.
		boolean do_hours = true;
		if (hours.length > 1 && hours[0].right() == hours[1].right()) {
			do_hours = false;
		}
		if (do_hours) {
System.out.println("time drawer.draw tuples e - hi" + hi);
		i = 0;
			while (i < hi) {
				if (hours[i].right() < 0) {
					hours[i].set_right(0);
				}
				draw_hour(g, bounds, hours[i], _x_values);
				++i;
			}
		}

	}

	// Precondition:
	//    p.left() specifies the hour
	//    p.right() specifies the index
	protected void draw_hour(Graphics g, Rectangle bounds, IntPair p,
			int[] _x_values) {
		int x, hour_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = _x_values[p.right()];
		hour_x = x + Hour_x_offset;
		g.setColor(Color.black);
		g.drawLine(x + Line_offset, bounds.y,
			x + Line_offset, bounds.y + bounds.height);
		g.setColor(conf.text_color());
		if (! is_indicator) {
			g.drawString(hour_table[p.left()], hour_x, Hour_y);
		}
	}

	// Precondition:
	//    p.left() specifies the day
	//    p.right() specifies the index
	protected void draw_day(Graphics g, Rectangle bounds, IntPair p,
			boolean line, boolean day) {
		int day_x, x;
		final int Line_offset = -3;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = (int)(p.right() * width_factor + bounds.x);
		day_x = x + Day_x_offset;
		g.setColor(conf.text_color());
		if (line) {
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (day) {
			g.drawString(String.valueOf(p.left()), day_x, Day_y);
		}
	}

	// Do y-coordinate reference values need to be displayed for this data?
	protected boolean reference_values_needed() {
		return false;
	}

	protected Configuration conf;

	protected Drawer _market_drawer;

	protected boolean is_indicator;

	protected String[] hour_table;
}
