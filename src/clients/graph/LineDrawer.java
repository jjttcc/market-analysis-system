/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data tuples as points connected by lines
 */
public class LineDrawer extends IndicatorDrawer {

	public LineDrawer(Drawer md) { super(md); }

	/**
	* Draw the data bars and the line segments connecting them.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x0, y0;
		int x1, y1;
		int lngth = 0;
		if (_data != null) lngth = _data.length;
		double height_factor;
		Configuration conf = Configuration.instance();
		if (draw_color == null) {
			draw_color = conf.line_color();
		}
		int[] _x_values = x_values();

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (_data == null || lngth < 1) return;

		g.setColor(draw_color);
		height_factor = height_factor_value(bounds);
		row = first_row() - 1;
		x0 = _x_values[row];
		y0 = (int)(bounds.height - (_data[0]-ymin) * height_factor + bounds.y);
		++row;

		for (i = 1; i < lngth; ++i, ++row) {
			x1 = _x_values[row];
			y1 = (int)(bounds.height - (_data[i]-ymin) * height_factor +
					bounds.y);
			g.drawLine(x0,y0,x1,y1);

			x0 = x1;
			y0 = y1;
		}
	}
}
