package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data as a bar graph
 */
public class BarDrawer extends Drawer {

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x, y;
		int lngth = data.length;
		int bar_width = bounds.width / lngth - 2;
		double width_factor, height_factor;
		int x_s[] = new int[4], y_s[] = new int[4];
		Configuration conf = Configuration.instance();

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (data == null || lngth < Stride) return;

		if (bar_width <= 0) bar_width = 1;
		g.setColor(conf.bar_color());
		width_factor = bounds.width / xrange;
		height_factor = bounds.height / yrange;
		for (i = 0, row = 1; i < lngth; i += Stride, ++row) {
			x = (int)((row - xmin) * width_factor + bounds.x);
			y = (int)(bounds.height - (data[i]-ymin) * height_factor +
					bounds.y);
			x_s[0] = x; x_s[1] = x + bar_width;
			x_s[2] = x_s[1]; x_s[3] = x_s[0];
			y_s[0] = y; y_s[1] = y;
			y_s[2] = bounds.height; y_s[3] = bounds.height;
			g.fillPolygon(x_s, y_s, 4);
		}
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return Stride; }

	private static final int Stride = 1;
}
