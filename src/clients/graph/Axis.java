package graph;

import java.awt.*;
import java.util.*;


/*
**************************************************************************
**
**    Class  Axis            
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
**    Modified by Jim Cochrane, last changed in October, 2004
**************************************************************************
**
**    This class is designed to be used in conjunction with 
**    the Graph class and DrawableDataSet class for plotting 2D graphs.
**
*************************************************************************/



/**
	* This class controls the look and feel of axes. 
	* It is designed to be used in conjunction with 
	* the Graph class and DrawableDataSet class for plotting 2D graphs.
	*
	* To work with the other classes a system of registration is used.
	* The axes have to be attached to the controlling Graph class
	* and the DrawableDataSet's have to be attached to both the Graph class
	* and the Axis class.
	*
	* This way the 3 main classes Graph, Axis and DrawableDataSet know of each
	* others existence.
	*
	* This does not mean the classes cannot be used independently, they can
	* but in this mode nothing is automated, the user must code everything
	* manually
	*
	* @version  $Revision$, $Date$.
	* @author   Leigh Brookshaw
	*/ 

public class Axis {

// Initialization

	/**
	*  Instantiate the class. The defalt type is a Horizontal axis
	*  positioned at the bottom of the graph.
	*/
	public Axis() {
		orientation = HORIZONTAL;
		position    = BOTTOM;
	}           

	/**
	* Instantiate the class. Setting the position.
	* @param p Set the axis position. Must be one of Axis.BOTTOM,
	* Axis.TOP, Axis.LEFT, Axis.RIGHT, Axis.HORIZONTAL or Axis.VERTICAL.
	* If one of the latter two are used then Axis.BOTTOM or 
	* Axis.LEFT is assumed.
	*/
	public Axis(int p) {

		setPosition(p);

		switch (position) {
			case LEFT:
			case VERTICAL: title.setRotation(90); break;
			case RIGHT: title.setRotation(-90); break;
			default: title.setRotation(0); break;
		}
	}

// Access - Constants

	/**
	*    Constant flagging Axis position on the graph. 
	*    Left side => Vertical
	*/
	public static final int  LEFT       = 2;

	/**
	*    Constant flagging Axis position on the graph. 
	*    Right side => Vertical
	*/
	public static final int  RIGHT      = 3;

	/**
	*    Constant flagging Axis position on the graph. 
	*    Top side => Horizontal
	*/
	public static final int  TOP        = 4;

	/**
	*    Constant flagging Axis position on the graph. 
	*    Bottom side => Horizontal
	*/
	public static final int  BOTTOM     = 5;

// Access

	/**
	* Maximum data value of the axis. This is the value used to scale
	* data into the data window. This is the value to alter to force
	* a rescaling of the data window.
	*/
	public double maximum() { return maximum; }

	/**
	* Minimum data value of the axis. This is the value used to scale
	* data into the data window. This is the value to alter to force
	* a rescaling of the data window.
	*/
	public double minimum() { return minimum; }

	/**
	* The width of the Axis. Where width for a horizontal axis is really 
	* the height
	*/
	public int width() { return width; }

	/**
	* Return the pixel equivalent of the passed data value. Using the 
	* position of the axis and the maximum and minimum values convert
	* the data value into a pixel value
	* @param v data value to convert
	* @return equivalent pixel value
	* @see graph.Axis#dataValue( )
	*/ 
	public int pixelValue(double v) {
		double scale;

		if (orientation == HORIZONTAL) {
			scale  = (double)(amax.x - amin.x)/(maximum - minimum);
			return amin.x + (int)( ( v - minimum ) * scale);
		} else {
			scale  = (double)(amax.y - amin.y)/(maximum - minimum);
			return amin.y + (int)( (maximum-v)*scale );
		}
	}

	/**
	* Return the data value equivalent of the passed pixel position.
	* Using the 
	* position of the axis and the maximum and minimum values convert
	* the pixel position into a data value
	* @param i pixel value
	* @return equivalent data value
	* @see graph.Axis#pixelValue( )
	*/ 
	public double dataValue(int i) {
		double scale;

		if (orientation == HORIZONTAL) {
			scale  = (maximum - minimum)/(double)(amax.x - amin.x);
			return minimum + (i - amin.x)*scale;
		} else {
			scale  = (maximum - minimum)/(double)(amax.y - amin.y);
			return maximum - (i - amin.y)*scale;
		}
	}

// Element change

	/**
	* Set the axis position.
	* @param p Must be one of Axis.BOTTOM,
	* Axis.TOP, Axis.LEFT, Axis.RIGHT, Axis.HORIZONTAL or Axis.VERTICAL.
	* If one of the latter two are used then Axis.BOTTOM or 
	* Axis.LEFT is assumed.
	*/
	public void setPosition(int p) {
		position = p;

		switch (position) {
			case LEFT:
				orientation = VERTICAL;
				break;
			case RIGHT:
				orientation = VERTICAL;
				break;
			case TOP:
				orientation = HORIZONTAL;
				break;
			case BOTTOM:
				orientation = HORIZONTAL;
				break;
			case HORIZONTAL:
				orientation = HORIZONTAL;
				position = BOTTOM;
				break;
			case VERTICAL:
				orientation = VERTICAL;
				position = LEFT;
				break;
			default:
				orientation = HORIZONTAL;
				position = BOTTOM;
				break;
		}
	}

	/**
	* Attach a DrawableDataSet for the Axis to manage.
	* @param d dataSet to attach
	* @see graph.DrawableDataSet
	*/
	public void attachDataSet( DrawableDataSet d ) {
System.out.println("attachDataSet - d.size: " + d.size());
		if (orientation == HORIZONTAL) {
System.out.println("attachDataSet attaching X data");
			attachX_Data( d );
		} else {
System.out.println("attachDataSet attaching Y data");
			attachY_Data( d );
		}
	}

//!!!!Remove?:
	/**
	* Reset the associated data sets with respect to this axis.
	*/
	public void resetDataSets() {
		DrawableDataSet d;
		Iterator i = dataset.iterator();
int count = 0;
		while (i.hasNext()) {
System.out.println("restting with data set " + ++count);
			d = (DrawableDataSet) i.next();
			resetX_Data(d);
			resetY_Data(d);
		}
	}

	/**
	* Set the title of the axis
	* @param s string containing text.
	*/
	public void setTitleText(String s) {   title.setText(s); }

	/**
	* Set the color of the title
	* @param c Color of the title.
	*/
	public void setTitleColor(Color c) {   title.setColor(c); }

	/**
	* Set the font of the title
	* @param c Title font.
	*/
	public void setTitleFont(Font f)   {   title.setFont(f); }

	/**
	* Set the title rotation angle. Only multiples of 90 degrees allowed.
	* @param a Title rotation angle in degrees.
	*/
	public void setTitleRotation(int a)   {   title.setRotation(a); }

	/**
	* Set the color of the labels
	* @param c Color of the labels.
	*/
	public void setLabelColor(Color c) {   label.setColor(c); }

	/**
	* Set the font of the labels.
	* @param f font.
	*/
	public void setLabelFont(Font f)   {   label.setFont(f); }

	/**
	* Set the color of the exponent
	* @param c Color.
	*/
	public void setExponentColor(Color c) {   exponent.setColor(c); }

	/**
	* Set the font of the exponent
	* @param f font.
	*/
	public void setExponentFont(Font f)   {   exponent.setFont(f); }

	/**
	* Is the range of the axis to be set automatically (based on the data)
	* or manually by setting the values Axis.minimum and Axis.maximum?
	* @param b boolean value.
	*/
	public void setManualRange(boolean b)   {  manualRange = b; }

// Removal

	/**
	* Detach an attached DrawableDataSet
	* @param d dataSet to detach
	* @see graph.DrawableDataSet
	*/
	public void detachDataSet( DrawableDataSet d ) {
		int i = 0;

		if (d == null) {
			return;
		}

		if (orientation == HORIZONTAL) {
			d.set_xaxis(null);
		} else {
			d.set_yaxis(null);
		}
		dataset.remove(d);

		if (!manualRange) {
			resetRange();
		}
	}

	/**
	* Detach All attached dataSets.
	*/
	public void detachAll() {
		int i;
		DrawableDataSet d;

		if (dataset.isEmpty()) {
			return;
		}

		if (orientation == HORIZONTAL) {
			for (i=0; i<dataset.size(); i++) {
				d = (DrawableDataSet)(dataset.get(i));
				d.set_xaxis(null);
			}
		} else {
			for (i=0; i<dataset.size(); i++) {
				d = (DrawableDataSet)(dataset.get(i));
				d.set_yaxis(null);
			}
		}

		dataset.clear();

		minimum = 0.0;
		maximum = 0.0;
	}

	/**
	* Reset the range of the axis (the minimum and maximum values) to the
	* default data values.
	*/
	public void resetRange() {
		minimum = dataMinimumCalculation();
		maximum = dataMaximumCalculation();
	}

	/**
	* Return the position of the Axis.
	* @return One of Axis.LEFT, Axis.RIGHT, Axis.TOP, or Axis.BOTTOM.
	*/ 
	public int position() { return position; }

	/**
	* If the Axis is Vertical return <i>true</i>.
	*/
	public boolean isVertical() {
		return orientation != HORIZONTAL;
	}   

// Basic operations

	/**
	* Position the axis at the passed coordinates. The coordinates should match
	* the type of axis.
	* @param xmin The minimum X pixel
	* @param xmax The maximum X pixel. These should be equal if the axis 
	*         is vertical
	* @param ymin The minimum Y pixel
	* @param ymax The maximum Y pixel. These should be equal if the axis 
	*         is horizontal
	* @return <i>true</i> if there are no inconsistencies.
	*/
	public boolean positionAxis(int xmin, int xmax, int ymin, int ymax ){
		amin = null;
		amax = null;

		if (orientation == HORIZONTAL && ymin != ymax) {
			return false;
		}
		if (orientation == VERTICAL   && xmin != xmax) {
			return false;
		}

		amin = new Point(xmin,ymin);
		amax = new Point(xmax,ymax);

		return true;
	}         

	/**
	* Draw the axis using the passed Graphics context.
	* @param g Graphics context for drawing
	*/
	public void draw(Graphics g) {
		Graphics lg;

		if (!redraw) {
			return;
		}
		if (minimum == maximum) {
			System.err.println(
				"Axis: data minimum==maximum Trying to reset range!");
			resetRange();
			if (minimum == maximum) {
				System.err.println(
					"Axis: Reseting Range failed!  Axis not drawn!");
				return;
			}
		}
		if (amin.equals(amax)) {
			return;
		}
		if (width == 0) {
			width = widthCalculation(g);
		}

		lg = g.create();

		if (force_end_labels) {
			minimum = label_start;
			maximum = minimum + (label_count-1)*label_step;
		}

		/*
		** For rotated text set the Component that is being drawn into
		*/
		title.setDrawingComponent(g2d);
		label.setDrawingComponent(g2d);
		exponent.setDrawingComponent(g2d);

		if (orientation == HORIZONTAL) {
			drawH_Axis(lg);
		} else {
			drawV_Axis(lg);
		}
	}

// Access - restricted

	/**
	* Return the width of the axis.
	* @param g graphics context.
	*/
	protected int widthCalculation(Graphics g) {
		int i;
		width = 0;

		if (minimum == maximum) {
			return 0;
		}
		if (dataset.size() == 0) {
			return 0;
		}

		calculateGridLabels();
		exponent.setText(null);

		if (label_exponent != 0) {
			exponent.copyState(label);
			exponent.setText("x10^"+String.valueOf(label_exponent));
		}

		if ( orientation == HORIZONTAL ) {
			width = label.getRHeight(g) + label.getLeading(g); 
			width += Math.max(title.getRHeight(g),exponent.getRHeight(g));
		} else {
			for(i=0; i<label_string.length; i++) {
				label.setText(" "+label_string[i]);
				width = Math.max(label.getRWidth(g),width);
			}
			max_label_width = width;
			width = 0;

			if (!title.isNull() ) {
				width = Math.max(width,title.getRWidth(g)+
				title.charWidth(g,' '));
			}

			if ( !exponent.isNull() ) {
				width = Math.max(width,exponent.getRWidth(g)+
				exponent.charWidth(g,' '));
			}
			width += max_label_width;
		}

		return width;
	}

// Implementation - Element change

	/**
	* Set maximum to `v'.
	*/
	protected void set_maximum(double v) { maximum = v; }

	/**
	* Set minimum to `v'.
	*/
	protected void set_minimum(double v) { minimum = v; }

	// Set data_window to `dw'.
	protected void set_data_window(Dimension dw) { data_window = dw; }

	// Set g2d to `g'.
	protected void set_g2d(Graph g) { g2d = g; }

	// Set gridcolor to `g'.
	protected void set_gridcolor(Color c) { gridcolor = c; }

	protected void set_drawgrid(boolean b) { drawgrid = b; }

	protected void set_drawzero(boolean b) { drawzero = b; }

	protected void set_zerocolor(Color c) { zerocolor = c; }

// Implementation

	/**
	* Return the minimum value of All datasets attached to the axis.
	* @return Data minimum
	*/
	private double dataMinimumCalculation() {
		double m;
		Iterator items;
		DrawableDataSet d;

		if (dataset.isEmpty()) {
			return 0.0;
		}

		d = (DrawableDataSet)(dataset.get(0));
		if (d == null) {
			return 0.0;
		}

		if (orientation == HORIZONTAL) {
			m = d.minimum_x();
			for (items = dataset.iterator() ; items.hasNext() ;) {
				d = (DrawableDataSet)items.next();
				m = Math.min(d.minimum_x(),m);
			}
		} else {
			m = d.minimum_y();
			for (items = dataset.iterator() ; items.hasNext() ;) {
				d = (DrawableDataSet)items.next();
				m = Math.min(d.minimum_y(),m);
			}
		}

		return m;
	}

	/**
	* Return the maximum value of All datasets attached to the axis.
	* @return Data maximum
	*/
	private double dataMaximumCalculation() {
		double m;
		Iterator items;
		DrawableDataSet d;

		if (dataset.isEmpty()) {
			return 0.0;
		}

		d = (DrawableDataSet)(dataset.get(0));

		if (d == null) {
			return 0.0;
		}


		if (orientation == HORIZONTAL) {
			m = d.maximum_x();
			for (items = dataset.iterator() ; items.hasNext() ;) {
				d = (DrawableDataSet)items.next();
				m = Math.max(d.maximum_x(),m);
		}
		} else {
			m = d.maximum_y();
			for (items = dataset.iterator() ; items.hasNext() ;) {
				d = (DrawableDataSet)items.next();
				m = Math.max(d.maximum_y(),m);
			}
		}

		return m;
	}

	/**
	* Draw a Horizontal Axis.
	* @param g Graphics context.
	*/
	private void drawH_Axis(Graphics g) {
		Graphics lg;
		int i;
		int j;
		int x0,y0,x1,y1;
		int direction;
		int offset;
		double minor_step;
		Color c;
		double vmin = minimum*1.001;
		double vmax = maximum*1.001;
		double scale  = (amax.x - amin.x)/(maximum - minimum);
		double val;
		double minor;

		//          System.out.println("Drawing Horizontal Axis!");
		if (axiscolor != null) {
			g.setColor(axiscolor);
		}
		g.drawLine(amin.x,amin.y,amax.x,amax.y);

		if (position == TOP) {
			direction =  1;
		}
		else direction = -1;

		minor_step = label_step/(minor_tic_count+1);
		val = label_start;
		for(i=0; i<label_count; i++) {
			if (val >= vmin && val <= vmax) {
				y0 = amin.y;
				x0 = amin.x + (int)( ( val - minimum ) * scale);
				if (Math.abs(label_value[i]) <= 0.0001 && drawzero) {
					c = g.getColor();
					if (zerocolor != null) {
						g.setColor(zerocolor);
					}
					g.drawLine(x0,y0,x0,y0+data_window.height*direction);
					g.setColor(c);
				} else 
				if (drawgrid) {
					c = g.getColor();
					if (gridcolor != null) {
						g.setColor(gridcolor);
					}
					g.drawLine(x0,y0,x0,y0+data_window.height*direction);
					g.setColor(c);
				}
				x1 = x0;
				y1 = y0 + major_tic_size*direction;
				g.drawLine(x0,y0,x1,y1);
			}

			minor = val + minor_step;
			for(j=0; j<minor_tic_count; j++) {
				if (minor >= vmin && minor <= vmax) {
					y0 = amin.y;
					x0 = amin.x + (int)( ( minor - minimum ) * scale);
					if (drawgrid) {
						c = g.getColor();
						if (gridcolor != null) {
							g.setColor(gridcolor);
						}
						g.drawLine(x0,y0,x0,y0+data_window.height*direction);
						g.setColor(c);
					}
					x1 = x0;
					y1 = y0 + minor_tic_size*direction;
					g.drawLine(x0,y0,x1,y1);
				}
				minor += minor_step;
			}
			val += label_step;
		}

		if (position == TOP) {
			offset = - label.getLeading(g) - label.getDescent(g);
		} else {
			offset = + label.getLeading(g) + label.getAscent(g);
		}

		val = label_start;
		for(i=0; i<label_count; i++) {
			if (val >= vmin && val <= vmax) {
				y0 = amin.y + offset;
				x0 = amin.x + (int)(( val - minimum ) * scale);
				label.setText(label_string[i]);
				label.draw(g,x0,y0,TextLine.CENTER);
			}
			val += label_step;
		}

		if (!exponent.isNull()) {
			if (position == TOP) {
				y0 = amin.y - label.getLeading(g) - label.getDescent(g) -
					exponent.getLeading(g) - exponent.getDescent(g);
			} else {
				y0 = amax.y + label.getLeading(g) + label.getAscent(g) +
					exponent.getLeading(g) + exponent.getAscent(g);
			}
			x0 = amax.x;
			exponent.draw(g,x0,y0,TextLine.LEFT);
		}

		if (!title.isNull()) {
			if (position == TOP ) {
				y0 = amin.y - label.getLeading(g) - label.getDescent(g) -
					title.getLeading(g) - title.getDescent(g);
			} else {
				y0 = amax.y + label.getLeading(g) + label.getAscent(g) +
					title.getLeading(g) + title.getAscent(g);
			}
			x0 = amin.x + ( amax.x - amin.x)/2;
			title.draw(g,x0,y0,TextLine.CENTER);
		}
	}

	/**
	* Draw a Vertical Axis.
	* @param g Graphics context.
	*/
	private void drawV_Axis(Graphics g) {
		Graphics lg;
		int i;
		int j;
		int x0,y0,x1,y1;
		int direction;
		int offset = 0;
		double minor_step;
		double minor;
		Color c;
		FontMetrics fm;
		Color gc = g.getColor();
		Font  gf = g.getFont();
		double vmin = minimum*1.001;
		double vmax = maximum*1.001;
		double scale  = (amax.y - amin.y)/(maximum - minimum);
		double val;

		//          System.out.println("Drawing Vertical Axis!");

		if (axiscolor != null) {
			g.setColor(axiscolor);
		}
		g.drawLine(amin.x,amin.y,amax.x,amax.y);
		if (position == RIGHT) {
			direction = -1;
		}
		else direction =  1;

		minor_step = label_step/(minor_tic_count+1);
		val = label_start;
		for(i=0; i<label_count; i++) {
			if (val >= vmin && val <= vmax) {
				x0 = amin.x;
				y0 = amax.y - (int)( ( val - minimum ) * scale);
				if (Math.abs(label_value[i]) <= 0.0001 && drawzero) {
					c = g.getColor();
					if (zerocolor != null) {
						g.setColor(zerocolor);
					}
					g.drawLine(x0,y0,x0+data_window.width*direction,y0);
					g.setColor(c);
				} else if (drawgrid) {
					c = g.getColor();
					if (gridcolor != null) {
						g.setColor(gridcolor);
					}
					g.drawLine(x0,y0,x0+data_window.width*direction,y0);
					g.setColor(c);
				}
				x1 = x0 + major_tic_size*direction;
				y1 = y0;
				g.drawLine(x0,y0,x1,y1);
			}

			minor = val + minor_step;
			for(j=0; j<minor_tic_count; j++) {
				if (minor >= vmin && minor <= vmax) {
					x0 = amin.x;
					y0 = amax.y - (int)( ( minor - minimum ) * scale);
					if (drawgrid) {
						c = g.getColor();
						if (gridcolor != null) {
							g.setColor(gridcolor);
						}
						g.drawLine(x0,y0,x0+ data_window.width*direction,y0);
						g.setColor(c);
					}
					x1 = x0 + minor_tic_size*direction;
					y1 = y0;
					g.drawLine(x0,y0,x1,y1);
				}
				minor += minor_step;
			}
			val += label_step;
		}

		val = label_start;
		for(i=0; i<label_count; i++) {
			if (val >= vmin && val <= vmax) {
				x0 = amin.x + offset;
				y0 = amax.y - (int)(( val - minimum ) * scale) + 
				label.getAscent(g)/2;
				if (position == RIGHT) {
					label.setText(" "+label_string[i]);
					label.draw(g,x0,y0,TextLine.LEFT);
				} else {
					label.setText(label_string[i]+" ");
					label.draw(g,x0,y0,TextLine.RIGHT);
				}
			}
			val += label_step;
		}

		if (!exponent.isNull()) {
			y0 = amin.y;
			if (position == RIGHT) {
				x0 = amin.x + max_label_width + exponent.charWidth(g,' ');
				exponent.draw(g,x0,y0,TextLine.LEFT);
			} else {
				x0 = amin.x - max_label_width - exponent.charWidth(g,' ');
				exponent.draw(g,x0,y0,TextLine.RIGHT);
			}
		}

		if (!title.isNull()) {
			y0 = amin.y + (amax.y-amin.y)/2;
			if (title.getRotation() == 0 || title.getRotation() == 180) {
				if (position == RIGHT) {
					x0 = amin.x + max_label_width + title.charWidth(g,' ');
					title.draw(g,x0,y0,TextLine.LEFT);
				} else {
					x0 = amin.x - max_label_width - title.charWidth(g,' ');
					title.draw(g,x0,y0,TextLine.RIGHT);
				}
			} else {
			title.setJustification(TextLine.CENTER);
				if (position == RIGHT) {
					x0 = amin.x + max_label_width - title.getLeftEdge(g) +
						title.charWidth(g,' ');
				} else {
					x0 =  amin.x - max_label_width - title.getRightEdge(g) -
						title.charWidth(g,' ');
				}
				title.draw(g,x0,y0);
			} 
		}
	}

	/**
	* Attach a DrawableDataSet to this horizontal axis
	* @param d dataset to attach.
	*/
	private void attachX_Data (DrawableDataSet d) {
		d.range();
		dataset.add(d);
		d.set_xaxis(this);

		if (dataset.size() == 1) {
			minimum = d.minimum_x();
			maximum = d.maximum_x();
		} else {
			if (minimum > d.minimum_x()) {
				minimum = d.minimum_x();
			}
			if (maximum < d.maximum_x()) {
				maximum = d.maximum_x();
			}
		}
	}

	/**
	* Attach a DrawableDataSet to this vertical axis
	* @param d dataset to attach.
	*/
	private void attachY_Data (DrawableDataSet d) {
		d.range();
		dataset.add(d);
		d.set_yaxis(this);

		if (dataset.size() == 1) {
			minimum = d.minimum_y();
			maximum = d.maximum_y();
		} else {
			if (minimum > d.minimum_y()) {
				minimum = d.minimum_y();
			}
			if (maximum < d.maximum_y()) {
				maximum = d.maximum_y();
			}
		}
	}

//!!!!Remove?:
	/**
	* Reset the relationship between DrawableDataSet `d' and this
	* horizontal axis.
	* @param d dataset to attach.
	*/
	private void resetX_Data (DrawableDataSet d) {
		d.range();
//!!!dataset.add(d);
//!!!d.set_xaxis(this);

//!!!!!:? resetRange();
		if (dataset.size() == 1) {
			minimum = d.minimum_x();
			maximum = d.maximum_x();
		} else {
			if (minimum > d.minimum_x()) {
				minimum = d.minimum_x();
			}
			if (maximum < d.maximum_x()) {
				maximum = d.maximum_x();
			}
		}
	}

//!!!!Remove?:
	/**
	* Reset the relationship between DrawableDataSet `d' and this
	* vertical axis.
	* @param d dataset to attach.
	*/
	private void resetY_Data (DrawableDataSet d) {
		d.range();
//!!!dataset.add(d);
//!!!d.set_yaxis(this);

		if (dataset.size() == 1) {
			minimum = d.minimum_y();
			maximum = d.maximum_y();
		} else {
			if (minimum > d.minimum_y()) {
				minimum = d.minimum_y();
			}
			if (maximum < d.maximum_y()) {
				maximum = d.maximum_y();
			}
		}
	}

	/**
	* calculate the labels
	*/
	private void calculateGridLabels() {
		double val;
		int i;
		int j;

		if (Math.abs(minimum) > Math.abs(maximum)) {
			label_exponent = ((int)Math.floor(
				SpecialFunction.log10(Math.abs(minimum))/3.0) )*3;
		}
		else {
			label_exponent = ((int)Math.floor(
				SpecialFunction.log10(Math.abs(maximum))/3.0) )*3;
		}

		label_step = RoundUp( (maximum-minimum)/guess_label_number );
		label_start = Math.floor( minimum/label_step )*label_step;
		val = label_start;
		label_count = 1;

		while(val < maximum) {
			val += label_step; label_count++;
		}

		label_string = new String[label_count];
		label_value  = new float[label_count];

		for(i=0; i<label_count; i++) {
			val = label_start + i*label_step;

			if (label_exponent < 0) {
				for (j=label_exponent; j<0;j++) {
					val *= 10;
				}
			} else {
				for (j=0; j<label_exponent;j++) {
					val /= 10;
				}
			}

			label_string[i] = String.valueOf(val);
			label_value[i] = (float)val;
		}
	}

// Implementation - Utilities

	/**
	* Round up the passed value to a NICE value.
	*/

	private double RoundUp( double val ) {
		int exponent;
		int i;

		exponent = (int)(Math.floor( SpecialFunction.log10(val) ));

		if (exponent < 0) {
			for(i=exponent; i<0; i++) {
				val *= 10.0;
			}
		} else {
			for(i=0; i<exponent; i++) {
				val /= 10.0;
			}
		}

		if (val > 5.0) {
			val = 10.0;
		} else if ( val > 2.0) {
			val = 5.0;
		} else if ( val > 1.0) {
			val = 2.0;
		}
		else val = 1.0;

		if (exponent < 0) {
			for(i=exponent; i<0; i++) {
				val /= 10.0;
			}
		} else {
			for(i=0; i<exponent; i++) {
				val *= 10.0;
			}
		}
		return val;
	}                  

// Implementation - Constants

	/**
	*    Constant flagging Horizontal Axis
	*/
	private static final int  HORIZONTAL = 0;

	/**
	*    Constant flagging Vertical Axis
	*/
	private static final int  VERTICAL   = 1;

	/**
	*    The first guess on the number of Labeled Major tick marks.
	*/
	private static final int  NUMBER_OF_TICS = 4;

// Implementation - attributes

	/**
	*    If <i>true</i> draw a grid positioned on major ticks over the graph
	*/
	private boolean  drawgrid        = false;

	/**
	*    If <i>true</i> draw a line positioned on the Zero label tick mark.
	*/
	private boolean  drawzero        = false;

	/**
	* Color of the grid
	*/
	private Color   gridcolor        = null;

	/**
	* Color of the line at the Zero label
	*/
	private Color   zerocolor        = null;

	/**
	* Default value <i>true</i>. Normally never changed. If set <i>false</I>
	* the Axis draw method exits without drawing the axis.
	* @see Axis#draw()
	*/
	private boolean redraw           = true;

	/**
	* Rescale the axis so that labels fall at the end of the Axis. Default
	* value <i>false</i>.
	*/
	private boolean force_end_labels = false;

	/**
	* Size in pixels of the major tick marks
	*/
	private int     major_tic_size = 10;

	/**
	* Size in pixels of the minor tick marks
	*/
	private int     minor_tic_size  = 5;

	/**
	* Number of minor tick marks between major tick marks
	*/
	private int     minor_tic_count = 1;

	/**
	* Color of the Axis.
	*/
	private Color   axiscolor;

	/**
	* Minimum data value of the axis. This is the value used to scale
	* data into the data window. This is the value to alter to force
	* a rescaling of the data window.
	*/
	private double minimum;

	/**
	* Maximum data value of the axis. This is the value used to scale
	* data into the data window. This is the value to alter to force
	* a rescaling of the data window.
	*/
	private double maximum;

	/**
	* Before the Axis can be positioned correctly and drawn the data window
	* needs to be calculated and passed to the Axis.
	*/
	private Dimension data_window = new Dimension(0,0);

	/**
	* The graph canvas this axis is attached to (if it is attached to any)
	* @see graph.Graph
	*/
	private Graph g2d = null;

	/**
	* The position in pixels of the minimum point of the axis line
	*/
	private Point amin;

	/**
	* The position in pixels of the maximum point of the axis line
	*/
	private Point amax;

	/**
	* The orientation of the axis. Either Axis.HORIZONTAL or
	* Axis.VERTICAL
	*/
	private int orientation;

	/**
	* The position of the axis. Either Axis.LEFT, Axis.RIGHT, Axis.TOP, or
	* Axis.BOTTOM
	*/
	private int position;

	/**
	* The width of the Axis. Where width for a horizontal axis is really 
	* the height
	*/
	private int width = 0;

	/**
	* Textline class to contain the title of the axis.
	*/
	private RTextLine title    = new RTextLine();

	/**
	* Textline class to hold the labels before printing.
	*/
	private RTextLine label    = new RTextLine("0");

	/**
	* Textline class to hold the label's exponent (if it has one).
	*/
	private RTextLine exponent = new RTextLine();

	/**
	* The width of the maximum label. Used to position a Vertical Axis.
	*/
	private int max_label_width     = 0;

	/**
	* Array containing a list of attached DrawableDataSets
	*/
	private ArrayList dataset = new ArrayList();

	/**
	* String to contain the labels.
	*/  
	private String label_string[]     = null;

	/**
	* The actual values of the axis labels
	*/
	private float  label_value[]      = null;

	/**
	* The starting value of the labels
	*/
	private double label_start        = 0.0;

	/**
	* The increment between labels
	*/
	private double label_step         = 0.0;

	/**
	* The label exponent
	*/
	private int    label_exponent     = 0;

	/**
	* The number of labels required
	*/
	private int    label_count        = 0;

	/**
	* Initial guess for the number of labels required
	*/
	private int    guess_label_number = 4;

	/**
	* If true the axis range must be manually set by setting the
	* Axis.minimum and Axis.maximum variables. The default is false.
	* The default action is for the axis range to be calculated everytime
	* a dataset is attached.
	*/
	private boolean manualRange = false;
}
