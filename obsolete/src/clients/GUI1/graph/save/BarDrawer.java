package graph;

import java.awt.*;
import java.util.*;

/**
 *  Abstraction for drawing price bars
 */
public class BarDrawer {

	private void draw_horizontal_lines(Graphics g, Rectangle bounds,
			Vector hline_data) {
		if (hline_data == null) return;

		int y1, y2;
		double d1, d2;
		for (int i = 0; i < hline_data.size(); ++i) {
			d1 = ((DoublePair) hline_data.elementAt(i)).left();
			d2 = ((DoublePair) hline_data.elementAt(i)).right();
			y1 = (int)(bounds.y + (1.0 - (d1-ymin) / yrange) * bounds.height);
			y2 = (int)(bounds.y + (1.0 - (d2-ymin) / yrange) * bounds.height);
			g.drawLine(bounds.x, y1, bounds.x + bounds.width, y2);
		}
	}

	private void draw_vertical_lines(Graphics g, Rectangle bounds,
			Vector vline_data) {
		if (vline_data == null) return;

		int x1, x2;
		double d1, d2;
		for (int i = 0; i < vline_data.size(); ++i) {
			d1 = ((DoublePair) vline_data.elementAt(i)).left();
			d2 = ((DoublePair) vline_data.elementAt(i)).right();
			x1 = (int)(bounds.x + ((d1-xmin) / xrange) * bounds.width);
			x2 = (int)(bounds.x + ((d2-xmin) / xrange) * bounds.width);
			g.drawLine(x1, bounds.y, x2, bounds.y + bounds.height);
		}
	}

	public void set_data(double d[]) {
		data = d;
	}

	public void set_xaxis(Axis a) {
		xaxis = a;
	}

	public void set_yaxis(Axis a) {
		yaxis = a;
	}

	public void set_clipping(boolean b) {
		clipping = b;
	}

	public void set_maxes(double xmax_v, double ymax_v,
		double xmin_v, double ymin_v) {
		xmax = xmax_v;
		ymax = ymax_v;
		xmin = xmin_v;
		ymin = ymin_v;
	}

	public void set_ranges (double x, double y) {
		xrange = x;
		yrange = y;
	}

	public void set_linestyle(int s) {
		linestyle = s;
	}

    public void set_stride(int s) {
		stride = s;
	}

	public void set_length (int l) {
		length = l;
	}

  /**
   * Draw the data bars and the line segments connecting them.
   * If this data has been attached to an Axis then scale the data
   * based on the axis maximum/minimum otherwise scale using
   * the data's maximum/minimum
   * @param g Graphics state
   * @param bounds The data window to draw into
   */
//!!!Move this into a new parent class - Drawer.
	public void draw_data(Graphics g, Rectangle bounds, Vector hlines,
		Vector vlines) {
		Color c;

		if ( xaxis != null ) {
			xmax = xaxis.maximum;
			xmin = xaxis.minimum;
		}

		if ( yaxis != null ) {
			ymax = yaxis.maximum;
			ymin = yaxis.minimum;
		}

		xrange = xmax - xmin;
		yrange = ymax - ymin;

		/*
		** Clip the data window
		*/
		if(clipping) {
			g.clipRect(bounds.x, bounds.y, bounds.width, bounds.height);
		}

		draw_horizontal_lines(g, bounds, hlines);
		draw_vertical_lines(g, bounds, vlines);
		if( linestyle != DataSet.NOLINE ) {
			draw_tuples(g,bounds);
		}    
	}

  /**
   * Draw the data bars and the line segments connecting them.
   * @param g Graphics context
   * @param w Data window
   */
      protected void draw_tuples(Graphics g, Rectangle bounds) {
          int i;
          int j;
          boolean inside0 = false;
          boolean inside1 = false;
          double x,y;
          int x0 = 0 , y0 = 0;
          int x1 = 0 , y1 = 0;
//     Calculate the clipping rectangle
          Rectangle clip = g.getClipRect();
          int xcmin = clip.x;
          int xcmax = clip.x + clip.width;
          int ycmin = clip.y;
          int ycmax = clip.y + clip.height;


//    Is there any data to draw? Sometimes the draw command will
//    will be called before any data has been placed in the class.
          if( data == null || data.length < stride ) return;
          
//    Is the first point inside the drawing region ?
          if( (inside0 = inside(data[0], data[1])) ) {

              x0 = (int)(bounds.x + ((data[0]-xmin)/xrange)*bounds.width);
              y0 = (int)(bounds.y +
					(1.0 - (data[1]-ymin)/yrange)*bounds.height);

              if( x0 < xcmin || x0 > xcmax || 
                  y0 < ycmin || y0 > ycmax)  inside0 = false;

          }

          for(i=stride; i<length; i+=stride) {
//        Is this point inside the drawing region?
              inside1 = inside( data[i], data[i+1]);
//        If one point is inside the drawing region calculate the second point
              if ( inside1 || inside0 ) {

               x1 = (int)(bounds.x + ((data[i]-xmin)/xrange)*bounds.width);
               y1 = (int)(bounds.y +
						(1.0 - (data[i+1]-ymin)/yrange)*bounds.height);

               if( x1 < xcmin || x1 > xcmax || 
                   y1 < ycmin || y1 > ycmax)  inside1 = false;

              }
//        If the second point is inside calculate the first point if it
//        was outside
              if ( !inside0 && inside1 ) {

                x0 = (int)(bounds.x +
						((data[i-stride]-xmin)/xrange)*bounds.width);
                y0 = (int)(bounds.y +
						(1.0 - (data[i-stride+1]-ymin)/yrange)*bounds.height);

              }
//        If either point is inside draw the segment
              if ( inside0 || inside1 )  {
					g.drawLine(x0,y0,x1,y1);
					//g.drawLine(x0,y0 + 25,x1,y1 + 25);
              }

/*
**        The reason for the convolution above is to avoid calculating
**        the points over and over. Now just copy the second point to the
**        first and grab the next point
*/
              inside0 = inside1;
              x0 = x1;
              y0 = y1;

          }

      }

  /**
   *  Return true if the point (x,y) is inside the allowed data range.
   */

      protected boolean inside(double x, double y) {
          if( x >= xmin && x <= xmax && 
              y >= ymin && y <= ymax )  return true;
          
          return false;
      }

	protected double data[];
	protected Axis xaxis;
	protected Axis yaxis;
	protected double xmax, ymax, xmin, ymin;
	protected double xrange, yrange;
	protected boolean clipping;
	public int linestyle;
    protected int stride = 2;
	protected int length;
}
