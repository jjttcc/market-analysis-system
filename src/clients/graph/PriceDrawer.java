/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import application_support.*;

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
		final int x_adjust = 0;
		int lngth = 0;
		if (data != null) lngth = data.size();
		if (lngth == 0) return;

		_bar_width = (int) ((double) base_bar_width(bounds, lngth / 4) * .75);
		MA_Configuration conf = MA_Configuration.application_instance();
		Color bar_color = conf.stick_color();
		double width_factor, height_factor;

		if (data == null || lngth < Stride) return;

		x_values = new int[tuple_count()];
		g.setColor(bar_color);
		width_factor = width_factor_value(bounds, lngth / 4);
		height_factor = height_factor_value(bounds);
		row = first_row();
		for (i = row - 1; i < lngth; i += Stride, ++row) {
			openy = (int) (bounds.height -
				(((Double) data.get(i)).doubleValue() - ymin) *
				height_factor + bounds.y);
			highy = (int)(bounds.height -
				(((Double) data.get(i+1)).doubleValue() - ymin) *
				height_factor + bounds.y);
			lowy = (int)(bounds.height -
				(((Double) data.get(i+2)).doubleValue() - ymin) *
				height_factor + bounds.y);
			closey = (int)(bounds.height -
				(((Double) data.get(i+3)).doubleValue() - ymin) *
				height_factor + bounds.y);
			x = (int)((row - xmin) * width_factor + bounds.x) + x_adjust;
			x_values[row-1] = x;
			// vertical low to high price line
			g.drawLine(x, lowy, x, highy);
			// horizontal line for close price
			g.drawLine(x, closey, x + _bar_width, closey);
			if (_open_bar) {
				g.drawLine(x, openy, x - _bar_width, openy);
			}
		}
	}

	// Is a bar for the open price to be drawn?
	public boolean open_bar() { return _open_bar; }

	// Set whether a bar for the open price is to be drawn.
	public void set_open_bar(boolean value) { _open_bar = value; }

	private boolean _open_bar = false;
}
