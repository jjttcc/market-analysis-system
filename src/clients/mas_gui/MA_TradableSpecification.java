package mas_gui;

import application_library.*;
import java.util.*;
import graph_library.DataSet;

// TradableSpecification with extensions for the open-source Market
// Analysis GUI client
public class MA_TradableSpecification extends TradableSpecification {

// Initialization

	public MA_TradableSpecification(String sym, String pertype) {
		super(sym, pertype);
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

	// Set `period_type' to `t'.
	void set_period_type(String t) {
		period_type = t;
	}

	// Set `main_data' to `d'.
	void set_main_data(DataSet d) {
		main_data = d;
	}

	// Set the data set for the indicator whose name is `indicator_name'
	// to `d'.  If there is no indicator spec with name `indicator_name',
	// no action is taken.
	void set_indicator_data(DataSet d, String indicator_name) {
System.out.println("set ind data called for " + indicator_name + " with " + d);
		IndicatorSpecification i = null;
		if (indicator_specs.containsKey(indicator_name)) {
			i = (IndicatorSpecification)
				indicator_specs.get(indicator_name);
		} else if (special_indicator_specs.containsKey(indicator_name)) {
			i = (IndicatorSpecification)
				special_indicator_specs.get(indicator_name);
		}
		if (i != null) {
System.out.println("indicator was found: " + i);
			i.set_data(d);
		}
else {System.out.println("indicator was NOT found: " + i);}
	}

	// Add indicator specification `i' to `indicator_specifications'.
	void add_indicator(IndicatorSpecification i) {
		indicator_specs.put(i.name(), i);
	}


	// Add "special" indicator specification `i' to
	// `special_indicator_specifications'.
	void add_special_indicator(IndicatorSpecification i) {
		special_indicator_specs.put(i.name(), i);
	}

	// Mark all indicator specifications as not `selected' and set their
	// data sets to null to free up no-longer-needed heap space.
	void unselect_all_indicators() {
		Iterator specs = indicator_specifications().iterator();
		IndicatorSpecification i;
		while (specs.hasNext()) {
			i = (IndicatorSpecification) specs.next();
			i.unselect();
			i.set_data(null);
		}
	}

	// Select indicator with name `name'.
	void select_indicator(String name) {
		IndicatorSpecification i = indicator_spec_for(name);
		if (i != null) {
			i.select();
		}
	}

	// Select indicators with the specified names.
	void select_indicators(Collection names) {
		Iterator i = names.iterator();
		String n;
		while (i.hasNext()) {
			n = (String) i.next();
			IndicatorSpecification ind = indicator_spec_for(n);
			if (ind != null) {
System.out.println("selecting ind: " + ind);
				ind.select();
			}
		}
	}

	// Unselect indicator with name `name' and set its data set to null
	// to free up no-longer-needed heap space.
	void unselect_indicator(String name) {
		IndicatorSpecification i = indicator_spec_for(name);
		if (i != null) {
			i.unselect();
			i.set_data(null);
		}
	}

// Removal

	void clear_all_indicators() {
		indicator_specs.clear();
		special_indicator_specs.clear();
	}

// Implementation - attributes

	// key: String (name), value: IndicatorSpecification:
	private HashMap special_indicator_specs;
}
