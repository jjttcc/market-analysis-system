package mas_gui;

import application_library.IndicatorSpecification;
import graph_library.DataSet;

// Specification for an indicator data request to the server
public class MA_IndicatorSpecification extends IndicatorSpecification {

// Initialization

	public MA_IndicatorSpecification(int the_id, String the_name) {
		super(the_id, the_name);
	}

// Access

	public DataSet current_data() {
		return data;
	}

// Element change

	/** Set the data set associated with the indicator to `d' */
	public void set_data(DataSet d) {
		data = d;
	}

//!!!!:
	public void old_remove_me_please_append_data(DataSet d) {
		data.append(d);
	}

// Removal

	public void clear_data() {
		data.clear_all();
	}

// Implementation - attributes

	private DataSet data;
}
