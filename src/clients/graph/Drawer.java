/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.Configuration;

/**
 *  Abstraction for drawing data tuples
 */
abstract public class Drawer {

	// Number of fields in each tuple
	public abstract int drawing_stride();

	// The data to be drawn
	public abstract Object data();

	public abstract MarketDrawer market_drawer();

	// Is this Drawer an indicator drawer?
	public abstract boolean is_indicator();

	// Number of tuples in the data
	public int tuple_count() {
		return data_length() / drawing_stride();
	}

	// Number of elements in the data
	abstract public int data_length();

	// Set data to `d'.
	public void set_data(Object d) {}

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

	// x values of main data
	abstract public int[] x_values();

	// Calculation of width factor for drawing based on window width
	// and record count.
	protected double width_factor_value(Rectangle bounds, int record_count) {
		final int w_margin = 6;
		final double adjustment_factor = 1.0015;
		double result;
		result = (bounds.width - w_margin) * adjustment_factor / record_count;
		return result;
	}

	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
	// Color to draw data in
	protected Color draw_color;
	final int Reference_rect_width = 40;	// Width of right reference bar
	final int Bottom_ref_rect_height = 25;	// Height of bottom reference bar
	final int X_left_line_adjust = 9;	// Ensures that line starts flush left.
	final int Ref_text_offset = -32;	// Offset for reference text
}
