/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

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

	// The dates associated with the principle (market) data
	public abstract String[] dates();

	// The times (if any) associated with the principle (market) data
	public abstract String[] times();

	public abstract Drawer market_drawer();

	// Is this Drawer an indicator drawer?
	public boolean is_indicator() {
		return market_drawer() != this;
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

	public void draw_boundaries(Graphics g, Rectangle bounds) {
		final int Y_fill_value = 5;
		Rectangle ref_bounds = reference_bounds(bounds);

		g.setColor(Color.gray);
		g.fill3DRect(ref_bounds.x, ref_bounds.y - Y_fill_value,
			ref_bounds.width, ref_bounds.height + Y_fill_value, true);
			//!!!ref_bounds.width, ref_bounds.height + Y_fill_value, true);
System.out.println("reference section was drawn for " + getClass());
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
		Rectangle reference_bounds = reference_bounds(bounds);

System.out.println("main bounds, bounds: " + main_bounds + ", " + bounds);
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

		draw_horizontal_lines(g, main_bounds, hlines);
		draw_vertical_lines(g, main_bounds, vlines);
		if (reference_values_needed()) {
			draw_reference_values(g, main_bounds, reference_bounds);
		}
		draw_tuples(g, main_bounds);
	}

	// x values of main data
	abstract protected int[] x_values();

	// Current data-bar width - defaults to 0
	protected int bar_width() { return 0; }

	// Bounds of the main drawing area, derived from `r'
	protected Rectangle main_bounds(Rectangle r) {
		final int xmargin = 6;
		Rectangle result = new Rectangle(r);
		result.x += xmargin;
		result.width -= Reference_rect_width + xmargin;
		return result;
	}

	// Bounds of the reference drawing area, derived from `r'
	protected Rectangle reference_bounds(Rectangle r) {
		Rectangle result = new Rectangle(r);
		result.x = result.width - Reference_rect_width;
		result.width = Reference_rect_width;
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

	/**
	*  Is the point (x,y) inside the allowed data range?
	*/
	protected boolean inside(double x, double y) {
		if( x >= xmin && x <= xmax && y >= ymin && y <= ymax )  return true;
		return false;
	}

	private void draw_horizontal_lines(Graphics g, Rectangle bounds,
			Vector hline_data) {
		if (hline_data == null) return;
System.out.println("dhl - bounds: " + bounds);

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
		boolean lines_needed = reference_lines_needed();

		for (int i = 0; i < refvalue_specs.length; ++i) {
			if (yrange >= refvalue_specs[i].minimum() &&
					yrange < refvalue_specs[i].maximum()) {
				step = refvalue_specs[i].step_value();
				break;
			}
		}
		start = (int) (Math.floor(ymin / step) * step + step);
		for (y = start; y < ymax; y += step) {
System.out.println("drv - refspecs - ln, step, start, y: " +
refvalue_specs.length + ", " + step + ", " + start + ", " + y +
" (class: " + getClass() + ")");
			display_reference_value(y, g, main_bounds, ref_bounds,
				lines_needed);
		}
	}

	// Display the value of the specified y coordinate at that y coordinate
	// at the far left side of the graph and at the far right side.
	protected void display_reference_value (long y, Graphics g,
			Rectangle main_bounds, Rectangle ref_bounds, boolean lines) {
		final int Y_text_adjust = 3, topmargin = 5;
		Configuration config = Configuration.instance();
		int adjusted_y = (int) (ref_bounds.y + (1.0 - (y-ymin) / yrange) *
								ref_bounds.height);

System.out.println("(" + getClass() + ")");
System.out.println("adjy, rbht + refb.y - topm: " + adjusted_y + ", " +
(ref_bounds.height + ref_bounds.y - topmargin));
		if (adjusted_y <= ref_bounds.height + ref_bounds.y - topmargin) {
			if (lines) {
				g.setColor(Color.black);
				g.drawLine(main_bounds.x - X_left_line_adjust, adjusted_y,
					main_bounds.x + main_bounds.width, adjusted_y);
			}
//		g.drawString(new Integer(y).toString(), bounds.x + 5, adjusted_y);
System.out.print("displrv drawing text at y: " + adjusted_y + Y_text_adjust);
System.out.println(" (class: " + getClass() + ")");
			g.setColor(config.text_color());
			g.drawString(new Integer((int) y).toString(),
				ref_bounds.x + ref_bounds.width + Ref_text_offset,
				adjusted_y + Y_text_adjust);
		}
	}

	// Do y-coordinate reference values need to be displayed for this data?
	abstract public void set_reference_values_needed(boolean b);

	// Do y-coordinate reference values need to be displayed for this data?
	abstract protected boolean reference_values_needed();

	// Do y-coordinate reference lines need to be displayed for this data?
	abstract protected boolean reference_lines_needed();

	// Calculation of width factor for drawing based on window width
	// and record count.
	protected double width_factor_value(Rectangle bounds, int record_count) {
		final int w_margin = 6;
		final double adjustment_factor = 1.0015;
		double result;
		result = (bounds.width - w_margin) * adjustment_factor / record_count;
		return result;
	}

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
		refvalue_specs[18] = new RefSpec(3000000000L, 9000000000000, 1000000000);
	}

	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
	// Color to draw data in
	protected Color draw_color;
	int Reference_rect_width = 40;		// Width of reference component
	final int X_left_line_adjust = 9;	// Ensures that line starts flush left.
	final int Ref_text_offset = -32;	// Offset for reference text
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
