/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

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
	}

	// The data to be drawn
	public ArrayList data() { return market_drawer.times(); }

	// The dates associated with the principle (market) data
	public ArrayList dates() { return market_drawer.dates(); }

	// The dates associated with the principle (market) data
	public ArrayList times() { return market_drawer.times(); }

	public int data_length() {
		int result;
		if (times() != null) {
			result = times().size();
		} else {
			result = 0;
		}
		return result;
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return 1; }

	public int[] x_values() {
		return market_drawer.x_values();
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
		int hour_idx, day_idx, i;
		int hour, day_of_week;
		final int Draw_all_hour_limit = 16, Hour_limit = 175,
			Hour_line_limit = 65, Day_limit = 200, Day_y_offset = 9;
		boolean draw_all_hours, draw_day_line;
		FontManager fontmgr = new FontManager(g);
		String old_hour_string;
		int[] x_values = x_values();
		ArrayList times = times();
		ArrayList dates = dates();

		// If there are no 'times', there is nothing to draw here.
		if (times == null || times.size() == 0) return;

		IntPair hours[] = new IntPair[times.size()],
			days[] = new IntPair[times.size()];

		if (is_indicator()) {
			Hour_y = label_y_value(bounds);
			Day_y = Hour_y + Day_y_offset;
		}
		Hour_x_offset = 10;
		// Determine the first hour in `times'.
		String hour_string = ((String) times.get(0)).substring(0,2);
		String day_string = ((String) dates.get(0)).substring(6,8);
		hour = Integer.valueOf(hour_string).intValue();
		day_of_week = week_day_for((String) dates.get(0));
		hour_idx = 0; day_idx = 0;
		hours[hour_idx] = new IntPair(hour, 0);
		days[day_idx] = new IntPair(day_of_week, 0);
		++hour_idx; ++day_idx;
		old_hour_string = hour_string;
		// Map out all hours (from times) and days (from dates) with IntPairs.
		for (i = 1; i < times.size(); ++i) {
			hour_string = ((String) times.get(i)).substring(0,2);
			if (! hour_string.equals(old_hour_string)) {
				hour = Integer.valueOf(hour_string).intValue();
				hours[hour_idx++] = new IntPair(hour, i);
				old_hour_string = hour_string;
				// If current hour is less than previous hour,
				// a new day has begun.
				if (hour < hours[hour_idx-2].left()) {
					day_of_week = week_day_for((String) dates.get(i));
					days[day_idx++] = new IntPair(day_of_week, i);
				}
			}
		}

		if (hour_idx > 1 && x_values.length > 1 &&
			hours[0] != null && hours[1] != null &&
			hours[0].right() >= 0 && hours[1].right() >= 0) {
			// Set the hour x offset according to the distance between
			// the x-value for the first hour and the x-value for
			// the second hour.
//!!!:
System.out.println("TimeDrawer.draw_tuples - hours[0].right()]: " +
hours[0].right() + ", hours[1].right(): " + hours[1].right());
			Hour_x_offset = label_x_value(x_values[hours[0].right()],
				x_values[hours[1].right()]);
			Day_x_offset = Hour_x_offset;
		}
		i = 0;
		draw_all_hours = hour_idx <= Draw_all_hour_limit;
		if (hour_idx < Hour_limit) {
			boolean draw_hour_line = hour_idx < Hour_line_limit;
			fontmgr.set_new_font(fontmgr.SERIF, Font.PLAIN, 10);
			// Draw hours.
			while (i < hour_idx) {
				if (drawable_hour(hours, hour_idx, i, draw_all_hours)) {
					draw_hour(g, bounds, hours[i], x_values, draw_hour_line);
				}
				++i;
			}
		}
		i = 0;
		draw_day_line = day_idx <= Day_limit;
		while (i < day_idx) {
			fontmgr.set_new_font(fontmgr.MONOSPACED, Font.ITALIC, 12);
			draw_day(g, bounds, days[i], x_values, draw_day_line);
			++i;
		}
		fontmgr.restore_font();
	}

	// Precondition:
	//    p.left() specifies the hour
	//    p.right() specifies the x-index
	protected void draw_hour(Graphics g, Rectangle bounds, IntPair p,
			int[] x_values, boolean draw_line) {
		int x, hour_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().size());
		if (p.right() >= x_values.length) {
			throw new Error("[TimeDrawer.draw_hour] p.right is too large " +
				"for index: " + p.right() + ", " + x_values.length);
		} else {
			x = x_values[p.right()];
		}
		hour_x = x + Hour_x_offset;
		if (draw_line && x > Too_far_left) {
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
			int[] x_values, boolean draw_line) {
		int x, day_x;
		final int Line_offset = -2;
		double width_factor;

		width_factor = width_factor_value(bounds, dates().size());
		if (p.right() >= x_values.length) {
			throw new Error("[TimeDrawer.draw_day] p.right is too large " +
				"for index: " + p.right() + ", " + x_values.length);
		} else {
			x = x_values[p.right()];
		}
		day_x = x + Day_x_offset;
		if (draw_line && x > Too_far_left) {
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

	protected static String[] hour_table;

	protected static String[] day_table;

	static {
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
}
