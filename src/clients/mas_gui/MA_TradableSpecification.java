package mas_gui;

import application_library.*;
import java.util.*;
import graph_library.DataSet;

// TradableSpecification with extensions for the open-source Market
// Analysis GUI client
public class MA_TradableSpecification extends TradableSpecification {

// Initialization

	public MA_TradableSpecification(String sym) {
		super(sym);
		special_indicator_specs = new HashMap();
	}

// Access

	// All 'IndicatorSpecification's, including
	// `special_indicator_specifications', valid for the assocaited tradable
	public Collection all_indicator_specifications() {
		Collection result = indicator_specifications();
		result.addAll(special_indicator_specs.values());
		return result;
	}

	// The "special" 'IndicatorSpecification's
	public Collection special_indicator_specifications() {
		return special_indicator_specs.values();
	}

	// The indicator specification with indicator with name `indicator_name'
	public IndicatorSpecification indicator_spec_for(
			String indicator_name) {
		IndicatorSpecification result = super.indicator_spec_for(	
			indicator_name);
		if (result == null) {
			result = (IndicatorSpecification)
				special_indicator_specs.get(indicator_name);
		}
		return result;
	}

// Element change

	// Set `symbol' to `s'.
	void set_symbol(String s) {
		symbol = s;
	}

	// Set `data' to `d'.
	void set_data(DataSet d) {
		data = d;
	}

	// Set the data set for the indicator whose name is `indicator_name'
	// to `d'.  If there is no indicator spec with name `indicator_name',
	// no action is taken.
	void set_indicator_data(DataSet d, String indicator_name) {
		MA_IndicatorSpecification spec = null;
		if (indicator_specs.containsKey(indicator_name)) {
			spec = (MA_IndicatorSpecification)
				indicator_specs.get(indicator_name);
		} else if (special_indicator_specs.containsKey(indicator_name)) {
			spec = (MA_IndicatorSpecification)
				special_indicator_specs.get(indicator_name);
		}
		if (spec != null) {
			spec.set_data(d);
		}
	}

	// Add indicator specification `spec' to `indicator_specifications'.
	void add_indicator(IndicatorSpecification spec) {
		indicator_specs.put(spec.name(), spec);
	}


	// Add "special" indicator specification `spec' to
	// `special_indicator_specifications'.
	void add_special_indicator(IndicatorSpecification spec) {
		special_indicator_specs.put(spec.name(), spec);
	}

	// Mark all indicator specifications as not `selected' and set their
	// data sets to null to free up no-longer-needed heap space.
	void unselect_all_indicators() {
		Iterator specs = indicator_specifications().iterator();
		MA_IndicatorSpecification spec;
		while (specs.hasNext()) {
			spec = (MA_IndicatorSpecification) specs.next();
			spec.unselect();
			spec.set_data(null);
		}
	}

	// Select indicator with name `name'.
	void select_indicator(String name) {
		MA_IndicatorSpecification spec =
			(MA_IndicatorSpecification) indicator_spec_for(name);
		if (spec != null) {
			spec.select();
		}
	}

	// Select indicators with the specified names.
	void select_indicators(Collection names) {
		Iterator i = names.iterator();
		String n;
		while (i.hasNext()) {
			n = (String) i.next();
			MA_IndicatorSpecification ind =
				(MA_IndicatorSpecification) indicator_spec_for(n);
			if (ind != null) {
				ind.select();
			}
		}
	}

	// Unselect indicator with name `name' and set its data set to null
	// to free up no-longer-needed heap space.
	void unselect_indicator(String name) {
		MA_IndicatorSpecification spec =
			(MA_IndicatorSpecification) indicator_spec_for(name);
		if (spec != null) {
			spec.unselect();
			spec.set_data(null);
		}
	}

	public void append_data(DataSet d) {
		data.append(d);
	}

// Implementation - attributes
// Removal

	void clear_all_indicators() {
		indicator_specs.clear();
		special_indicator_specs.clear();
	}

// Implementation - attributes

	// key: String (name), value: MA_IndicatorSpecification:
	private HashMap special_indicator_specs;

	protected DataSet data;
}
