package application_library;

import graph_library.DataSet;

// Specification for an indicator data request to the server
abstract public class IndicatorSpecification {

// Initialization

	public IndicatorSpecification(int the_id, String the_name) {
		identifier = the_id;
		name = the_name;
	}

// Access

	// The identifier for the indicator, according to the
	// client-server protocol
	public int identifier() {
		return identifier;
	}

	// The name of the indicator
	public String name() {
		return name;
	}

	public String toString() {
		return "indicator name: " + name + ", ID: " + identifier;
	}

// Status report

	/**
	Has the indicator been selected for display?
	*/
	public boolean selected() {
		return selected;
	}

// Element change

	/** Set `selected' to true. */
	public void select() {
		selected = true;
	}

	// Set `selected' to false.
	public void unselect() {
		selected = false;
	}

	/**
	* Append data set `d' to the current indicator data.
	**/
	public abstract void append_data(DataSet d);

// Implementation - attributes

	protected int identifier;

	protected String name;

	private boolean selected = false;
}
