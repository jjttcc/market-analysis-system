package application_library;

import graph_library.DataSet;

// Specification for an indicator data request to the server
public class IndicatorDataSpecification {

// Initialization

	public IndicatorDataSpecification(int the_id, String the_name) {
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

	// The data associated with the indicator
	public DataSet data() {
		return data;
	}

	public String toString() {
		return "indicator name: " + name + ", ID: " + identifier;
	}

// Status report

	public boolean selected() {
		return selected;
	}

// Element change

//@@@Consider creating a MA_IndicatorDataSpecification, moving this
//procedure to it, and making it only package-accessible.  (See
//MA_TradableDataSpecification.)
	// The data associated with the indicator
	public void set_data(DataSet d) {
		data = d;
	}

//@@@Consider creating a MA_IndicatorDataSpecification, moving this
//procedure to it, and making it only package-accessible.  (See
//MA_TradableDataSpecification.)
	// Set `selected' to true.
	public void select() {
		selected = true;
	}

//@@@Consider creating a MA_IndicatorDataSpecification, moving this
//procedure to it, and making it only package-accessible.  (See
//MA_TradableDataSpecification.)
	// Set `selected' to false.
	public void unselect() {
		selected = false;
	}

// Implementation - attributes

	private int identifier;

	private String name;

	private DataSet data;

	private boolean selected = false;
}
