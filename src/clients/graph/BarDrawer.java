package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing price bars
 */
public class BarDrawer extends Drawer {

	/**
	* Draw the data bars.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		double x,y;
		int x0, y0;
		int x1, y1;

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if( data == null || data.length < Stride ) return;

		x0 = (int)(bounds.x + ((data[0]-xmin)/xrange)*bounds.width);
		y0 = (int)(bounds.y + (1.0 - (data[1]-ymin)/yrange)*bounds.height);

//!!!Change to not draw lines - just draw the current tuple; and get x[01]
//!!!from the current row, not from data.
		for (i = Stride, row = 1; i < data.length; i += Stride, ++row) {
			// Calculate the second point.
			x1 = (int)(bounds.x + ((data[i]-xmin)/xrange)*bounds.width);
			y1 = (int)(bounds.y + (1.0 -
					(data[i+1]-ymin)/yrange)*bounds.height);
			g.drawLine(x0,y0,x1,y1);
			x0 = x1;
			y0 = y1;
		}
	}

	// 4 points: open, high, low, close - no x coordinates
	public int drawing_stride() { return Stride; }

	private static final int Stride = 4;
}
