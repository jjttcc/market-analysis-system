package application_library;

import java.util.*;

/**
* Specification for a set of data requests to the server for data to
# be displayed in a chart window
**/
abstract public class ChartableSpecification {

// Initialization

	public ChartableSpecification(String pertype) {
		period_type = pertype;
	}

// Access

	/**
	* The period type of the data to be requested
	**/
	public String period_type() {
		return period_type;
	}

	/**
	* The 'TradableSpecification's
	**/
	public abstract Collection tradable_specifications();

	/**
	* TradableSpecification from `tradable_specifications' with the
	* symbol `symbol', if any, otherwise, null
	**/
	public TradableSpecification specification_for(String symbol) {
		Iterator specs = tradable_specifications().iterator();
		TradableSpecification spec, result = null;
		if (symbol != null) {
			while (result == null && specs.hasNext()) {
				spec = (TradableSpecification) specs.next();
				if (symbol.equals(result.symbol())) {
					result = spec;
				}
			}
		}
		return result;
	}

	/**
	* All "selected" indicator specifications for all tradables
	**/
	public Collection selected_indicators() {
		Iterator i = tradable_specifications().iterator();
		LinkedList result = new LinkedList();
		TradableSpecification tspec;
		while (i.hasNext()) {
			tspec = (TradableSpecification) i.next();
			Iterator j = tspec.indicator_specifications().iterator();
			IndicatorSpecification ispec;
			while (j.hasNext()) {
				ispec = (IndicatorSpecification) j.next();
				if (ispec.selected()) {
					result.add(ispec);
				}
			}
		}

		return result;
	}

// Implementation - attributes

	protected String period_type;
}
