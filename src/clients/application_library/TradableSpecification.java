package application_library;

import java.util.*;
import graph_library.DataSet;

/**
* Specification for a data request to the server for data for a "tradable"
**/
abstract public class TradableSpecification extends DataSpecification {

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

// Basic operations

	/**
	* Append data set `d' to the `current_data'.
	* Precondition: d != null && d.size() > 0
	# Precondition: current_data().last_date_time_matches_first(d);
	**/
	public void append_data(DataSet d) {
		assert d != null && d.size() > 0: PRECONDITION;
		assert current_data().last_date_time_matches_first(d): PRECONDITION;
		DataSet data = current_data();
		last_append_changed_state = false;
		assert data.last_date_time_matches_first(d);
		if (d.size() > 1 || ! data.last_tuple_matches_first(d)) {
			// Since the last record of `data' is for the same time period as
			// the first record of `d', it needs to be replaced by the
			// first record of `d'.  (I.e., remove the last record of `data'
			// before appending `d' to `data'.)
			data.remove_last_record();
			data.append(d);
			last_append_changed_state = true;
		} else {
			assert d.size() == 1 && data.last_tuple_matches_first(d) &&
				data.last_date_time_matches_first(d): ASSERTION;
			// Since d.size is 1 and the last record of `data' matches
			// the single record in `d', there is no need to replace the
			// last record of `data' with the first record of `d'.
			assert last_append_changed_state == false: ASSERTION;
		}
	}

// Implementation - attributes

	protected String symbol;

	// key: String (name), value: IndicatorSpecification:
	protected HashMap indicator_specs;
}
