package application_library;

import graph_library.DataSet;

public class IndicatorDataSpecification {
	// The ID for the indicator, according to the client-server protocol
	public int indicator_id() {
		return indicator_id;
	}

	// The name of the indicator
	public String indicator_name() {
		return indicator_name;
	}

	// The data associated with the indicator
	public DataSet data() {
		return data;
	}

	private int indicator_id;


	private String indicator_name;

	private DataSet data;
}
