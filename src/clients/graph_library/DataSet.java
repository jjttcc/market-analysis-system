package graph_library;

import java.awt.*;
import java.util.*;



/**
 *  Plottable data sets.
 */
abstract public class DataSet {

// Access

	// Number of records in this data set
	abstract public int count();

	// Color data is to be drawn in - can be null
	public Color color() { return color; }

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

// Element change

	// Set the color the data is to be drawn in - can be null
	public void setColor(Color c) { color = c; }

	/**
	* Append a copy of `d' at end.
	* @postcondition
	*     implies(d == null, count() == old count())
	*     implies(d != null, count() == old count() + d.count()) */
	abstract public void append(DataSet d);

// Implementation

	// Color data is to be drawn in - can be null
	protected Color color;
}
