package graph;

import java.awt.*;

/*
**************************************************************************
**
**    Class  InteractiveGraph
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
**    Modified by Jim Cochrane, last changed in October, 2000
**    Changed name from G2Dint.
**************************************************************************
**
**    This class is an extension of Graph class.
**    It adds interactive selection of the plotting range
**    and can display the mouse position in user coordinates.
**
*************************************************************************/

/**
 *    This class is an extension of Graph class.
 *    It adds interactive selection of the plotting range
 *    and can display the mouse position in user coordinates.
 *
 *    <h4>Mouse Events</h4>
 *    <dl>
 *     <dt>MouseDown
 *     <dd>Starts the range selection
 *     <dt>MouseDrag
 *     <dd>Drag out a rectangular range selection
 *     <dt>MouseUp
 *     <dd>Replot with modified plotting range.
 *     <dt>
 *    </dl>
 *    <h4>KeyDown Events</h4>
 *    <dl>
 *     <dt>R
 *     <dd>Redraw plot with default limits
 *     <dt>r
 *     <dd>Redraw plot using current limits
 *     <dt>m
 *     <dd>Pop window to enter manually plot range
 *     <dt>c
 *     <dd>Toggle pop-up window that displays the mouse position
 *         in user coordinates
 *     <dt>d
 *     <dd>Show coordinates of the closest data point to the cursor
 *     <dt>D
 *     <dd>Hide data coordinates pop-window
 *     <dt>h
 *     <dd>This key pressed in Any pop-window at any-time will hide it.
 *    </dl>
 *    <P>
 *    <B>Note:</B> To hide Any pop-window press the key <B>h</B> in the
 *    window. This will hide the window at any time. Depending on your
 *    windowing system the mouse button might have to be pressed in the
 *    popup window to ensure it has the keyboard focus.
 *
 * @version $Revision$, $Date$.
 * @author Leigh Brookshaw
 */

abstract public class InteractiveGraph extends Graph {

	public InteractiveGraph () { super(); }

/**
 *    Set to true when a rectangle is being dragged out by the mouse
 */
	private boolean drag = false;
/**
 *    User limits. The user has set the limits using the mouse drag option
 */
	private boolean userlimits = false;

/**
 *    Ths popup window for the cursor position command
 */
	private Gin cpgin = null;
/**
 *    Ths popup window for the data point command
 */
	private Gin dpgin = null;
/**
 *    The popup window to manually set the range
 */
	private Range range = null;
/**
 *    Button Down position
 */
	private int x0,y0;
/**
 *    Button Drag position
 */
	private int  x1,y1;
/*
**    Previous Button Drag position
*/
	private int x1old, y1old;

/**
 *    Attached X Axis which must be registered with this class.
 *    This is one of the axes used to find the drag range.
 *    If no X axis is registered no mouse drag.
 */
	private Axis xaxis;
/**
 *    Attached Y Axis which must be registered with this class.
 *    This is one of the axes used to find the drag range.
 *    If no Y axis is registered no mouse drag.
 */
	private Axis yaxis;


/**
 *    Create Xaxis to be used for the drag scaling
 */
	public Axis createXAxis() {
		xaxis = super.createAxis(Axis.BOTTOM);
		return xaxis;
	}

/**
 *    Create Yaxis to be used for the drag scaling
 */
	public Axis createYAxis() {
		yaxis = super.createAxis(Axis.LEFT);
		return yaxis;
	}

/**
 *    Attach axis to be used for the drag scaling. X axes are assumed to
 *    have Axis position Axis.BOTTOM or Axis.TOP. Y axes are assumed
 *    to have position Axis.LEFT or Axis.RIGHT.
 * @param a Axis to attach
 * @see Axis
 */
	public void attachAxis(Axis a) {
		if (a==null) return;
		super.attachAxis(a);         
		if (a.getAxisPos() == Axis.BOTTOM || a.getAxisPos() == Axis.TOP) {
			xaxis = a;
		} else {
			yaxis = a;
		}
	}

/**
 *  New update method incorporating mouse dragging.
 */
	public void update(Graphics g) {
		Rectangle r = bounds();
		Color c = g.getColor();

		/* The r.x and r.y returned from bounds is relative to the
		** parents space so set them equal to zero
		*/
		r.x = 0;
		r.y = 0;

		if (drag) {
			/**
			* Set the dragColor. Do it everytime just incase someone
			* is playing silly buggers with the background color. 
			*/
			g.setColor(DataBackground);
			float hsb[] = Color.RGBtoHSB(DataBackground.getRed(),
				DataBackground.getGreen(), DataBackground.getBlue(), null);

			if (hsb[2] < 0.5) g.setXORMode(Color.white);
			else g.setXORMode(Color.black);

			/*
			**         Drag out the new box.
			**         Use drawLine instead of drawRect to avoid problems
			**         when width and heights become negative. Seems drawRect
			**         can't handle it!
			*/

			/*
			** Draw over old box to erase it. This works because XORMode
			** has been set. If from one call to the next the background
			** color changes going to get some odd results.
			*/
			g.drawLine(x0, y0, x1old, y0);
			g.drawLine(x1old, y0, x1old, y1old);
			g.drawLine(x1old, y1old, x0, y1old);
			g.drawLine(x0, y1old, x0, y0);
			/*
			** draw out new box
			*/
			g.drawLine(x0, y0, x1, y0);
			g.drawLine(x1, y0, x1, y1);
			g.drawLine(x1, y1, x0, y1);
			g.drawLine(x0, y1, x0, y0);
			/*
			** Set color back to default color
			*/
			g.setColor(c);

			x1old = x1;
			y1old = y1;

			return;
		}

		if ( clearAll ) {
			g.setColor(getBackground());
			g.fillRect(r.x,r.y,r.width,r.height);
			g.setColor(c);
		}
		if (paintAll) paint(g);
	}

/**
 * Handle the Key Down events.
 */
	public boolean keyDown(Event e, int key) {
		if (xaxis==null || yaxis==null) return false;

		switch ( key ) {
			case 'R':
				xaxis.resetRange();
				yaxis.resetRange();
				userlimits = false;
				repaint();
				return true;
			case 'r':
				repaint();
				return true;
			case 'c':
				if ( cpgin == null) cpgin = new Gin("Position");
				if ( cpgin.isVisible() ) {
					cpgin.hide();
				} else {
					cpgin.show();
				}
				return true;
			case 'D':
			if (dpgin != null) dpgin.hide();
			return true; 
			case 'd':
				if (dpgin == null) dpgin = new Gin("Data Point");
				dpgin.show();
				double d[] = closest_point(e.x, e.y);
				dpgin.setXlabel( d[0] );
				dpgin.setYlabel( d[1] );
				int ix = xaxis.getInteger(d[0]);
				int iy = yaxis.getInteger(d[1]);
				if (ix >= datarect.x && ix <= datarect.x +datarect.width && 
					iy >= datarect.y && iy <= datarect.y +datarect.height) {
					Graphics g = getGraphics();
					g.fillOval(ix-4, iy-4, 8, 8);
				}
				return true;
			case 'm':
				if (range == null) range = new Range(this);
				range.show();
				range.requestFocus();
				userlimits = true;
				return true;
			default:
// System.out.println("KeyPress "+e.key);
				return false;
		}
	}

/**
 * Handle the Mouse Down events
 */
	public boolean mouseDown(Event e, int x, int y) {
		if (xaxis==null || yaxis==null) return false;
		// As soon as the mouse button is pressed request the Focus;
		// otherwise we will miss key events.
		requestFocus();

		x0 = x;
		y0 = y;

		drag = true; 
		x1old = x0;
		y1old = y0;

		if (x0 < datarect.x) x0 = datarect.x;
		else if (x0 > datarect.x + datarect.width) {
			x0 = datarect.x + datarect.width;
		}

		if (y0 < datarect.y) y0 = datarect.y;
		else if (y0 > datarect.y + datarect.height) {
			y0 = datarect.y + datarect.height;
		}

		return true;
	}

/**
 * Handle the Mouse Up events
 */
	public boolean mouseUp(Event e, int x, int y) {
		if (xaxis==null || yaxis==null) return false;

		x1   = x;
		y1   = y;
		if (drag) userlimits = true;
		drag = false;

		if (x1 < datarect.x) x1 = datarect.x;
		else if (x1 > datarect.x + datarect.width ) {
			x1 = datarect.x + datarect.width;
		}

		if (y1 < datarect.y) y1 = datarect.y;
		else if (y1 > datarect.y + datarect.height )  {
			y1 = datarect.y + datarect.height;
		}
		if ( Math.abs(x0-x1) > 5 &&  Math.abs(y0-y1) > 5 ) {
			if (x0 < x1 ) {                
				xaxis.set_minimum(xaxis.getDouble(x0));
				xaxis.set_maximum(xaxis.getDouble(x1));
			} else {
				xaxis.set_maximum(xaxis.getDouble(x0));
				xaxis.set_minimum(xaxis.getDouble(x1));
			}
			if (y0 >y1 ) {                
				yaxis.set_minimum(yaxis.getDouble(y0));
				yaxis.set_maximum(yaxis.getDouble(y1));
			} else {
				yaxis.set_maximum(yaxis.getDouble(y0));
				yaxis.set_minimum(yaxis.getDouble(y1));
			}
			repaint();
		}
		return true;
	}

/**
 * Handle the Mouse Drag events
 */
	public boolean mouseDrag(Event e, int x, int y) {
		if (xaxis==null || yaxis==null) return false;
		x1   = x;
		y1   = y;

		if (drag) {
			if (x1 < datarect.x) x1 = datarect.x;
			else if (x1 > datarect.x + datarect.width) {
				x1 = datarect.x + datarect.width;
			}
			if (y1 < datarect.y) y1 = datarect.y;
			else if (y1 > datarect.y + datarect.height) {
				y1 = datarect.y + datarect.height;
			}
		}
		if (cpgin != null && cpgin.isVisible()) {
			cpgin.setXlabel(  xaxis.getDouble(x1) );
			cpgin.setYlabel(  yaxis.getDouble(y1) );
		}
		repaint();
		return true;
	}

/** 
 * Handle the Mouse Mouve events
 */
public boolean mouseMove(Event e, int x, int y) {
	if (xaxis==null || yaxis==null) return false;
	x1   = e.x;
	y1   = e.y;
	if (cpgin != null && cpgin.isVisible()) {
		cpgin.setXlabel(  xaxis.getDouble(x1) );
		cpgin.setYlabel(  yaxis.getDouble(y1) );
	}
	return true;
}

/**
 * Handle the Action Events.
 * This handler allows external classes (pop-up windows etc.) to
 * communicate to this class asyncronously.
 */ 
	public boolean action(Event e, Object a) {
		if (xaxis==null || yaxis==null) return false;
		if (e.target instanceof Range && range != null) {
			Double d;
			double txmin = xaxis.minimum();
			double txmax = xaxis.maximum();
			double tymin = yaxis.minimum();
			double tymax = yaxis.maximum();

			d = range.minimum_x();
			if (d != null) txmin = d.doubleValue();
			d = range.maximum_x();
			if (d != null) txmax = d.doubleValue();
			d = range.minimum_y();
			if (d != null) tymin = d.doubleValue();
			d = range.maximum_y();
			if (d != null) tymax = d.doubleValue();
			if ( txmax > txmin && tymax > tymin ) {
				xaxis.set_minimum(txmin);
				xaxis.set_maximum(txmax);
				yaxis.set_minimum(tymin);
				yaxis.set_maximum(tymax);
			}
			repaint();
			return true;
		}
		return false;
	}

/**
 *   Find the closest data point to the cursor
 */
	protected double[] closest_point(int ix, int iy) {
		DrawableDataSet ds;
		int   i;
		double a[] = new double[3];
		double distsq = -1.0;
		double data[] = {0.0, 0.0};
		double x = xaxis.getDouble(ix);
		double y = yaxis.getDouble(iy);

//System.out.println("closest_point: x="+x+", y="+y);
		for (i=0; i<dataset.size(); i++) {
			ds = (DrawableDataSet)(dataset.get(i));
			a = ds.closest_point(x,y);
			if ( distsq < 0.0 || distsq > a[2] ) {
				data[0] = a[0];
				data[1] = a[1];
				distsq  = a[2];
			}
		}
		return data;
	}
}

/**
 *      Popup a window to output data after a Graphics Input command
 *      the window contains the following
 *           X  value
 *           Y  value
 */

class Gin extends Frame {

	private Label xlabel = new Label();
	private Label ylabel = new Label();

  /**
   * Instantiate the class
   */
	public Gin() {
		setLayout(new GridLayout(2,1));
		xlabel.setAlignment(Label.LEFT);
		ylabel.setAlignment(Label.LEFT);
		this.setFont(new Font(FontProperties.HELVETICA_PLAIN, Font.PLAIN, 20));
		add("x",xlabel);
		add("y",ylabel);
		resize(150,100);
		super.setTitle("Graphics Input");
	}
  /**
   * Instantiate the class. 
   * @param title the title to use on the pop-window.
   */

	public Gin(String title) {
		this();
		if (title != null) super.setTitle(title);
	}

  /**
   *  Set the X value
   * @param d The value to set it
   */

	public void setXlabel(double d) {
		xlabel.setText( String.valueOf(d) );
	}

  /**
   *  Set the Y value
   * @param d The value to set it
   */

public void setYlabel(double d) {
	ylabel.setText( String.valueOf(d) );
}

  /**
   *  Set the both values
   * @param dx The X value to set
   * @param dy The Y value to set
   */

	public void setLabels(double dx, double dy) {
		xlabel.setText( String.valueOf(dx) );
		ylabel.setText( String.valueOf(dy) );
	}

  /**
   * Set the display font
   */

	public void setFont( Font f ) {
		if (f == null) return;
		xlabel.setFont(f);
		ylabel.setFont(f);
	}

  /**
   * Set the size of the window
   * @param x width in pixels
   * @param y height in pixels
   */
	public void resize( int x, int y) {
		super.resize(x,y);
	}

  /**
   * Catch the Key Down event 'h'. If the key is pressed then
   * hide this window.
   *
   * @param e The event
   * @param key the key pressed
   */

	public boolean keyDown(Event e, int key) {
		if ( key == 'h' ) {
			this.hide();
			return true;
		}
		return false;
	}
}

/**
 *    A  popup window for altering the range of the plot
 */

class Range extends Frame {

	public Range(Graph g) {
		g2d = g;
		setLayout (new GridLayout(5,2,5,10));
		xminLabel.setAlignment(Label.LEFT);
		xmaxLabel.setAlignment(Label.LEFT);
		yminLabel.setAlignment(Label.LEFT);
		ymaxLabel.setAlignment(Label.LEFT);

		add("xminLabel",xminLabel);
		add("xminText",xminText);
		add("xmaxLabel",xmaxLabel);
		add("xmaxText",xmaxText);
		add("yminLabel",yminLabel);
		add("yminText",yminText);
		add("ymaxLabel",ymaxLabel);
		add("ymaxText",ymaxText);

		add("cancel", cancel);
		cancel.setBackground(Color.red);
		add("done",done);
		done.setBackground(Color.green);

		resize(250,250);
		super.setTitle("Set Plot Range");
	}

	public Double minimum_x() {
		try {
			return Double.valueOf(xminText.getText());
		}
		catch (Exception ex) {
			return null;
		}
	}

	public Double maximum_x() {
		try {
			return Double.valueOf(xmaxText.getText());
		}
		catch (Exception ex) {
			return null;
		}
	}

	public Double minimum_y() {
		try {
			return Double.valueOf(yminText.getText());
		}
		catch (Exception ex) {
			return null;
		}
	}

	public Double maximum_y() {
		try {
			return Double.valueOf(ymaxText.getText());
		}
		catch (Exception ex) {
			return null;
		}
	}

	public void resize( int x, int y) {
		super.resize(x,y);
	}

	public void requestFocus() {
		xminText.requestFocus();
	}
/*
** Handle the events
*/
	public boolean keyDown(Event e, int key) {
		if (e.target instanceof TextField) {
			if ( ( key == 10 || e.key == 13 ) ) {
				if (xminText.equals(e.target)) {
					xmaxText.requestFocus();
					return true;
				} else if (xmaxText.equals(e.target)) {
					yminText.requestFocus();
					return true;
				} else if (yminText.equals(e.target)) {
					ymaxText.requestFocus();
					return true;
				} else if (ymaxText.equals(e.target)) {
					xminText.requestFocus();
					return true;
				}
				return true;
			}
		}
		return false;
	}

	public boolean action(Event e, Object a) {
		if (e.target instanceof Button) {
			if ( done.equals(e.target) && g2d != null) {
				g2d.deliverEvent( new Event(this,Event.ACTION_EVENT,this));
				this.hide();
				return true;
			} else if ( cancel.equals(e.target) ) {
				this.hide();
				return true;
			}
		}
		return false;
	}

// Implementation
	Graph g2d = null;
	private Label xminLabel = new Label("Xmin");
	private Label yminLabel = new Label("Ymin");
	private Label xmaxLabel = new Label("Xmax");
	private Label ymaxLabel = new Label("Ymax");
	private TextField xminText = new TextField(20);
	private TextField yminText = new TextField(20);
	private TextField xmaxText = new TextField(20);
	private TextField ymaxText = new TextField(20);
	private Button cancel = new Button("Cancel");
	private Button done   = new Button("Done");

}
