package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing data tuples as points connected by lines
 */
public class LineDrawer extends Drawer {

	/**
	* Draw the data bars and the line segments connecting them.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x0, y0;
		int x1, y1;
		int lngth = data.length;
		double width_factor, height_factor;

System.err.println("line data length: " + lngth);

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (data == null || lngth < Stride) return;

		width_factor = bounds.width / xrange;
		height_factor = bounds.height / yrange;
System.err.println("width factor for lines: " + width_factor);
System.err.println("height factor for lines: " + height_factor);
System.err.println("xmin, xmax, bounds.x, bounds.width, xrange: " +
xmin+", "+xmax+", "+bounds.x+", "+bounds.width+", "+xrange);
		row = 1;
		x0 = (int)((row - xmin) * width_factor + bounds.x);
		y0 = (int)(bounds.height - (data[0]-ymin) * height_factor + bounds.y);
		++row;

		for (i = Stride; i < lngth; i += Stride, ++row) {
			x1 = (int)((row - xmin) * width_factor + bounds.x);
			y1 = (int)(bounds.height - (data[i]-ymin) * height_factor +
					bounds.y);
System.err.println("row, data["+i+"], x1, y1: "+row+", "+data[i]+", "+
x1+", "+y1);
			g.drawLine(x0,y0,x1,y1);

			/*
			** The reason for the convolution above is to avoid calculating
			** the points over and over. Now just copy the second point to the
			** first and grab the next point
			*/
			x0 = x1;
			y0 = y1;
		}
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return Stride; }

	private static final int Stride = 1;
}
