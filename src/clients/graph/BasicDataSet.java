package graph;

import java.awt.*;
import java.util.*;
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
 * Basic plottable data sets
 */
public class BasicDataSet extends DataSet {

// Initialization

	/**
	*  Instantiate an empty data set.
	* @precondition
	*     d != null<br>
	* @postcondition<br>
	*     size() == 0
	*     data != null && dates != null && times != null
	*/
	public BasicDataSet() {
		data = new ArrayList();
		dates = new ArrayList();
		times = new ArrayList();
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
	* precondition:<br>
	*     d != null && n >= 0<br>
	* postcondition:<br>
	*     size() == data_points()
	*     data != null && dates != null && times != null
	*/
	public BasicDataSet(double d[], int n) throws Error {
		if (d  == null || n < 0) {
			String msg = "BasicDataSet constructor: precondition violated:\n";
			if (d == null) {
				msg += "Argument d is null.";
			} else {
				msg += "Argument n is less than 0.";
			}
			throw new Error(msg);
		}
		data = new ArrayList(d.length);
		dates = new ArrayList();
		times = new ArrayList();
		for (int i = 0; i < d.length; ++i) {
			data.add(new Double(d[i]));
		}

		tuple_count = n;
	}

// Access

	public double maximum_x() {  return dxmax; } 

	public double minimum_x() {  return dxmin; } 

	public double maximum_y() {  return dymax; } 

	public double minimum_y() {  return dymin; }

	// Number of records in this data set
	public int size() {
		return tuple_count;
	}

	public String toString() {
		String result = super.toString();
		result += " - data size, dates size, times size: " + data.size() +
			", " + dates.size() + ", " + times.size();
		if (dates.size() != times.size()) {
			result += "\ndates, times have different sizes: " +
				dates.size() + ", " + times.size();
		}
			
		if (getClass().getName().equals("graph.DrawableDataSet")) {
			if (data.size() / stride() != dates.size()) {
				result += "\n[1] dates, data have different sizes: " +
					dates.size() + ", " + data.size() / stride();
		}
		} else {
			if (dates.size() != data.size() &&
					data.size() / 4 != dates.size()) {
				result += "\n[2] dates, data have different sizes: " +
					dates.size() + ", " + data.size() / stride();
			}
		}
		return result;
	}

// Element change

	public void append(DataSet d) {
		throw new Error("Code defect: Unimplemented procedure called: 'append");
	}

	public void set_dates(ArrayList d) {
		dates = d;
	}

	public void set_times(ArrayList t) {
		times = t;
	}

	public void set_dates(String[] d) {
		dates = new ArrayList(d.length);
		for (int i = 0; i < d.length; ++i) {
			dates.add(d[i]);
		}
	}

	public void set_times(String[] t) {
		times = new ArrayList(t.length);
		for (int i = 0; i < t.length; ++i) {
			times.add(t[i]);
		}
	}


// Implementation

	/**
	* Number of components in a data tuple - for example, 2 (x, y) for
	* a simple point
	*/
	protected int stride() { return 1; }

	protected int length() {
		int result = 0;
		if (data != null) result = data.size();
		return result;
	}

// Implementation - attributes

	// Main data
	protected ArrayList data;	// Double

	// Date data
	protected ArrayList dates;	// String

	// Time data
	protected ArrayList times;	// String

	/**
	* The data X maximum. 
	* Once the data is loaded this will never change.
	*/
	protected double dxmax;

	/**
	* The data X minimum. 
	* Once the data is loaded this will never change.
	*/
	protected double dxmin;

	/**
	* The data Y maximum. 
	* Once the data is loaded this will never change.
	*/
	protected double dymax;

	/**
	* The data Y minimum. 
	* Once the data is loaded this will never change.
	*/
	protected double dymin;

	// Number of tuples in the data
	protected int tuple_count;
}
