package graph;

import java.awt.*;
import java.util.*;
import java_library.support.*;
import graph_library.DataSet;


/*
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
**    Adapted from the original DataSet class by Jim Cochrane,
**    last changed in 2004.
*************************************************************************/


/**
 * Plottable data sets that can, with the help of a BasicDrawer,
 * draw themselves
 * To be used in conjunction with the Graph class and Axis 
 * class for plotting 2D graphs.
 */
public class DrawableDataSet extends BasicDataSet
	implements AssertionConstants {

// Initialization

	/**
	*  Instantiate an empty data set.
	* @precondition
	*     d != null<br>
	* @postcondition<br>
	*     dates_needed() && drawer() == d<br>
	*     data != null && dates != null && times != null
	*     size() == 0 */
	public DrawableDataSet(BasicDrawer d) {
		assert d != null: PRECONDITION;
		drawer = d;
		data = new ArrayList();
		dates = new ArrayList();
		times = new ArrayList();
		drawer.set_dates(dates);
		drawer.set_times(times);
		date_drawer = new DateDrawer(d);
		time_drawer = new TimeDrawer(d);
		dates_needed = true;
		tuple_count = 0;
	}

	/**
	* Instantiate a DataSet with the parsed data.
	* `d' contains a set of tuples flattened out into array elements -
	* for example, for a 4-field tuple, d[0..3] are the fields of the
	# first tuple, d[4..7] are the fields of the second tuple, etc.
	* The integer n is the number of data Points. This means that the
	* length of the data array is t*n, where t is the number of fields
	* in a tuple.
	* Note: `d' is expected to take y-position (vertical) data only;
	* x-positions will be calculated based on the position of each
	* tuple in `d' - from 1 to d.length.
	* @param d Array containing the (y1,y2,...) data tuples.
	* @param n Number of tuples in the array.
	* @param drwr object used to draw the data.<br>
	* precondition:<br>
	*     d != null && n > 0 && drwr != null<br>
	* postcondition:<br>
	*     dates_needed() && drawer() == drwr<br>
	*     data != null && dates != null && times != null
	*     size() == data_points() */
	public DrawableDataSet(double d[], int n, BasicDrawer drwr) throws Error {
		super(d, n);
		assert d != null && n > 0 && drwr != null: PRECONDITION;
		if (drwr == null) {
			throw new Error("DrawableDataSet constructor: " +
				"precondition violated - drwr is null");
		}
		drawer = drwr;
		drawer.set_dates(dates);
		drawer.set_times(times);
		date_drawer = new DateDrawer(drawer);
		time_drawer = new TimeDrawer(drawer);
		dates_needed = true;
		if (! (dates_needed() && drawer() == drwr) ||
				size() != data_points()) {
			throw new Error("DataSet constructor: postcondition violated");
		}
	}

// Access

	// The object used by 'this' to draw itself
	public BasicDrawer drawer() { return drawer; }

	// Do dates need to be drawn?
	public boolean dates_needed() { return dates_needed; }

	// x axis
	public Axis xaxis() { return xaxis; }

	// y axis
	public Axis yaxis() { return yaxis; }

	/**
	* The number of data points in the DataSet
	* @return number of (x,y) points.
	*/
	public int data_points() {  return length()/stride(); }

	/**
	* The data point at the parsed index. The first (x,y) pair
	* is at index 0.
	* @param index Data point index
	* @return array containing the (x,y) pair.
	*/
	public double[] point(int index) {
		int strd = stride();
		double point[] = new double[strd];
		int i = index*strd;
		if (index < 0 || i > length()-strd) {
			return null;
		}

		for (int j=0; j<strd; j++) {
			point[j] = ((Double) data.get(i+j)).doubleValue();
		}

		return point;
	}

	/**
	* Return the data point that is closest to the parsed (x,y) position
	* @param x 
	* @param y (x,y) position in data space. 
	* @return array containing the closest data point.
	*/
	public double[] closest_point(double x, double y) {
		double point[] = {0.0, 0.0, 0.0};
		int i;
		double xdiff, ydiff, dist2;
		int strd = stride();

		xdiff = ((Double) data.get(0)).doubleValue() - x;
		ydiff = ((Double) data.get(1)).doubleValue() - y;
		point[0] = ((Double) data.get(0)).doubleValue();
		point[1] = ((Double) data.get(1)).doubleValue();
		point[2] = xdiff*xdiff + ydiff*ydiff;

		for(i=strd; i<length()-1; i+=strd) {
			xdiff = ((Double) data.get(i)).doubleValue() - x;
			ydiff = ((Double) data.get(i+1)).doubleValue() - y;
			dist2 = xdiff*xdiff + ydiff*ydiff;
			if(dist2 < point[2]) {
				point[0] = ((Double) data.get(i)).doubleValue();
				point[1] = ((Double) data.get(i+1)).doubleValue();
				point[2] = dist2;
			}
		}

		return point;
	}

// Element change

	public void append(DataSet d) {
		int oldsize = size();
		if (d != null) {
			tuple_count = oldsize + d.size();
			BasicDataSet drwd = (BasicDataSet) d;
			data.addAll(drwd.data);
			dates.addAll(drwd.dates);
			times.addAll(drwd.times);

			// Reset fields dependent on the data set contents.
			range();
			if (xaxis != null) {
				xaxis.resetRange();
			}
			if (yaxis != null) {
				yaxis.resetRange();
			}
		}
		if (d != null && ! (size() == oldsize + d.size())) {
			throw new Error("append: postcondition 2 violated");
		} else if (d == null && (size() != oldsize)) {
			throw new Error("append: postcondition 1 violated");
		}
	}

	public void set_drawer(BasicDrawer d) {
		drawer = d;
	}

	public void set_dates(ArrayList d) {
		dates = d;
		drawer.set_dates(d);
	}

	public void set_times(ArrayList t) {
		times = t;
		drawer.set_times(t);
	}

	public void set_dates(String[] d) {
		dates = new ArrayList(d.length);
		for (int i = 0; i < d.length; ++i) {
			dates.add(d[i]);
		}
		drawer.set_dates(dates);
	}

	public void set_times(String[] t) {
		times = new ArrayList(t.length);
		for (int i = 0; i < t.length; ++i) {
			times.add(t[i]);
		}
		drawer.set_times(times);
	}

	public void set_dates_needed(boolean b) { dates_needed = b; }

	// Set the x axis to `a'.
	public void set_xaxis(Axis a) { xaxis = a; }

	// Set the y axis to `a'.
	public void set_yaxis(Axis a) { yaxis = a; }

	// Add y1, y2 values for a horizontal line.
	public void add_hline(DoublePair p) {
		if (hline_data == null) hline_data = new ArrayList();
		hline_data.add(p);
	}

	// Add x1, x2 values for a vertical line.
	public void add_vline(DoublePair p) {
		if (vline_data == null) vline_data = new ArrayList();
		vline_data.add(p);
	}

	public void set_reference_values_needed(boolean b) {
		drawer.set_reference_values_needed (b);
	}

// Basic operations

	/**
	* Draw the data.
	* If this data has been attached to an Axis then scale the data
	* based on the axis maximum/minimum otherwise scale using
	* the data's maximum/minimum
	* @param g Graphics state
	* @param bounds The data window to draw into
	*/
	public void draw_data(Graphics g, Rectangle bounds) {
		boolean restore_bounds = false;
		if (! range_set) range();
		if ( linecolor != null) g.setColor(linecolor);
		drawer.set_data(data);
		drawer.set_xaxis(xaxis);
		drawer.set_yaxis(yaxis);
		drawer.set_maxes(xmax, ymax, xmin, ymin);
		drawer.set_ranges(xrange, yrange);
		drawer.set_clipping(clipping);
		drawer.draw_data(g, bounds, hline_data, vline_data, color);
	}

// Class invariant

	public boolean invariant() {
		return drawer() != null;
	}

// Implementation

	// set g2d to `b'.
	protected void set_g2d(Graph g) { g2d = g; }

	// The `time_drawer', if there are times; otherwise the `date_drawer',
	// if there are dates; otherwise null
	protected TemporalDrawer temporal_drawer() {
		TemporalDrawer result = null;

		if (times != null) result = time_drawer;
		else if (dates != null) result = date_drawer;

		return result;
	}

	/**
	* Draw times, if they exist; otherwise date dates, if they exist.
	* Precondition: temporal_drawer() != null implies
	*    temporal_drawer().main_data_processed()
	* @param g Graphics context
	* @param w Data Window
	*/
	protected void draw_dates(Graphics g, Rectangle w) {
		TemporalDrawer temporal_drawer = temporal_drawer();
		if (temporal_drawer != null && temporal_drawer.main_data_processed()) {

			temporal_drawer.set_xaxis(xaxis);
			temporal_drawer.set_yaxis(yaxis);
			temporal_drawer.set_maxes(xmax, ymax, xmin, ymin);
			temporal_drawer.set_ranges(xrange, yrange);
			temporal_drawer.set_clipping(clipping);
			temporal_drawer.draw_data(g, w);
		}
	}

	/**
	* Calculate the range of the data. This modifies dxmin,dxmax,dymin,dymax
	* and xmin,xmax,ymin,ymax
	* Precondition: tuple_count has been set
	*/
	protected void range() {
		int i;
		int lnth = length();
		int stride = stride();

		if (lnth >= stride ) {
			dymax = ((Double) data.get(0)).doubleValue();
			dymin = dymax;
			// The range for x follows the data index - starts at 1
			// and ends at data.length.
			dxmax = tuple_count;
			dxmin = 1;
		} else {
			dxmin = 0.0;
			dxmax = 0.0;
			dymin = 0.0;
			dymax = 0.0;
		}

		// `data' holds only y values - find the largest and smallest.
		for (i = 0; i < lnth; ++i) {
			if (dymax < ((Double) data.get(i)).doubleValue()) {
				dymax = ((Double) data.get(i)).doubleValue();
			}
			else if ( dymin > ((Double) data.get(i)).doubleValue() ) {
				dymin = ((Double) data.get(i)).doubleValue();
			}
		}
		if ( yaxis == null) {
			ymin = dymin;
			ymax = dymax;
		}
		if ( xaxis == null) {
			xmin = dxmin;
			xmax = dxmax;
		}
		range_set = true;
	}

	/**
	* Number of components in a data tuple - for example, 2 (x, y) for
	* a simple point
	* @precondition
	*    drawer != null
	*/
	protected int stride() {
		if (drawer == null) {
			throw new Error("assertion violated in 'stride()': drawer != null");
		}
		return drawer.drawing_stride();
	}

// Implementation - attributes

	/** 
	*    The Graphics canvas that is driving the whole show.
	* @see graph.Graph
	*/
	private Graph g2d;

	/**
	*    The color of the straight line segments
	*/
	private Color linecolor     = null;

	/**
	*    The Axis object the X data is attached to. From the Axis object
	*    the scaling for the data can be derived.
	* @see graph.Axis
	*/
	private Axis xaxis;

	/**
	*    The Axis object the Y data is attached to.
	* @see graph.Axis
	*/
	private Axis yaxis;

	/**
	* The current plottable X maximum of the data. 
	* This can be very different from
	* true data X maximum. The data is clipped when plotted.
	*/
	private double xmax; 

	/**
	* The current plottable X minimum of the data. 
	* This can be very different from
	* true data X minimum. The data is clipped when plotted.
	*/
	private double xmin;

	/**
	* The current plottable Y maximum of the data. 
	* This can be very different from
	* true data Y maximum. The data is clipped when plotted.
	*/
	private double ymax; 

	/**
	* The current plottable Y minimum of the data. 
	* This can be very different from
	* true data Y minimum. The data is clipped when plotted.
	*/
	private double ymin;

	/**
	* Boolean to control clipping of the data window.
	* Default value is <em>true</em>, clip the data window.
	*/
	private boolean clipping = false;

	/**
	* Drawer of price bars - e.g., tic bars or candles
	*/
	private BasicDrawer drawer;

	/**
	* Drawer of dates
	*/
	protected DateDrawer date_drawer;

	/**
	* Drawer of times
	*/
	private TimeDrawer time_drawer;

	// Horizontal, vertical line data
	private ArrayList hline_data;
	private ArrayList vline_data;

	/**
	*    The X range of the clipped data
	*/
	private double xrange;

	/**
	*    The Y range of the clipped data
	*/
	private double yrange;

	// Has range() been called to set the range?
	private boolean range_set = false;

	private boolean dates_needed;
}
