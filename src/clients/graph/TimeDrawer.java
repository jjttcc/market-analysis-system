/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing time data
 */
public class TimeDrawer extends TemporalDrawer {

	// mkd is the associated market drawer and is_ind specifies whether
	// this TimeDrawer is associated with indicator data.
	TimeDrawer(BasicDrawer mkd) {
		super(mkd);
		hour_table = new String[] {"12", "1", "2", "3", "4", "5", "6", "7",
			"8", "9", "10", "11", "12", "1", "2", "3", "4", "5", "6", "7",
			"8", "9", "10", "11"};
		day_table = new String[8];
		day_table[Calendar.SUNDAY] = "S";
		day_table[Calendar.MONDAY] = "M";
		day_table[Calendar.TUESDAY] = "T";
		day_table[Calendar.WEDNESDAY] = "W";
		day_table[Calendar.THURSDAY] = "T";
		day_table[Calendar.FRIDAY] = "F";
		day_table[Calendar.SATURDAY] = "S";
	}

	// The data to be drawn
	public Object data() { return _market_drawer.times(); }

	// The dates associated with the principle (market) data
	public String[] dates() { return _market_drawer.dates(); }

	// The dates associated with the principle (market) data
	public String[] times() { return _market_drawer.times(); }

	public int data_length() {
		int result;
		if (times() != null) {
			result = times().length;
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

	protected int Hour_y, Day_y;

	protected int Hour_x_offset, Day_x_offset;

	// length of the hour name
	protected int hour_ln = 2;

	/**
	* Draw a vertical line for each hour in `times' and days and hour
	* names at the appropriate places.
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int hi, di, i;
		int hour, day_of_week;
		final int Draw_all_hour_limit = 16;
		boolean draw_all_hours;
		String old_hour_string;
		int[] _x_values = x_values();
		String[] times = times();
		String[] dates = dates();
		IntPair hours[] = new IntPair[times.length],
			days[] = new IntPair[times.length];

		if (times == null || times.length == 0) return;

		if (is_indicator()) {
			Hour_y = label_y_value(bounds);
			Day_y = Hour_y;
		}
		Hour_x_offset = 10;
		// Determine the first hour in `times'.
		String hour_string = times[0].substring(0,2);
		String day_string = dates[0].substring(6,8);
		hour = Integer.valueOf(hour_string).intValue();
		day_of_week = week_day_for(dates[0]);
		hi = 0; di = 0;
		hours[hi] = new IntPair(hour, 0);
		days[di] = new IntPair(day_of_week, 0);
		++hi; ++di;
		old_hour_string = hour_string;
		// Map out all hours (from times) and days (from dates) with IntPairs.
		for (i = 1; i < times.length; ++i) {
			hour_string = times[i].substring(0,2);
			if (! hour_string.equals(old_hour_string)) {
				hour = Integer.valueOf(hour_string).intValue();
				hours[hi++] = new IntPair(hour, i);
				old_hour_string = hour_string;
				// If current hour is less than previous hour,
				// a new day has begun.
				if (hour < hours[hi-2].left()) {
					day_of_week = week_day_for(dates[i]);
					days[di++] = new IntPair(day_of_week, i);
				}
			}
		}

		if (hi > 1 && _x_values.length > 1 &&
			hours[0] != null && hours[1] != null &&
			hours[0].right() >= 0 && hours[1].right() >= 0) {
			// Set the hour x offset according to the distance between
			// the x-value for the first hour and the x-value for
			// the second hour.
			Hour_x_offset = label_x_value(_x_values[hours[0].right()],
				_x_values[hours[1].right()]);
			Day_x_offset = Hour_x_offset;
		}
		i = 0;
		draw_all_hours = hi <= Draw_all_hour_limit;
		// Draw hours.
		while (i < hi) {
			if (drawable_hour(hours, hi, i, draw_all_hours)) {
				draw_hour(g, bounds, hours[i], _x_values);
			}
			++i;
		}
		i = 0;
		while (i < di) {
			draw_day(g, bounds, days[i], _x_values);
			++i;
		}
	}

	// Precondition:
	//    p.left() specifies the hour
	//    p.right() specifies the x-index
	protected void draw_hour(Graphics g, Rectangle bounds, IntPair p,
			int[] x_values) {
		int x, hour_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = x_values[p.right()];
		hour_x = x + Hour_x_offset;
		if (x > Too_far_left) {
			g.setColor(conf.reference_line_color());
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (is_indicator()) {
			g.setColor(conf.text_color());
			g.drawString(hour_table[p.left()], hour_x, Hour_y);
		}
	}

	// Precondition:
	//    p.left() specifies the day
	//    p.right() specifies the x-index
	protected void draw_day(Graphics g, Rectangle bounds, IntPair p,
			int[] x_values) {
		int x, day_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().length);
		x = x_values[p.right()];
		day_x = x + Day_x_offset;
		if (x > Too_far_left) {
			g.setColor(conf.reference_line_color());
			g.drawLine(x + Line_offset, bounds.y,
				x + Line_offset, bounds.y + bounds.height);
		}
		if (is_indicator()) {
			g.setColor(conf.text_color());
			g.drawString(day_table[p.left()], day_x, Day_y);
		}
	}

	protected boolean drawable_hour(IntPair hours[], int hcount, int i,
			boolean draw_all) {
		 boolean result;
		 boolean is_odd = hours[i].left() % 2 == 1;
		 boolean first_hour_of_day = i == 0 ||
		 	hours[i-1].left() > hours[i].left();
		 boolean last_hour_of_day = i == hcount - 1 ||
		 	hours[i].left() > hours[i+1].left();

		 if (draw_all) {
			// Draw all hours actually means draw all hours except for
			// odd hours that begin the day.
		 	result = ! (is_odd && first_hour_of_day ||
				! is_odd && last_hour_of_day);
		 } else {
			 // An hour is drawable if it is not the first hour in the array
			 // and it is not the first hour of the day and it is odd.
			 result = ! first_hour_of_day && is_odd;
		}

		return result;
	}

	// The day of the week for `date'.
	protected int week_day_for(String date) {
		int result;

		int year = Integer.valueOf(date.substring(0,4)).intValue();
		// Java months start at 0.
		int month = Integer.valueOf(date.substring(4,6)).intValue() - 1;
		int day = Integer.valueOf(date.substring(6,8)).intValue();
		GregorianCalendar cal = new GregorianCalendar(year, month, day);
		result = cal.get(Calendar.DAY_OF_WEEK);

		return result;
	}

	protected String[] hour_table;

	protected String[] day_table;
}
