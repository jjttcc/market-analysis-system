package mas_gui;

import application_library.IndicatorSpecification;
import graph_library.DataSet;

// Specification for an indicator data request to the server
public class MA_IndicatorSpecification extends IndicatorSpecification {

// Initialization

	public MA_IndicatorSpecification(int the_id, String the_name) {
		super(the_id, the_name);
	}

// Element change

	/** Set the data set associated with the indicator to `d' */
	public void set_data(DataSet d) {
		data = d;
	}

	public void append_data(DataSet d) {
		data.append(d);
	}

// Implementation - attributes

	private DataSet data;
}
