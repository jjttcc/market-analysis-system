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

	/**
	* Append data set `d' to the `current_data'.
	* Precondition: d != null && d.size() > 0
	* Precondition: last_append_changed_state()
	**/
	public void append_data(DataSet d) {
		assert d != null && d.size() > 0: PRECONDITION;
		DataSet data = current_data();
		if (! data.last_date_time_matches_first(d)) {
			if (data.size() > 1 &&
					data.date_time_matches(d, data.size() - 2, 0)) {

				data.remove_last_record();
				data.remove_last_record();
			} else {
				// No records removed.
			}
		} else {
			data.remove_last_record();
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

// Implementation - attributes

	protected int identifier;

	protected String name;

	private boolean selected = false;
}
