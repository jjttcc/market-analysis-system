package mas_gui;

import application_library.*;
import java.util.*;
import graph_library.DataSet;

// ChartableSpecification with extensions for the open-source Market
// Analysis GUI client
public class MA_ChartableSpecification extends ChartableSpecification {

// Initialization

	public MA_ChartableSpecification(String sym, String pertype) {
		super(pertype);
		tradable_specification = new MA_TradableSpecification(sym);
	}

// Access

	public MA_TradableSpecification tradable_specification() {
		return tradable_specification;
	}

	public Collection tradable_specifications() {
		if (tradable_specifications == null) {
			tradable_specifications = new LinkedList();
			tradable_specifications.add(tradable_specification);
		}
		return tradable_specifications;
	}

// Element change

	// Set `period_type' to `t'.
	void set_period_type(String t) {
		period_type = t;
	}


// Implementation - attributes

	private MA_TradableSpecification tradable_specification;

	private Collection tradable_specifications;
}
