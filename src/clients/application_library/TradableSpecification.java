package application_library;

import java.util.*;
import graph_library.DataSet;

// Specification for a data request to the server for data for a "tradable"
public class TradableDataSpecification {

// Initialization

	public TradableDataSpecification(String sym, String pertype) {

		symbol = sym;
		period_type = pertype;
		indicator_specs = new HashMap();
	}

// Access

	// The symbol of the tradable for which data is to be requested
	public String symbol() {
		return symbol;
	}

	// The period type of the data to be requested
	public String period_type() {
		return period_type;
	}

	// The main (date,open,high,low,close,...) data set for the tradable
	public DataSet main_data() {
		return main_data;
	}

	// The indicator specification with indicator with name `indicator_name'
	IndicatorDataSpecification indicator_spec_for(String indicator_name) {
		return (IndicatorDataSpecification) indicator_specs.get(indicator_name);
	}

	// All 'IndicatorDataSpecification's
	Collection indicator_specifications() {
		return indicator_specs.values();
	}

// Implementation - attributes

	private String symbol;

	private String period_type;

	// key: String (indicator_name), value: IndicatorDataSpecification:
	private HashMap indicator_specs;

	private DataSet main_data;
}
