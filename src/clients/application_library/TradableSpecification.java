package application_library;

import java.util.*;
import graph_library.DataSet;

// Specification for a data request to the server for data for a "tradable"
public class TradableSpecification {

// Initialization

	public TradableSpecification(String sym, String pertype) {

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
	public IndicatorSpecification indicator_spec_for(
			String indicator_name) {
		return (IndicatorSpecification) indicator_specs.get(indicator_name);
	}

	// The indicator specifications
	public Collection indicator_specifications() {
		return indicator_specs.values();
	}

	// All "selected" indicator specifications
	public Collection selected_indicators() {
		Iterator i = indicator_specs.values().iterator();
		LinkedList result = new LinkedList();
		IndicatorSpecification spec;
		while (i.hasNext()) {
			spec = (IndicatorSpecification) i.next();
			if (spec.selected()) {
				result.add(spec);
			}
		}
		return result;
	}

// Implementation - attributes

	protected String symbol;

	protected String period_type;

	// key: String (name), value: IndicatorSpecification:
	protected HashMap indicator_specs;

	protected DataSet main_data;
}
