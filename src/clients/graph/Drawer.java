/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;

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

	public abstract Drawer market_drawer();

	// Is this Drawer an indicator drawer?
	public boolean is_indicator() {
		return market_drawer() != this;
	}
	// Set the dates.
	public void set_dates(String[] d) {}

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

	/**
	* Draw the data bars and the line segments connecting them.
	* If this data has been attached to an Axis then scale the data
	* based on the axis maximum/minimum otherwise scale using
	* the data's maximum/minimum
	* @param g Graphics state
	* @param bounds The data window to draw into
	*/
	public void draw_data(Graphics g, Rectangle bounds, Vector hlines,
		Vector vlines) {
		Color c;

		if ( xaxis != null ) {
			xmax = xaxis.maximum;
			xmin = xaxis.minimum;
		}

		if ( yaxis != null ) {
			ymax = yaxis.maximum;
			ymin = yaxis.minimum;
		}

		xrange = xmax - xmin;
		yrange = ymax - ymin;

		/*
		** Clip the data window
		*/
		if (clipping) {
			g.clipRect(bounds.x, bounds.y, bounds.width, bounds.height);
		}

		draw_horizontal_lines(g, bounds, hlines);
		draw_vertical_lines(g, bounds, vlines);
		if (reference_values_needed()) draw_reference_values(g, bounds);
		draw_tuples(g, bounds);
	}

	abstract protected int[] x_values();

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

		int y1, y2;
		double d1, d2;
		for (int i = 0; i < hline_data.size(); ++i) {
			d1 = ((DoublePair) hline_data.elementAt(i)).left();
			d2 = ((DoublePair) hline_data.elementAt(i)).right();
			y1 = (int)(bounds.y + (1.0 - (d1-ymin) / yrange) * bounds.height);
			y2 = (int)(bounds.y + (1.0 - (d2-ymin) / yrange) * bounds.height);
			g.drawLine(bounds.x, y1, bounds.x + bounds.width, y2);
		}
	}

	private void draw_vertical_lines(Graphics g, Rectangle bounds,
			Vector vline_data) {
		if (vline_data == null) return;

		int x1, x2;
		double d1, d2;
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
	void draw_reference_values(Graphics g, Rectangle bounds) {
		int step = 0, start, y;

		for (int i = 0; i < refvalue_specs.length; ++i) {
			if (yrange >= refvalue_specs[i].minimum() &&
					yrange < refvalue_specs[i].maximum()) {
				step = refvalue_specs[i].step_value();
				break;
			}
		}
		start = (int) (Math.floor(ymin / step) * step + step);
		for (y = start; y < ymax; y += step) {
			display_reference_value(y, g, bounds);
		}
	}

	// Display the value of the specified y coordinate at that y coordinate
	// at the far left side of the graph and at the far right side.
	protected void display_reference_value (int y, Graphics g,
			Rectangle bounds) {
		int adjusted_y = (int) (bounds.y + (1.0 - (y-ymin) / yrange) *
								bounds.height);

		g.drawLine(bounds.x, adjusted_y, bounds.x + bounds.width, adjusted_y);
		g.drawString(new Integer(y).toString(), bounds.x + 5, adjusted_y);
		g.drawString(new Integer(y).toString(),
						bounds.x + bounds.width - 30, adjusted_y);
	}

	// Do y-coordinate reference values need to be displayed for this data?
	protected boolean reference_values_needed() {
		// Assumption: If the stride is 1, the data is for an indicator,
		// which does not need reference values.
		return drawing_stride() > 1;
	}

	// Calculation of width factor for drawing based on window width
	// and xrange.
	protected double width_factor_value(Rectangle bounds) {
		final int w_margin = 6;
		return (bounds.width - w_margin) / xrange;
	}

	// Calculation of height factor for drawing based on window height
	// and yrange.
	protected double height_factor_value(Rectangle bounds) {
		return bounds.height / yrange;
	}

	static protected RefSpec[] refvalue_specs;

	static {
		refvalue_specs = new RefSpec[7];
		refvalue_specs[0] = new RefSpec(0, 15, 1);
		refvalue_specs[1] = new RefSpec(15, 30, 5);
		refvalue_specs[2] = new RefSpec(30, 150, 10);
		refvalue_specs[3] = new RefSpec(150, 300, 50);
		refvalue_specs[4] = new RefSpec(300, 1500, 100);
		refvalue_specs[5] = new RefSpec(1500, 3000, 500);
		refvalue_specs[6] = new RefSpec(3000, 2000000000, 1000);
	}

	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
}

class RefSpec {
	RefSpec(int min, int max, int v) {
		_minimum = min;
		_maximum = max;
		_value = v;
	}

	int minimum() { return _minimum; }

	int maximum() { return _maximum; }

	int step_value() { return _value; }

	private int _minimum;

	private int _maximum;

	private int _value;
}
