package application_library;

import graph_library.DataSet;

// Specification for an indicator data request to the server
abstract public class IndicatorSpecification extends DataSpecification {

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

	public void append_data(DataSet d) {
		DataSet data = current_data();
		if (! data.last_date_time_matches_first(d)) {
			if (data.size() > 1 && data.need_a_name(d, data.size() - 2, 0)) {
				data.remove_last_record();
				data.remove_last_record();
System.out.println("IS app_data - 2 records removed");
			}
else {
System.out.println("IS app_data - NOTHING removed");
}
		} else {
			data.remove_last_record();
System.out.println("IS app_data - 1 record removed");
		}
		data.append(d);
		last_append_changed_state = true;
	}

	/** Set `selected' to true. */
	public void select() {
		selected = true;
	}

	// Set `selected' to false.
	public void unselect() {
		selected = false;
	}

// Hook routine implementations

	protected boolean bypass_append_data_guards() {
		return true;
	}

// Implementation - attributes

	protected int identifier;

	protected String name;

	private boolean selected = false;
}
