package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing data tuples
 */
abstract public class Drawer {

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

    public void set_stride(int s) {
		stride = s;
	}

	public void set_length (int l) {
		length = l;
	}

  /**
   * Draw the data bars and the line segments connecting them.
   * If this data has been attached to an Axis then scale the data
   * based on the axis maximum/minimum otherwise scale using
   * the data's maximum/minimum
   * @param g Graphics state
   * @param bounds The data window to draw into
   */
//!!!Move this into a new parent class - Drawer.
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
		draw_tuples(g, bounds, g.getClipBounds());
	}

  /**
   * Draw the data tuples.
   */
	abstract protected void draw_tuples(Graphics g, Rectangle bounds,
			Rectangle clip);

  /**
   *  Return true if the point (x,y) is inside the allowed data range.
   */

      protected boolean inside(double x, double y) {
          if( x >= xmin && x <= xmax &&
              y >= ymin && y <= ymax )  return true;

          return false;
      }

	protected double data[];
	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
    protected int stride = 2;
	protected int length;
}
