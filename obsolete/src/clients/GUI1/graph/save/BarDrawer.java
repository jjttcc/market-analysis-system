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
	protected void draw_tuples(Graphics g, Rectangle bounds, Rectangle clip) {
		int i;
		int j;
		boolean inside0 = false;
		boolean inside1 = false;
		double x,y;
		int x0 = 0 , y0 = 0;
		int x1 = 0 , y1 = 0;
		int xcmin = clip.x;
		int xcmax = clip.x + clip.width;
		int ycmin = clip.y;
		int ycmax = clip.y + clip.height;

		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if( data == null || data.length < stride ) return;

		// Is the first point inside the drawing region ?
		if( (inside0 = inside(data[0], data[1])) ) {
			x0 = (int)(bounds.x + ((data[0]-xmin)/xrange)*bounds.width);
			y0 = (int)(bounds.y +
			(1.0 - (data[1]-ymin)/yrange)*bounds.height);
			if( x0 < xcmin || x0 > xcmax || y0 < ycmin || y0 > ycmax) {
				inside0 = false;
			}
		}

		for(i=stride; i<length; i+=stride) {
				// Is this point inside the drawing region?
				inside1 = inside( data[i], data[i+1]);
				// If one point is inside the drawing region,
				// calculate the second point.
				if ( inside1 || inside0 ) {
				x1 = (int)(bounds.x + ((data[i]-xmin)/xrange)*bounds.width);
				y1 = (int)(bounds.y +
				(1.0 - (data[i+1]-ymin)/yrange)*bounds.height);
				if( x1 < xcmin || x1 > xcmax || y1 < ycmin || y1 > ycmax) {
					inside1 = false;
				}
			}
			// If the second point is inside calculate the first point if it
			// was outside
			if ( !inside0 && inside1 ) {
				x0 = (int)(bounds.x +
				((data[i-stride]-xmin)/xrange)*bounds.width);
				y0 = (int)(bounds.y +
				(1.0 - (data[i-stride+1]-ymin)/yrange)*bounds.height);
			}
			// If either point is inside draw the segment
			if ( inside0 || inside1 )  {
				g.drawLine(x0,y0,x1,y1);
				//g.drawLine(x0,y0 + 25,x1,y1 + 25);
			}

			/*
			** The reason for the convolution above is to avoid calculating
			** the points over and over. Now just copy the second point to the
			** first and grab the next point
			*/
			inside0 = inside1;
			x0 = x1;
			y0 = y1;
		}
	}
}
