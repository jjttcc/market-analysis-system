package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing data tuples
 */
abstract public class Drawer {

	// Number of fields in each tuple
	abstract public int drawing_stride();

	public void set_data(double d[]) {
		data = d;
	}

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
		if(clipping) {
			g.clipRect(bounds.x, bounds.y, bounds.width, bounds.height);
		}

		draw_horizontal_lines(g, bounds, hlines);
		draw_vertical_lines(g, bounds, vlines);
		if (reference_values_needed()) draw_reference_values(g, bounds);
		draw_tuples(g, bounds);
	}

	/**
	* Draw the data tuples.
	*/
	abstract protected void draw_tuples(Graphics g, Rectangle bounds);

	/**
	*  Return true if the point (x,y) is inside the allowed data range.
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

	void draw_reference_values(Graphics g, Rectangle bounds) {
		int step, start, y;

		if (yrange <= 1200) {
			if (yrange <= 120) {
				if (yrange <= 12) {
					step = 1;
				}
				else {
					step = 10;
				}
			}
			else {
				step = 100;
			}
		}
		else {
			step = 1000;
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

	protected double data[];
	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
}
