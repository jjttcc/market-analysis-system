package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data as a bar graph
 */
public class BarDrawer extends IndicatorDrawer {

	public BarDrawer(Drawer md) { super(md); }

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x, y;
		int lngth = _data.length;
		int bar_width = bounds.width / lngth - 2;
		double width_factor, height_factor;
		int x_s[] = new int[4], y_s[] = new int[4];
		Configuration conf = Configuration.instance();
		int[] _x_values = x_values();

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (_data == null || lngth < 1) return;

		if (bar_width <= 0) bar_width = 1;
		g.setColor(conf.bar_color());
		width_factor = width_factor_value(bounds);
		height_factor = height_factor_value(bounds);
		row = first_row() - 1;
		for (i = 0; i < lngth; ++i, ++row) {
			x = _x_values[row];
			y = (int)(bounds.height - (_data[i]-ymin) * height_factor +
					bounds.y);
			x_s[0] = x; x_s[1] = x + bar_width;
			x_s[2] = x_s[1]; x_s[3] = x_s[0];
			y_s[0] = y; y_s[1] = y;
			y_s[2] = bounds.height; y_s[3] = bounds.height;
			g.fillPolygon(x_s, y_s, 4);
		}
	}
}
