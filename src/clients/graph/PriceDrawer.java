package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing price bars
 */
public class PriceDrawer extends Drawer {

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int openy, highy, lowy, closey;
		int x;
		int lngth = data.length;
		int sidebar_length = bounds.width / lngth + 3;
		Configuration conf = Configuration.instance();
		Color bar_color = conf.stick_color();
		double width_factor, height_factor;

		if (data == null || lngth < Stride) return;

		g.setColor(bar_color);
		width_factor = bounds.width / xrange;
		height_factor = bounds.height / yrange;
		for (i = 0, row = 1; i < lngth; i += Stride, ++row) {
			openy = (int) (bounds.height - (data[i] - ymin) * height_factor +
						bounds.y);
			highy = (int)(bounds.height - (data[i+1] - ymin) * height_factor +
						bounds.y);
			lowy = (int)(bounds.height - (data[i+2] - ymin) * height_factor +
						bounds.y);
			closey = (int)(bounds.height - (data[i+3] - ymin) * height_factor +
						bounds.y);
			x = (int)((row - xmin) * width_factor + bounds.x);
			// vertical low to high price line
			g.drawLine(x, lowy, x, highy);
			// horizontal line for close price
			g.drawLine(x, closey, x+sidebar_length, closey);
			if (_open_bar) {
				g.drawLine(x, openy, x-sidebar_length, openy);
			}
		}
	}

	// 4 points: open, high, low, close - no x coordinates
	public int drawing_stride() { return Stride; }

	// Is a bar for the open price to be drawn?
	public boolean open_bar() { return _open_bar; }

	// Set whether a bar for the open price is to be drawn.
	public void set_open_bar(boolean value) { _open_bar = value; }

	private static final int Stride = 4;

	private boolean _open_bar = false;
}
