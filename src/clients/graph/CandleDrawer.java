package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing candles
 */
public class CandleDrawer extends Drawer {

	/**
	* Draw the data bars and the line segments connecting them.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int openy, highy, lowy, closey;
		int x, middle_x;
		int x_s[] = new int[Stride], y_s[] = new int[Stride];
		int lngth = data.length;
		int candlewidth = bounds.width / lngth + 5;
		Color original_color = g.getColor();
		boolean white;
		double width_factor, height_factor;

System.err.println("candle data length: " + lngth);
System.err.println("xmin, xmax, bounds.x, bounds.width, xrange: " +
xmin+", "+xmax+", "+bounds.x+", "+bounds.width+", "+xrange);

		if (data == null || lngth < Stride) return;

		width_factor = bounds.width / xrange;
		height_factor = bounds.height / yrange;
System.err.println("width_factor for candles: " + width_factor);
System.err.println("height_factor for candles: " + width_factor);
System.err.println("xmin, bounds.x, bounds.width, xrange: " +
xmin+", "+bounds.x+", "+bounds.width+", "+xrange);
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
//!!!experiment: x = (int)(bounds.x + (row-xmin)*(xrange/bounds.width));
			middle_x = x + candlewidth / 2;
			// For candle color, relation is reversed (< -> >) because
			// of the coordinate system used - higher coordinates have
			// a lower value.
			white = closey > openy? false: true;
System.err.println("x, middle_x, candlewidth: "+x+", "+middle_x+", "+
candlewidth);
System.err.println("openy, highy, lowy, closey, x, middle_x, white: "+
openy+", "+highy+", "+lowy+", "+closey+", "+x+", "+middle_x+", "+white);
System.err.println("row, data["+i+".."+(i+3)+"]: "+row+", "+data[i]+", "+
(data[i+1])+", "+(data[i+2])+", "+(data[i+3]));
			g.setColor(white? Color.green: Color.red);
			y_s[0] = openy; y_s[1] = openy; y_s[2] = closey; y_s[3] = closey;
			x_s[0] = x; x_s[1] = x + candlewidth;
			x_s[2] = x + candlewidth; x_s[3] = x;
			// Candle body
			g.fillPolygon(x_s, y_s, Stride);
			g.setColor(original_color);
			// Stems
			if (white) {
				g.drawLine(middle_x, closey, middle_x, highy);
				g.drawLine(middle_x, openy, middle_x, lowy);
			}
			else {
				g.drawLine(middle_x, closey, middle_x, lowy);
				g.drawLine(middle_x, openy, middle_x, highy);
			}
		}
	}

	// 4 points: open, high, low, close - no x coordinates
	public int drawing_stride() { return Stride; }

	private static final int Stride = 4;
}
