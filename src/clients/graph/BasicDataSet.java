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
 * Basic plottable data sets
 */
public class BasicDataSet extends DataSet implements AssertionConstants {

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

	// Main data (List[Double])
	public java.util.List data() {
		return data;
	}

	// Date data (List[String])
	public java.util.List dates() {
		return dates;
	}

	// Time data (List[String])
	public java.util.List times() {
		return times;
	}

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
		StringBuffer buffer = new StringBuffer();
		buffer.append(" - stride, data size, dates size, times size: " +
			stride() + ", " + data.size() + ", " + dates.size() + ", " +
			times.size());
		if (dates.size() != times.size()) {
			buffer.append("\ndates, times have different sizes: " +
				dates.size() + ", " + times.size());
		}
			
		if (getClass().getName().equals("graph.DrawableDataSet")) {
			if (data.size() / stride() != dates.size()) {
				buffer.append("\n[1] dates, data have different sizes: " +
					dates.size() + ", " + data.size() / stride());
		}
		} else {
			if (dates.size() != data.size() &&
					data.size() / 4 != dates.size()) {
				buffer.append("\n[2] dates, data have different sizes: " +
					dates.size() + ", " + data.size() / stride());
			}
		}
		int size = size();
		int stride = stride();
		assert stride > 0;
		buffer.append("\n");
		for (int i = 0; i < size; ++i) {
			buffer.append(dates.get(i) + ", " + times.get(i) + ", ");
			int j;
			for (j = 0; j < stride - 1; ++j) {
				buffer.append(data.get(i * stride + j) + ",");
			}
			buffer.append(data.get(i * stride + j) + "\n");
		}
		result = result + buffer.toString();
		return result;
	}

// Status report

	public boolean last_date_time_matches_first(DataSet d) {
		boolean result = false;
		if (d != null) {
			BasicDataSet drwd = (BasicDataSet) d;
			java.util.List new_dates = drwd.dates;
			java.util.List new_times = drwd.times;
			if (! new_dates.isEmpty() && ! new_times.isEmpty() &&
					! dates.isEmpty() && ! times.isEmpty()) {

				result = ((String) last_in_list(dates)).equals(
						((String) first_in_list(new_dates))) &&
						((String) last_in_list(times)).equals(
						((String) first_in_list(new_times)));
			}
		}
		return result;
	}

	public boolean last_tuple_matches_first(DataSet d) {
		boolean result = false;
		if (d != null) {
			BasicDataSet drwd = (BasicDataSet) d;
			java.util.List new_data = drwd.data;
			if (! new_data.isEmpty() && ! data.isEmpty()) {
				result = true;
				int stride = stride();
				for (int i = 0; result && i < stride; ++i) {
					Double current_field =
						((Double) data.get(data.size() - (stride - i)));
					Double new_field = ((Double) new_data.get(i));
					result = current_field.equals(new_field);
				}
			}
		}
		return result;
	}

	public boolean date_time_matches(DataSet d, int this_index, int d_index) {

		boolean result = false;
		if (d != null) {
			BasicDataSet drwd = (BasicDataSet) d;
			java.util.List new_dates = drwd.dates;
			java.util.List new_times = drwd.times;
			if (! new_dates.isEmpty() && ! new_times.isEmpty() &&
					! dates.isEmpty() && ! times.isEmpty()) {

				result = ((String) dates.get(this_index)).equals(
						((String) new_dates.get(d_index))) &&
						((String) times.get(this_index)).equals(
						((String) new_times.get(d_index)));
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

// Removal

	public void clear_all() {
		data.clear();
		dates.clear();
		times.clear();
		tuple_count = 0;
	}

	public void remove_last_record() {
		assert size() > 0: PRECONDITION;
		int stride = stride(), oldsize = size();
		for (int i = 0; i < stride; ++i) {
			data.remove(data.size() - 1);
		}
		assert dates.size() == tuple_count;
		dates.remove(dates.size() - 1);
		if (! times.isEmpty()) {
			times.remove(times.size() - 1);
		}
		--tuple_count;
		assert dates.size() == tuple_count;
		assert size() == oldsize - 1: POSTCONDITION;
	}

// Class invariant

	public boolean invariant() {
		return data != null && dates != null && times != null &&
			(times.isEmpty() || times.size() == dates.size());
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
