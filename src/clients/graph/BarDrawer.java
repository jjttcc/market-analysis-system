/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import application_support.*;

/**
 *  Abstraction for drawing data as a bar graph
 */
public class BarDrawer extends IndicatorDrawer {

	public BarDrawer(MarketDrawer md) { super(md); }

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x, y;
		int lngth = 0;
		int[] x_values = x_values();
		if (data != null) lngth = data_length();
		if (lngth == 0 || x_values == null) return;

		int bar_width = bar_width();
		double height_factor;
		int x_s[] = new int[4], y_s[] = new int[4];
		MA_Configuration conf = MA_Configuration.application_instance();
		if (draw_color == null) draw_color = conf.bar_color();

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (data == null || lngth < 1) return;

		if (bar_width <= 0) bar_width = 1;
		g.setColor(draw_color);
		height_factor = height_factor_value(bounds);
		row = first_row() - 1;
		for (i = 0; row < lngth; ++i, ++row) {
			// Prevent drawing bars for 0 values:
			if (((Double) data.get(i)).doubleValue() == 0) continue;

			x = x_values[row] + 1;
			y = (int)(bounds.height -
				(((Double) data.get(i)).doubleValue() - ymin) *
				height_factor + bounds.y);
			x_s[0] = x; x_s[1] = x + bar_width;
			x_s[2] = x_s[1]; x_s[3] = x_s[0];
			y_s[0] = y; y_s[1] = y;
			y_s[2] = bounds.height; y_s[3] = bounds.height;
			g.fillPolygon(x_s, y_s, 4);
		}
	}
}
