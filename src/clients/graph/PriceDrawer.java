/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing price bars
 */
public class PriceDrawer extends MarketDrawer {

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int openy, highy, lowy, closey;
		int x;
		int lngth = 0;
		if (_data != null) lngth = _data.length;
		if (lngth == 0) return;

		int sidebar_length = bounds.width / lngth + 3;
		Configuration conf = Configuration.instance();
		Color bar_color = conf.stick_color();
		double width_factor, height_factor;

		if (_data == null || lngth < Stride) return;

		_x_values = new int[tuple_count()];
		g.setColor(bar_color);
		width_factor = width_factor_value(bounds);
		height_factor = height_factor_value(bounds);
		row = first_row();
		for (i = row - 1; i < lngth; i += Stride, ++row) {
			openy = (int) (bounds.height - (_data[i] - ymin) * height_factor +
						bounds.y);
			highy = (int)(bounds.height - (_data[i+1] - ymin) * height_factor +
						bounds.y);
			lowy = (int)(bounds.height - (_data[i+2] - ymin) * height_factor +
						bounds.y);
			closey = (int)(bounds.height - (_data[i+3] - ymin) * height_factor +
						bounds.y);
			x = (int)((row - xmin) * width_factor + bounds.x);
			_x_values[row-1] = x;
			// vertical low to high price line
			g.drawLine(x, lowy, x, highy);
			// horizontal line for close price
			g.drawLine(x, closey, x+sidebar_length, closey);
			if (_open_bar) {
				g.drawLine(x, openy, x-sidebar_length, openy);
			}
		}
	}

	// Is a bar for the open price to be drawn?
	public boolean open_bar() { return _open_bar; }

	// Set whether a bar for the open price is to be drawn.
	public void set_open_bar(boolean value) { _open_bar = value; }

	private boolean _open_bar = false;
}
