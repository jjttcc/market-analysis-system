package graph_library;

import java.awt.*;
import java.util.*;



/**
 *  Plottable data sets.
 */
abstract public class DataSet {

// Access

	// Number of records in this data set
	abstract public int size();

	// The name of the data set
	// Postcondition: result != null
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

	// Color data is to be drawn in - can be null
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

// Element change

	// Set the color the data is to be drawn in - can be null
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

// Implementation

	// Color data is to be drawn in - can be null
	protected Color color;
}
