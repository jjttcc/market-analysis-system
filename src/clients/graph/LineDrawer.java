/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import application_support.*;

/**
 *  Abstraction for drawing data tuples as points connected by lines
 */
public class LineDrawer extends IndicatorDrawer {

	public LineDrawer(MarketDrawer md) { super(md); }

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
		int right_adjust = bar_width() / 2;
		if (data != null) lngth = data.size();
		double height_factor;
		MA_Configuration conf = MA_Configuration.application_instance();
		if (draw_color == null) {
			draw_color = conf.line_color();
		}
		int[] x_values = x_values();

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (lngth == 0 || x_values == null) return;

		g.setColor(draw_color);
		height_factor = height_factor_value(bounds);
		row = first_row() - 1;
		x0 = x_values[row] + right_adjust;
		y0 = (int)(bounds.height - (((Double)
			data.get(0)).doubleValue()-ymin) * height_factor + bounds.y);
		++row;

		for (i = 1; row < x_values.length && i < lngth; ++i, ++row) {
			x1 = x_values[row] + right_adjust;
			y1 = (int)(bounds.height - (((Double)
				data.get(i)).doubleValue()-ymin) * height_factor + bounds.y);
			g.drawLine(x0,y0,x1,y1);

			x0 = x1;
			y0 = y1;
		}
	}

	void draw_reference_values(Graphics g, Rectangle main_bounds,
			Rectangle ref_bounds) {
		super.draw_reference_values(g, main_bounds, ref_bounds);
	}
}
