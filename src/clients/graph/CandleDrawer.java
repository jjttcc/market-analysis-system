/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing candles
 */
public class CandleDrawer extends MarketDrawer {

	/**
	* Draw the candles.
	* @param g Graphics context
	* @param w Data window
	* Assumption: Stride >= 4 and the first four fields of each tuple
	* contain the open, high, low, and close, respectively.
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int openy, highy, lowy, closey;
		int x, middle_x;
		int x_s[] = new int[4], y_s[] = new int[4];
		int lngth = 0;
		if (_data != null) lngth = _data.length;
		if (lngth == 0) return;

		int candlewidth = bounds.width / lngth * 3 + 1;
		Configuration conf = Configuration.instance();
		Color black = conf.black_candle_color();
		Color white = conf.white_candle_color();
		Color wick_color = conf.stick_color();
		boolean is_white;
		double width_factor, height_factor;

		if (_data == null || lngth < Stride) return;

		_x_values = new int[tuple_count()];
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
			middle_x = x + candlewidth / 2;
			_x_values[row-1] = x;
			// For candle color, relation is reversed (< -> >) because
			// of the coordinate system used - higher coordinates have
			// a lower value.
			is_white = closey > openy? false: true;
			if (openy == closey) {	// If it's a doji
				draw_doji_line(g, x, closey, candlewidth);
			}
			else {					// Not a doji - regular candle
				g.setColor(is_white? white: black);
				y_s[0] = openy; y_s[1] = openy;
				y_s[2] = closey; y_s[3] = closey;
				x_s[0] = x; x_s[1] = x + candlewidth;
				x_s[2] = x + candlewidth; x_s[3] = x;
				// Candle body
				g.fillPolygon(x_s, y_s, Stride);
			}
			g.setColor(wick_color);
			// Stems
			if (is_white) {
				g.drawLine(middle_x, closey, middle_x, highy);
				g.drawLine(middle_x, openy, middle_x, lowy);
			}
			else {
				g.drawLine(middle_x, closey, middle_x, lowy);
				g.drawLine(middle_x, openy, middle_x, highy);
			}
		}
	}

	// Draw the horizontal line indicating a doji.
	protected void draw_doji_line(Graphics g, int x, int y, int candlewidth) {
		g.setColor(Configuration.instance().stick_color());
		g.drawLine(x, y, x + candlewidth, y);
	}
}
