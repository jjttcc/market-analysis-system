package graph_library;

import java.awt.*;
import java.util.*;
import java_library.support.*;


/**
 *  Plottable data sets.
 */
abstract public class DataSet extends BasicUtilities {

// Access

	/**
	* Number of records in this data set
	**/
	abstract public int size();

	/**
	* The name of the data set
	* Postcondition: result != null
	**/
	public String name() {
		return "";	// Redefine if needed.
	}

	/**
	* The data X maximum.
	*/
	abstract public double maximum_x();

	/**
	* The data X minimum.
	*/
	abstract public double minimum_x();

	/**
	* The data Y maximum.
	*/
	abstract public double maximum_y();

	/**
	* The data Y minimum.
	*/
	abstract public double minimum_y();

	/**
	* Color data is to be drawn in - can be null
	**/
	public Color color() { return color; }

	public String toString() {
		String result = name();
		if (result.length() > 0) {
			result += ", " + getClass().getName();
		} else {
			result = getClass().getName();
		}
		return result;
	}

// Status report

	/**
	* Does the last date and time of `this' match the first date and
	* time of `d'?
	**/
	public abstract boolean last_date_time_matches_first(DataSet d);

	/**
	* Does the last tuple (e.g., o,h,l,c values) of `this' match the
	* first tuple of `d'?
	**/
	public abstract boolean last_tuple_matches_first(DataSet d);

	public abstract boolean need_a_name(DataSet d, int this_index, int d_index);

// Element change

	/**
	* Set the color the data is to be drawn in - can be null
	**/
	public void setColor(Color c) { color = c; } 
	/**
	* Append a copy of `d' at end.
	* @postcondition
	*     implies(d == null, size() == old size())
	*     implies(d != null, size() == old size() + d.size()) */
	abstract public void append(DataSet d);

// Removal

	/**
	* Remove all data.
	* @postcondition
	*     size() == 0 */
	abstract public void clear_all();

	/**
	* Remove the last record in this dataset.
	* Precondition: size() > 0
	* Postcondition: size() == old size() - 1
	**/
	public abstract void remove_last_record();

// Implementation

	// Color data is to be drawn in - can be null
	protected Color color;
}
