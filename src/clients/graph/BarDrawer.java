package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data as a bar graph
 */
public class BarDrawer extends Drawer {

	public void set_data(Object d) {
		data = (double[]) d;
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return Stride; }

	public int data_length() {
		int result;
		if (data != null) {
			result = data.length;
		} else {
			result = 0;
		}
		return result;
	}

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

		_x_values = new int[tuple_count()];
		if (bar_width <= 0) bar_width = 1;
		g.setColor(conf.bar_color());
		width_factor = width_factor_value(bounds);
		height_factor = height_factor_value(bounds);
		for (i = 0, row = 1; i < lngth; i += Stride, ++row) {
			x = (int)((row - xmin) * width_factor + bounds.x);
			_x_values[row-1] = x;
			y = (int)(bounds.height - (data[i]-ymin) * height_factor +
					bounds.y);
			x_s[0] = x; x_s[1] = x + bar_width;
			x_s[2] = x_s[1]; x_s[3] = x_s[0];
			y_s[0] = y; y_s[1] = y;
			y_s[2] = bounds.height; y_s[3] = bounds.height;
			g.fillPolygon(x_s, y_s, 4);
		}
	}

	private static final int Stride = 1;

	protected double data[];
}
