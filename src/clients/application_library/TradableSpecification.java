package application_library;

import java.util.*;
import graph_library.DataSet;

/**
* Specification for a data request to the server for data for a "tradable"
**/
abstract public class TradableSpecification {

// Initialization

	public TradableSpecification(String sym) {
		symbol = sym;
		indicator_specs = new HashMap();
	}

// Access

	/**
	* The symbol of the tradable for which data is to be requested
	**/
	public String symbol() {
		return symbol;
	}

	/**
	* The indicator specification with indicator with name `indicator_name'
	**/
	public IndicatorSpecification indicator_spec_for(
			String indicator_name) {

System.out.println("isf = ispecs.size: " + indicator_specs.size());
		return (IndicatorSpecification) indicator_specs.get(indicator_name);
	}

	/**
	* The indicator specifications
	**/
	public Collection indicator_specifications() {
		return indicator_specs.values();
	}

	/**
	* All "selected" indicator specifications
	**/
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

// Element change

	/**
	* Append data set `d' to the current main (date,open,high,low,close,...)
	* tradable data.
	**/
	public abstract void append_data(DataSet d);

// Implementation - attributes

	protected String symbol;

	// key: String (name), value: IndicatorSpecification:
	protected HashMap indicator_specs;
}
