package graph;

import java.awt.*;
import java.applet.*;
import java.util.*;
import java.lang.*;
import java.io.StreamTokenizer;
import java.io.InputStream;
import java.io.IOException;
import java.net.URL;
import support.Configuration;

/*
**************************************************************************
**
**                      Class  graph.Graph
**
**************************************************************************
**    Copyright (C) 1995, 1996 Leigh Brookshaw
**
**    This program is free software; you can redistribute it and/or modify
**    it under the terms of the GNU General Public License as published by
**    the Free Software Foundation; either version 2 of the License, or
**    (at your option) any later version.
**
**    This program is distributed in the hope that it will be useful,
**    but WITHOUT ANY WARRANTY; without even the implied warranty of
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**    GNU General Public License for more details.
**
**    You should have received a copy of the GNU General Public License
**    along with this program; if not, write to the Free Software
**    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
**************************************************************************
**    Modified by Jim Cochrane.
**    Changed name from Graph2D.
**************************************************************************
**
** The main entry point and interface for the 2D graphing package.
** This class keeps track of the DataSets and the Axes.
** It has the main drawing engine that positions axis etc.
**
*************************************************************************/


/**
 * This is the main plotting class. It partitions the canvas to contain the
 * specified axes with the remaining space taken with the plotting region.
 * Axes are packed against the walls of the canvas. The <B>paint</B> and
 * <B>update</B> methods of this class handle all the drawing operations of the
 * graph. This means that independent components like Axis and DataSets must be
 * registered with this class to be incorporated into the plot.
 *
 * @version  $Revision$, $Date$
 * @author   Leigh Brookshaw
 */

public class Graph extends Canvas {


/*
** Default Background Color
*/
	private Color DefaultBackground = null;



/*
*********************
**
** Protected Variables
**
*********************/

/**
 *  A vector list of All the axes attached
 *  @see Graph#attachAxis()
 */

	private Vector axis          = new Vector(4);

/**
 *  A vector list of All the DataSets attached
 *  @see Graph#attachDataSet()
 *  @see DataSet
 */

	protected Vector dataset       = new Vector(10);

/**
 *  The markers that may have been loaded
 *  @see Graph#setMarkers()
 */

	private Markers markers = null;

/**
 * The blinking "data loading" thread
 * @see Graph#startedloading()
 */

	private LoadMessage load_thread = null;

/**
 * The background color for the data window
 */
	protected Color DataBackground = null;


	// Symbol to display, if any
	private String symbol;

/*
**********************
**
** Variables
**
*********************/

/**
 *  If this is greater than zero it means that
 *  data loading threads are active so the message "loading data"
 *  is flashed on the plot canvas. When it is back to zero the plot
 *  progresses normally
 */
	private int  loadingData  = 0;


/**
 *  The width of the border at the top of the canvas. This allows 
 *  slopover from axis labels, legends etc.
 */
	private int     borderTop          = 20;

/**
 *  The width of the border at the bottom of the canvas. This allows 
 *  slopover from axis labels, legends etc.
 */
	private int     borderBottom       = 20;

/**
 *  The width of the border at the left of the canvas. This allows 
 *  slopover from axis labels, legends etc.
 */
	private int     borderLeft         = 20;

/**
 *  The width of the border at the right of the canvas. This allows 
 *  slopover from axis labels, legends etc.
 */
	private int     borderRight        = 20;

/**
 *  If set <I>true</I> a frame will be drawn around the data window.
 *  Any axes will overlay this frame.
 */
	private boolean frame        = true;

/**
 *  The color of the frame to be drawn
 */
	private Color   framecolor;

/**
 * If set <I>true</I> (the default) a grid will be drawn over the data window.
 * The grid will align with the major tic marks of the Innermost axes.
 */
	private boolean drawgrid     = true; 

/**
 * The color of the grid to be drawn
 */
	private Color   gridcolor    = Color.pink;

/**
 *  If set <I>true</I> (the default) a grid line will be drawn 
 *  across the data window
 *  at the zeros of the innermost axes.
 */
	private boolean drawzero     = true;

/**
 *  The color of the zero grid lines.
 */ 
	private Color   zerocolor    = Color.orange;

/**
 *  The rectangle that the data will be plotted within. This is an output
 *  variable only.
*/
	protected Rectangle datarect   = new Rectangle();

/**
 *  If set <I>true</I> (the default) the canvas will be set to the background
 *  color (erasing the plot) when the update method is called.
 *  This would only be changed for special effects.
 */
	protected boolean clearAll     = true;

/**
 *  If set <I>true</I> (the default) everything associated with the plot
 *  will be drawn when the update method or paint method are called.
 *  Normally
 *  only modified for special effects
*/
	protected boolean paintAll     = true;

/**
 *  Modify the position of the axis and the range of the axis so that
 *  the aspect ratio of the major tick marks are 1 and the plot is square
 *  on the screen
*/
	private boolean square = false;

  /**
   * Text to be painted Last onto the Graph Canvas.
   */
	private TextLine lastText = null;
/*
*******************
**
**  Public Methods
**
*******************/

	public void set_framecolor(Color c) { framecolor = c; }

	public void set_borderTop(int i) { borderTop = i; }

	public void set_borderBottom(int i) { borderBottom = i; }

	public void set_borderLeft(int i) { borderLeft = i; }

	public void set_borderRight(int i) { borderRight = i; }

/**
 * Attach a DataSet to the graph. By attaching the data set the class
 * can draw the data through its paint method.
 */

	public void attachDataSet(DataSet d) {
	if( d != null) {
		dataset.addElement(d);
		d.set_g2d(this);
	}
}
/**
 *    Detach the DataSet from the class. Data associated with the DataSet
 *    will nolonger be plotted.
 *
 *    @param d    The DataSet to detach.
 */

	public void detachDataSet( DataSet d ) {
		if(d != null) {
			if(d.xaxis() != null) d.xaxis().detachDataSet(d);
			if(d.yaxis() != null) d.yaxis().detachDataSet(d);
			dataset.removeElement(d);
		}
	}
/**
 *    Detach All the DataSets from the class.
*/

	public void detachDataSets() {
		DataSet d;
		int i;

		if(dataset == null | dataset.isEmpty() ) return;

		for (i=0; i<dataset.size(); i++) {
			d = ((DataSet)dataset.elementAt(i));
			if(d.xaxis() != null) d.xaxis().detachDataSet(d);
			if(d.yaxis() != null) d.yaxis().detachDataSet(d);
		}
		dataset.removeAllElements();
	}

	// Set symbol to be displayed to `s'.
	public void set_symbol(String s) {
		symbol = s;
	}

/**
 *    Create and attach an Axis to the graph. The position of the axis
 *    is one of Axis.TOP, Axis.BOTTOM, Axis.LEFT or Axis.RIGHT.
 *
 *    @param position   Position of the axis in the drawing window.
 *
*/
public Axis createAxis( int position ) {
	Axis a;

	try { 
		a =  new Axis(position);
		a.set_g2d(this);
		axis.addElement( a );
	}
	catch (Exception e) { 
		System.err.println("Failed to create Axis");
		e.printStackTrace();
		return null;
	}

	return a;
}
/**
 *  Attach a previously created Axis. Only Axes that have been attached will
 *  be drawn 
 *
 *    @param the Axis to attach.
*/
public void attachAxis( Axis a ) {
	if(a == null) return;

	try { 
		axis.addElement( a );
		a.set_g2d(this);
	}
	catch (Exception e) { 
		System.err.println("Failed to attach Axis");
		e.printStackTrace();
	}
}

/**
 * Detach a previously attached Axis.
 *    @param the Axis to dettach.
*/
	public void detachAxis( Axis a ) {
		if(a != null) {
			a.detachAll();
			a.set_g2d(null);
			axis.removeElement(a);
		}
	}

/**
 * Detach All attached Axes.
*/
	public void detachAxes() {
		int i;

		if(axis == null | axis.isEmpty() ) return;

		for (i=0; i<axis.size(); i++) {
			((Axis)axis.elementAt(i)).detachAll();
			((Axis)axis.elementAt(i)).set_g2d(null);
		}
		axis.removeAllElements();
	}

/**
 * Get the Maximum X value of all attached DataSets.
 *  @return  The maximum value
*/
	public double getXmax() {
		DataSet d;
		double max=0.0;

		if(dataset == null | dataset.isEmpty() ) return max;
		for (int i=0; i<dataset.size(); i++) {
			d = ((DataSet)dataset.elementAt(i));
			if(i==0) max = d.getXmax();
			else max = Math.max(max,d.getXmax());
		}

		return max;
	}

/**
 * Get the Maximum Y value of all attached DataSets.
 *  @return  The maximum value
*/
	public double getYmax() {
		DataSet d;
		double max=0.0;

		if(dataset == null | dataset.isEmpty() ) return max;
		for (int i=0; i<dataset.size(); i++) {
			d = ((DataSet)dataset.elementAt(i));
			if(i==0) max = d.getYmax();
			else max = Math.max(max,d.getYmax());
		}

		return max;
	}

/**
 * Get the Minimum X value of all attached DataSets.
 *  @return  The minimum value
*/

	public double getXmin() {
		DataSet d;
		double min = 0.0;

		if(dataset == null | dataset.isEmpty() ) return min;
		for (int i=0; i<dataset.size(); i++) {
			d = ((DataSet)dataset.elementAt(i));
			if(i==0) min = d.getXmin();
			else     min = Math.min(min,d.getXmin());
		}

		return min;
	}

/**
 * Get the Minimum Y value of all attached DataSets.
 *  @return  The minimum value
*/

public double getYmin() {
	DataSet d;
	double min=0.0;

	if(dataset == null | dataset.isEmpty() ) return min;
	for (int i=0; i<dataset.size(); i++) {
		d = ((DataSet)dataset.elementAt(i));
		if(i==0) min = d.getYmin();
		else     min = Math.min(min,d.getYmin());
	}

	return min;
}



/**
 *  Set the markers for the plot.
 *  @param m  Marker class containing the defined markers
 *  @see Markers
 */
	public void setMarkers(Markers m) {
		markers = m;
	}

/**
 *  Get the markers
 *  @return defined Marker class
 *  @see Markers
 */   
	public Markers getMarkers() {
		return markers;
	}

/**
 * Set the background color for the entire canvas.
 * @params c The color to set the canvas
 */
	public void setGraphBackground(Color c) {
		if(c == null) return;
		setBackground(c);
	}

/**
 * Set the background color for the data window.
 * @params c The color to set the data window. 
 */
	public void setDataBackground(Color c) {
		if(c == null) return;
		DataBackground = c;
	}

/**
 *  This paints the entire plot. It calls the draw methods of all the
 *  attached axis and data sets.
 *  The order of drawing is - Axis first, data legends next, data last.
 *  @params g Graphics state.
 */
	public void paint(Graphics g) {
		int i;
		Graphics lg  = g.create();
		Rectangle r = bounds();

		/* The r.x and r.y returned from bounds is relative to the
		** parents space so set them equal to zero.
		*/
		r.x = 0;
		r.y = 0;

		if (DefaultBackground == null) DefaultBackground=this.getBackground();
		if (DataBackground == null)    DataBackground=this.getBackground();

		if (!paintAll) return;

		r.x      += borderLeft;
		r.y      += borderTop;
		r.width  -= borderLeft+borderRight;
		r.height -= borderBottom+borderTop;


		paintFirst(lg,r);

		if (!axis.isEmpty()) {
			r = drawAxis(lg, r);
		} else {
		if (clearAll) {
				Color c = g.getColor();
				g.setColor(DataBackground);
				g.fillRect(r.x,r.y,r.width,r.height);
				g.setColor(c);
			}
			drawFrame(lg,r.x,r.y,r.width,r.height);
		}

		paintBeforeData(lg,r);

		if (!dataset.isEmpty()) {
			datarect.x      = r.x;
			datarect.y      = r.y;
			datarect.width  = r.width;
			datarect.height = r.height;

			for (i=0; i<dataset.size(); i++) {
				((DataSet)dataset.elementAt(i)).draw_data(lg,r);
			}
		}

		if (symbol != null && symbol.length() > 0) {
			display_text("[" + symbol + "]", g);
		}
		paintLast(lg,r);
		lg.dispose();
	}

/**
 *  A hook into the paint method. This is called before
 *  anything is plotted. The rectangle passed is the dimension of
 *  the canvas minus the border dimensions.
 *  @params g Graphics state
 *  @params r Rectangle containing the graph
 */
	public void paintFirst( Graphics g, Rectangle r) {}

/**
 *  A hook into the paint method. This is called before
 *  the data is drawn but after the axis. 
 *  The rectangle passed is the dimension of
 *  the data window.
 *  @params g Graphics state
 *  @params r Rectangle containing the data
 */
	public void paintBeforeData( Graphics g, Rectangle r) {}

/**
 *  A hook into the paint method. This is called after
 *  everything has been drawn. 
 *  The rectangle passed is the dimension of
 *  the data window.
 *  @params g Graphics state
 *  @params r Rectangle containing the data
 */
	public void paintLast( Graphics g, Rectangle r) {
		if( lastText != null ) {
			lastText.draw(g,r.width/2, r.height/2, TextLine.CENTER);
		}
	}

/**
 * This method is called via the repaint() method.
 * All it does is blank the canvas (with the background color)
 * before calling paint.
 */
	public void update(Graphics g) {
		if( clearAll ) {
			Color c = g.getColor();
			/* The r.x and r.y returned from bounds is relative to the
			** parents space so set them equal to zero
			*/
			Rectangle r = bounds();

			r.x = 0;
			r.y = 0;

			g.setColor(getBackground());
			g.fillRect(r.x,r.y,r.width,r.height);
			g.setColor(c);
		}

		if( paintAll ) paint(g);
	}
/**
 * Handle  keyDown events. Only one event is handled the pressing
 * of the key 'r' - this will repaint the canvas.
 */
	public boolean keyDown(Event e, int key) {
		if( key == 'r' ) {
			repaint();
			return true;
		}  else {
			return false;
		}
	}                                               

/**
 *  Calling this method pauses the plot and displays a flashing
 *  message on the screen. Mainly used when data is being loaded across the
 *  net. Everytime this routine is called a counter is incremented
 *  the method finishedloading() decrements the counter. When the
 *  counter is back to zero the plotting resumes.
 *  @see Graph#finishedloading()
 *  @see Graph#loadmessage()
 *  @see LoadMessage
*/
public void startedloading() {
	loadingData++;
	if(loadingData != 1) return;
	if(load_thread == null) load_thread = new LoadMessage(this);
	load_thread.setFont(new Font("Helvetica", Font.PLAIN, 25));
	load_thread.begin();
}

/**
 * Decrement the loading Data counter by one. When it is zero resume
 * plotting.
 *  @see Graph#startedloading()
 *  @see Graph#loadmessage()
 *  @see LoadMessage
*/
	public void finishedloading() {
		loadingData--;
		if(loadingData > 0) return;
		if(load_thread != null) load_thread.end();
		load_thread = null;
	}

/**
 * Change the message to be flashed on the canvas
 * @param s String contining the new message.
 * @see Graph#startedloading()
 * @see Graph#finishedloading()
 * @see LoadMessage
*/
	public void loadmessage(String s) {
		if(load_thread == null) load_thread = new LoadMessage(this);
		load_thread.setMessage(s);
	}                

/*
*******************
**
** Protected Methods
**
*******************/

	// Display `s' near the upper right corner of the graph.
	protected void display_text(String s, Graphics g) {
		g.setColor(Configuration.instance().text_color());
		g.drawString(s, 23, 23);
	}

/**
 *  Force the plot to have an aspect ratio of 1 by forcing the
 *  axes to have the same range. If the range of the axes
 *  are very different some extremely odd things can occur. All axes are
 *  forced to have the same range, so more than 2 axis is pointless.
 */
	protected Rectangle ForceSquare(Graphics g, Rectangle r) {
		Axis a;
		Rectangle dr;
		int x      = r.x;
		int y      = r.y;
		int width  = r.width;
		int height = r.height;
		double xmin;
		double xmax;
		double ymin;
		double ymax;
		double xrange = 0.0;
		double yrange = 0.0;
		double range;
		double aspect;

		if( dataset == null | dataset.isEmpty() ) return r; 

		/*
		**          Force all the axis to have the same range. This of course
		**          means that anything other than one xaxis and one yaxis
		**          is a bit pointless.
		*/
		for (int i=0; i<axis.size(); i++) {
			a = (Axis)axis.elementAt(i);
			range = a.maximum() - a.minimum();
			if(a.isVertical()) {
				yrange = Math.max(range, yrange);
			} else {
				xrange = Math.max(range, xrange);
			}
		}

		if (xrange <= 0 | yrange <= 0) return r; 

		if (xrange > yrange) range = xrange;
		else range = yrange;

		for (int i=0; i<axis.size(); i++) {
			a = (Axis)axis.elementAt(i);
			a.set_maximum(a.minimum() + range);
		}
		// Get the new data rectangle.
		dr = getDataRectangle(g, r);
		// Modify the data rectangle so that it is square.
		if(dr.width > dr.height) {
			x += (dr.width-dr.height)/2.0;
			width -= dr.width-dr.height;
		} else {
			y += (dr.height-dr.width)/2.0;
			height -= dr.height-dr.width;
		}

		return new Rectangle(x,y,width,height);
	}
/**
 *  Calculate the rectangle occupied by the data
 */

	protected Rectangle getDataRectangle(Graphics g, Rectangle r) {
		Axis a;
		int waxis;
		int x     = r.x;
		int y     = r.y;
		int width = r.width;
		int height = r.height;

		for (int i=0; i<axis.size(); i++) {
			a = ((Axis)axis.elementAt(i));
			waxis = a.getAxisWidth(g);

			switch (a.getAxisPos()) {
				case Axis.LEFT:
					x += waxis;
					width -= waxis;
					break;
				case Axis.RIGHT:
					width -= waxis;
					break;
				case Axis.TOP:
					y += waxis;
					height -= waxis;
					break;
				case Axis.BOTTOM:
					height -= waxis;
					break;
			}
		}

		return new Rectangle(x, y, width, height);
	}

/**
 *
 *  Draw the Axis. As each axis is drawn and aligned less of the canvas
 *  is avaliable to plot the data. The returned Rectangle is the canvas
 *  area that the data is plotted in.
 */
	protected Rectangle drawAxis(Graphics g, Rectangle r) {
		Axis a;
		int waxis;
		Rectangle dr;
		int x;
		int y;
		int width;
		int height;

		if(square) r = ForceSquare(g,r);

		dr = getDataRectangle(g,r);
		x      = dr.x;
		y      = dr.y;
		width  = dr.width;
		height = dr.height;

		if(clearAll ) {
			Color c = g.getColor();
			g.setColor(DataBackground);
			g.fillRect(x,y,width,height);
			g.setColor(c);
		}

		// Draw a frame around the data area (If requested)
		if(frame) drawFrame(g,x,y,width,height);

		// Now draw the axis in the order specified aligning them
		// with the final data area.
		for (int i=0; i<axis.size(); i++) {
			a = ((Axis)axis.elementAt(i));
			a.set_data_window(new Dimension(width,height));

			switch (a.getAxisPos()) {
				case Axis.LEFT:
					r.x += a.width();
					r.width -= a.width();
					a.positionAxis(r.x,r.x,y,y+height);
					if(r.x == x ) {
						a.set_gridcolor(gridcolor);
						a.set_drawgrid (drawgrid);
						a.set_zerocolor(zerocolor);
						a.set_drawzero (drawzero);
					}
					a.drawAxis(g);
					a.set_drawgrid (false);
					a.set_drawzero (false);
					break;
				case Axis.RIGHT:
					r.width -= a.width();
					a.positionAxis(r.x+r.width,r.x+r.width,y,y+height);
					if(r.x+r.width == x+width ) {
						a.set_gridcolor(gridcolor);
						a.set_drawgrid (drawgrid);
						a.set_zerocolor(zerocolor);
						a.set_drawzero (drawzero);
					}
					a.drawAxis(g);
					a.set_drawgrid (false);
					a.set_drawzero (false);
					break;
				case Axis.TOP:
					r.y += a.width();
					r.height -= a.width();
					a.positionAxis(x,x+width,r.y,r.y);
					if(r.y == y) {
						a.set_gridcolor(gridcolor);
						a.set_drawgrid (drawgrid);
						a.set_zerocolor(zerocolor);
						a.set_drawzero (drawzero);
					}
					a.drawAxis(g);
					a.set_drawgrid (false);
					a.set_drawzero (false);
					break;
				case Axis.BOTTOM:
					r.height -= a.width();
					a.positionAxis(x,x+width,r.y+r.height,r.y+r.height);
					if(r.y +r.height == y+height ) {
						a.set_gridcolor(gridcolor);
						a.set_drawgrid (drawgrid);
						a.set_zerocolor(zerocolor);
						a.set_drawzero (drawzero);
					}
					a.drawAxis(g);
					a.set_drawgrid (false);
					a.set_drawzero (false);
					break;
			}
		}

		return r;
	}
/*
 *  Draws a frame around the data area.
 */
	protected void drawFrame(Graphics g, int x, int y, int width, int height) {
		Color c = g.getColor();
		if( framecolor != null ) g.setColor(framecolor);
		g.drawRect(x,y,width,height);
		g.setColor(c);
	}
}

/**
 * This should be thrown if any of the packages fileloaders 
 * encounter a format error
*/
class FileFormatException extends Exception {
	public FileFormatException(String s) {
		super(s);
	}
}

/**
 *   This is a separate thread that flashes a message
 *   on the Graph canvas that data is loading
 */

class LoadMessage extends Thread {
	Graph  g2d;
	String   message    = "Loading Data ... Please Wait!";
	String   newmessage = null;
	long     visible    = 500;
	long     invisible  = 200;
	Color    foreground = Color.red;
	Graphics lg = null;
	Font     f = null;

/**
 *    Instantiate the class
 * @param g2d The Graph canvas to draw message on
 *
 */            
	public LoadMessage(Graph g2d) {
		this.g2d = g2d;
	}

/**
 *  Instantiate the class
 * @param g2d The Graph canvas to draw message on
 * @param s   The string to flash on the canvas
 */            
public LoadMessage(Graph g2d, String s) {
	this(g2d);
	this.message = s;
}

/**
 *  Instantiate the class
 * @param g2d The Graph canvas to draw message on
 * @param s   The string to flash on the canvas
 * @param visible Number of milliseconds the message is visible
 * @param invisible Number of milliseconds the message is invisible
 */            

	public LoadMessage(Graph g, String s, long visible, long invisible) {
		this(g,s);
		this.visible = visible;
		this.invisible = invisible;
	}

/**
 *   begin displaying the message
 */
	public void begin() {
		g2d.clearAll = false;
		g2d.paintAll = false;
		super.start();
	}

/**
 *   end displaying message and force a graph repaint
 */
	public void end() {
		super.stop();
		g2d.clearAll = true;
		g2d.paintAll = true;
		if(lg != null) lg.dispose();
		g2d.repaint();
	}

/**
 *   The method to call when the thread starts
 */
	public void run() {
		boolean draw = true;
		FontMetrics fm;
		Rectangle r;
		int sw = 0;
		int sa = 0;
		int x  = 0;
		int y  = 0;

		setPriority(Thread.MIN_PRIORITY);
		while(true) {
			if( newmessage != null && draw) {
				message = newmessage;
				newmessage = null;
			}
			if(lg == null) {
				lg = g2d.getGraphics();
				if(lg != null) lg = lg.create();
			}

			if( lg != null) {
				if(f != null) lg.setFont(f);
				fm = lg.getFontMetrics(lg.getFont());
				sw = fm.stringWidth(message);
				sa = fm.getAscent();
			} else {
				draw = false;
			}

			if (draw) {
				lg.setColor(foreground);
				r = g2d.bounds();
				x = r.x + (r.width-sw)/2;
				y = r.y + (r.height+sa)/2;
				lg.drawString(message, x, y);
				g2d.repaint();
				try { sleep(visible); }
				catch(Exception e) { }
			} else {
				if(lg != null) {
					lg.setColor(g2d.getBackground());
					lg.drawString(message, x, y);
					g2d.repaint();
				}
				try { sleep(invisible); }
				catch(Exception e) { }
			}
			draw = !draw;
		}
	}

  /**
   * Set the font the message will be displayed in
   * @param f the font
   */
	public void setFont(Font f) {
		this.f = f;
	}

  /**
   *  The foreground color for the message
   * @param c the foreground color
   */

	public void setForeground(Color c) {
		if(c == null) return;
		this.foreground = c;
	}
  /**
   *   Set the message to be displayed
   * @param s the message
   */

	public void setMessage(String s) {
		if(s==null) return;
		newmessage = s;
	}
}
