/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.Configuration;
import support.Utilities;

/**
 *  Drawer of Primary, non-temporal market data
 */
abstract public class BasicDrawer extends Drawer {

	// The dates associated with the principle (market) data
	public abstract String[] dates();

	// The times (if any) associated with the principle (market) data
	public abstract String[] times();

	public boolean data_processed() {
		return x_values() != null && x_values().length > 0;
	}

	// Is this Drawer an indicator drawer?
	public boolean is_indicator() {
		return market_drawer() != this;
	}

	// Is this Drawer an indicator drawer for the lower graph?
	public boolean is_lower_indicator() {
		return is_indicator() && is_lower();
	}

	// Set the dates.
	public void set_dates(String[] d) {}

	// Set the times.
	public void set_times(String[] t) {}

	// Number of tuples in the data
	public int tuple_count() {
		return data_length() / drawing_stride();
	}

	// Number of elements in the data
	abstract public int data_length();

	public void set_boundaries_needed(boolean b) { boundaries_needed = b; }

	public void set_xaxis(Axis a) {
		xaxis = a;
	}

	public void set_yaxis(Axis a) {
		yaxis = a;
	}

	public void set_clipping(boolean b) {
		clipping = b;
	}

	public void set_maxes(double xmax_v, double ymax_v,
		double xmin_v, double ymin_v) {
		xmax = xmax_v;
		ymax = ymax_v;
		xmin = xmin_v;
		ymin = ymin_v;
	}

	public void set_ranges (double x, double y) {
		xrange = x;
		yrange = y;
	}

	private void draw_boundaries(Graphics g, Rectangle bounds) {
		int Y_fill_value = 0;
		Rectangle right_bounds = right_reference_bounds(bounds);
		if (! is_lower()) Y_fill_value = 5;

		g.setColor(Color.lightGray);
		if (is_lower_indicator()) {
			Rectangle btm_bounds = bottom_reference_bounds(bounds);
			// The bottom reference area
			g.fill3DRect(btm_bounds.x, btm_bounds.y,
				btm_bounds.width, btm_bounds.height, true);
			// The right reference area
			g.fill3DRect(right_bounds.x, right_bounds.y,
				right_bounds.width, right_bounds.height + Y_fill_value, true);
		} else {
			g.fill3DRect(right_bounds.x, right_bounds.y - Y_fill_value,
				right_bounds.width, right_bounds.height + Y_fill_value, true);
		}
	}

	/**
	* Draw the data bars and the line segments connecting them.
	* If this data has been attached to an Axis then scale the data
	* based on the axis maximum/minimum otherwise scale using
	* the data's maximum/minimum
	* @param g Graphics state
	* @param bounds The data window to draw into
	*/
	public void draw_data(Graphics g, Rectangle bounds, Vector hlines,
		Vector vlines, Color c) {
		draw_color = c;
		Rectangle main_bounds = main_bounds(bounds);
		Rectangle right_bounds = right_reference_bounds(bounds);

		if ( xaxis != null ) {
			xmax = xaxis.maximum();
			xmin = xaxis.minimum();
		}

		if ( yaxis != null ) {
			ymax = yaxis.maximum();
			ymin = yaxis.minimum();
		}

		xrange = xmax - xmin;
		yrange = ymax - ymin;

		/*
		** Clip the data window
		*/
		if (clipping) {
			g.clipRect(bounds.x, bounds.y, bounds.width, bounds.height);
		}

		if (boundaries_needed) draw_boundaries(g, bounds);
		draw_horizontal_lines(g, main_bounds, hlines);
		draw_vertical_lines(g, main_bounds, vlines);
		if (reference_values_needed()) {
			draw_reference_values(g, main_bounds, right_bounds);
		}
		if (market_drawer() != null) {
			draw_tuples(g, main_bounds);
		}
	}

	// Is this an indicator for the lower graph?
	protected boolean is_lower() { return false; }

	// Current data-bar width - defaults to 0
	protected int bar_width() { return 0; }

	// Bounds of the main drawing area, derived from `r'
	protected Rectangle main_bounds(Rectangle r) {
		final int xmargin = 6;
		Rectangle result = new Rectangle(r);
		result.x += xmargin;
		result.width -= Reference_rect_width + xmargin;
		if (is_lower_indicator()) {
			result.height -= Bottom_ref_rect_height;
		}
		return result;
	}

	// Bounds of the right reference drawing area, derived from `r'
	protected Rectangle right_reference_bounds(Rectangle r) {
		Rectangle result = new Rectangle(r);
		result.x = result.width - Reference_rect_width;
		result.width = Reference_rect_width;
		if (is_lower_indicator()) {
			result.height -= Bottom_ref_rect_height;
		}
		return result;
	}

	// Bounds of the bottom reference drawing area, derived from `r'
	protected Rectangle bottom_reference_bounds(Rectangle r) {
		Rectangle result = new Rectangle(r);
		if (is_lower_indicator()) {
			result.height = Bottom_ref_rect_height;
			result.y += r.height - Bottom_ref_rect_height;
		}
		return result;
	}

	/**
	* Draw the data tuples.
	* Postcondition: 
	*    x_values contains the x values that were used to draw each tuple.
	*/
	abstract protected void draw_tuples(Graphics g, Rectangle bounds);

	// The row of first data tuple
	protected int first_row() {
		return first_date_index() + 1;
	}

	// Index of the earliest date - 0 by default - redefine if needed.
	protected int first_date_index() {
		return 0;
	}

	private void draw_horizontal_lines(Graphics g, Rectangle bounds,
			Vector hline_data) {
		if (hline_data == null) return;

		int y1, y2;
		double d1, d2;
		g.setColor(Color.black);
		for (int i = 0; i < hline_data.size(); ++i) {
			d1 = ((DoublePair) hline_data.elementAt(i)).left();
			d2 = ((DoublePair) hline_data.elementAt(i)).right();
			y1 = (int)(bounds.y + (1.0 - (d1-ymin) / yrange) * bounds.height);
			y2 = (int)(bounds.y + (1.0 - (d2-ymin) / yrange) * bounds.height);
			g.drawLine(bounds.x - X_left_line_adjust, y1,
				bounds.x + bounds.width, y2);
		}
	}

	private void draw_vertical_lines(Graphics g, Rectangle bounds,
			Vector vline_data) {
		if (vline_data == null) return;

		int x1, x2;
		double d1, d2;
		g.setColor(Color.black);
		for (int i = 0; i < vline_data.size(); ++i) {
			d1 = ((DoublePair) vline_data.elementAt(i)).left();
			d2 = ((DoublePair) vline_data.elementAt(i)).right();
			x1 = (int)(bounds.x + ((d1-xmin) / xrange) * bounds.width);
			x2 = (int)(bounds.x + ((d2-xmin) / xrange) * bounds.width);
			g.drawLine(x1, bounds.y, x2, bounds.y + bounds.height);
		}
	}

	// Draw lines and labels for reference values for the y axis according
	// to range of the data - for example, 10, 20, 30 when the range
	// is from 8 to 37.
	void draw_reference_values(Graphics g, Rectangle main_bounds,
			Rectangle ref_bounds) {
		int start;
		long step = 0, y;
		Vector y_values = new Vector();	// Double
		String[] y_strings;
		Double d;
		boolean lines_needed = reference_lines_needed();
		Font old_font = g.getFont();
		g.setFont(new Font("Monospaced", Font.ITALIC, 12));

		for (int i = 0; i < refvalue_specs.length; ++i) {
			if (yrange >= refvalue_specs[i].minimum() &&
					yrange < refvalue_specs[i].maximum()) {
				step = refvalue_specs[i].step_value();
				break;
			}
		}
		start = (int) (Math.floor(ymin / step) * step + step);
		for (y = start; y < ymax; y += step) {
			y_values.addElement(new Double(y));
		}
		y_strings = Utilities.formatted_doubles(y_values, ! is_lower());
		if (y_values.size() > 0) {
			display_reference_values(y_values, y_strings, g, main_bounds,
				ref_bounds, lines_needed);
		}
		g.setFont(old_font);
	}

	// Precondition: yvalues != null && yvalues.size() > 0 &&
	//    yvalues.size() == ystrs.length
	protected void display_reference_values(Vector yvalues, String[] ystrs,
			Graphics g, Rectangle main_bounds, Rectangle ref_bounds,
			boolean lines) {
		final int Y_text_adjust = 3, margin = 5, margin_for_text = 8;
		final int Min_vertical_space = 15;
		int step = 1;
		int adj_ys[] = new int[yvalues.size() + 1];
		String[] ystrings = new String[ystrs.length];
		Configuration config = Configuration.instance();
		adj_ys[0] = (int) (ref_bounds.y + (1.0 -
			(((Double) yvalues.elementAt(0)).doubleValue() - ymin) / yrange) *
			ref_bounds.height);
		ystrings[0] = ystrs[0];
		if (yvalues.size() > 1) {
			int i;
			int adjusted_y = (int) (ref_bounds.y + (1.0 -
				(((Double) yvalues.elementAt(1)).doubleValue() - ymin) /
				yrange) * ref_bounds.height);
			// If the first two elements of yvalues are too close together:
			if (adj_ys[0] - adjusted_y < Min_vertical_space) {
				// Ensure that every other value is skipped.
				int start = 2;
				if (adj_ys[0] <= ref_bounds.y + margin_for_text || adj_ys[0] >=
						ref_bounds.y + ref_bounds.height - margin_for_text) {
					// The first element of yvalues is out of bounds, so
					// start with the second element.
					start = 1;
				}
				for (i = start; i < yvalues.size(); i += 2) {
					adj_ys[i / 2] = (int) (ref_bounds.y + (1.0 -
						(((Double) yvalues.elementAt(i)).doubleValue() -
						ymin) / yrange) * ref_bounds.height);
					ystrings[i / 2] = ystrs[i];
				}
				adj_ys[i / 2] = -1;
			} else {
				// Ensure that every value is displayed.
				for (i = 1; i < yvalues.size(); ++i) {
					adj_ys[i] = (int) (ref_bounds.y + (1.0 -
						(((Double) yvalues.elementAt(i)).doubleValue() -
						ymin) / yrange) * ref_bounds.height);
					ystrings[i] = ystrs[i];
				}
				adj_ys[i] = -1;
			}
		}

		for (int i = 0; i < adj_ys.length && adj_ys[i] >= 0; ++i) {
			if (adj_ys[i] > ref_bounds.y + margin &&
					adj_ys[i] < ref_bounds.y + ref_bounds.height - margin) {
				if (lines) {
					g.setColor(Color.black);
					g.drawLine(main_bounds.x - X_left_line_adjust, adj_ys[i],
						main_bounds.x + main_bounds.width, adj_ys[i]);
				}
				if (adj_ys[i] > ref_bounds.y + margin_for_text && adj_ys[i] <
						ref_bounds.y + ref_bounds.height - margin_for_text) {
					g.setColor(config.text_color());
					g.drawString(ystrings[i],
						ref_bounds.x + ref_bounds.width + Ref_text_offset,
						adj_ys[i] + Y_text_adjust);
				}
			}
		}
	}

	// Set reference_values_needed, if appropriate.
	abstract public void set_reference_values_needed(boolean b);

	// Set lower indicator value, if appropriate.
	public void set_lower(boolean b) {}

	// Do y-coordinate reference values need to be displayed for this data?
	abstract protected boolean reference_values_needed();

	// Do y-coordinate reference lines need to be displayed for this data?
	abstract protected boolean reference_lines_needed();

	// Calculation of height factor for drawing based on window height
	// and yrange.
	protected double height_factor_value(Rectangle bounds) {
		return bounds.height / yrange;
	}

	protected int base_bar_width(Rectangle bounds, int bar_count) {
		return bounds.width / bar_count;
	}

	static protected RefSpec[] refvalue_specs;

	static {
		refvalue_specs = new RefSpec[19];
		refvalue_specs[0] = new RefSpec(0, 15, 1);
		refvalue_specs[1] = new RefSpec(15, 30, 5);
		refvalue_specs[2] = new RefSpec(30, 150, 10);
		refvalue_specs[3] = new RefSpec(150, 300, 50);
		refvalue_specs[4] = new RefSpec(300, 1500, 100);
		refvalue_specs[5] = new RefSpec(1500, 3000, 500);
		refvalue_specs[6] = new RefSpec(3000, 15000, 1000);
		refvalue_specs[7] = new RefSpec(15000, 30000, 5000);
		refvalue_specs[8] = new RefSpec(30000, 150000, 10000);
		refvalue_specs[9] = new RefSpec(150000, 300000, 50000);
		refvalue_specs[10] = new RefSpec(300000, 1500000, 100000);
		refvalue_specs[11] = new RefSpec(1500000, 3000000, 500000);
		refvalue_specs[12] = new RefSpec(3000000, 15000000, 1000000);
		refvalue_specs[13] = new RefSpec(15000000, 30000000, 5000000);
		refvalue_specs[14] = new RefSpec(30000000, 150000000, 10000000);
		refvalue_specs[15] = new RefSpec(150000000, 300000000, 50000000);
		refvalue_specs[16] = new RefSpec(300000000, 1500000000, 100000000);
		refvalue_specs[17] = new RefSpec(1500000000, 3000000000L, 500000000);
		refvalue_specs[18] = new RefSpec(3000000000L, 9000000000000,
			1000000000);
	}

	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
	protected boolean boundaries_needed;
	// Color to draw data in
	protected Color draw_color;
	final int Reference_rect_width = 50;	// Width of right reference bar
	final int Bottom_ref_rect_height = 25;	// Height of bottom reference bar
	final int X_left_line_adjust = 9;	// Ensures that line starts flush left.
	final int Ref_text_offset = -42;	// Offset for reference text
}

class RefSpec {
	RefSpec(long min, long max, long v) {
		_minimum = min;
		_maximum = max;
		_value = v;
	}

	long minimum() { return _minimum; }

	long maximum() { return _maximum; }

	long step_value() { return _value; }

	private long _minimum;

	private long _maximum;

	private long _value;
}
