package application_library;

import java.util.*;
import java_library.support.*;
import graph_library.DataSet;

//!!!!Remove when finished debugging:
		import graph.*;

/**
* General specification for a tradable data request to the server
**/
abstract public class DataSpecification implements AssertionConstants {

// Access

	/**
	* The current data
	**/
	public abstract DataSet current_data();

// Status report

	// Did the last call to `append_data' actually add any records?
	public boolean last_append_changed_state() {
		return last_append_changed_state;
	}

// Element change

	/**
	* Append data set `d' to the `current_data'.
	**/
//!!!!!!!!!:
	public void append_data_first_try(DataSet d) {
		DataSet data = current_data();
		boolean last_record_was_remove = false;
		// If the last date/time of `data' matches the first date/time of `d'
		// and the last tuple (ohlc tuple) does NOT match the first tuple
		// of `d'
		if (data.last_date_time_matches_first(d) &&
				! data.last_tuple_matches_first(d)) {

			data.remove_last_record();
			last_record_was_remove = true;
		}
		if (last_record_was_remove || d.size() > 1) {
			data.append(d);
			last_append_changed_state = true;
		}
	}

	/**
	* Append data set `d' to the `current_data'.
	* Precondition: d != null && d.size() > 0
	**/
	public void append_data_second_try(DataSet d) {
		assert d != null && d.size() > 0: PRECONDITION;
		DataSet data = current_data();
		last_append_changed_state = false;
System.out.println("A");
		if (data.last_date_time_matches_first(d)) {
System.out.println("B");
			if (d.size() > 1 || ! data.last_tuple_matches_first(d)) {
System.out.println("C");
				// 'data.last_date_time_matches_first(d)' means that the
				// last tuple of `data' needs to be replaced by the first
				// tuple of `d', which is done by removing data's last tuple:
System.out.println("d.size: " + d.size());
System.out.println("data.last_tuple_matches_first(d)): " +
data.last_tuple_matches_first(d));
System.out.println("Not surprisingly, this path was executed!!");
				data.remove_last_record();
				data.append(d);
				last_append_changed_state = true;
			}
else {
System.out.println("D");
System.out.println("last d/t matches first, but tuple also matches");
}
		} else if (d.size() > 1) {
System.out.println("E");
			assert ! data.last_date_time_matches_first(d);
System.out.println("ODDLY, this path was executed!!");
			data.append(d);
			last_append_changed_state = true;
		}
	}

//!!!:
static boolean appd_called = false;
	/**
	* Append data set `d' to the `current_data'.
	* Precondition: d != null && d.size() > 0
	# Precondition: current_data().last_date_time_matches_first(d);
	**/
	public void append_data(DataSet d) {
		assert d != null && d.size() > 0: PRECONDITION;
//!!!!:		assert current_data().last_date_time_matches_first(d): PRECONDITION;
//!!!:
if (! appd_called) {
System.out.println("new append data being used");
}
appd_called = true;
if (! current_data().last_date_time_matches_first(d)) {
System.out.println("OOOOOOOOOOPPPPPPPPPPPP");
BasicDataSet data = (BasicDataSet) current_data();
BasicDataSet newdata = (BasicDataSet) d;
System.out.println("d.size, cur data.size: " + newdata.size() + ", " +
	data.size());
System.out.println("last date/time in cur data: '" +
	data.dates().get(data.size() - 1) + "', '" +
	data.times().get(data.size() - 1) + "'");
System.out.println("first date/time in d: '" +
	newdata.dates().get(0) + "', '" +
	newdata.times().get(0) + "'");
System.out.println("checking current_data().last_date_time_matches_first(d) " +
"again: " + current_data().last_date_time_matches_first(d));
System.out.println("d: '" + d + "'");
System.out.println("cur data: '" + current_data() + "'");
System.exit(227);
}
		DataSet data = current_data();
		last_append_changed_state = false;
		assert data.last_date_time_matches_first(d);
		if (bypass_append_data_guards() || (d.size() > 1 ||
				! data.last_tuple_matches_first(d))) {
			// Since the last record of `data' is for the same time period as
			// the first record of `d', it needs to be replaced by the
			// first record of `d'.  (I.e., remove the last record of `data'
			// before appending `d' to `data'.)
			append_data_without_guards(d);
System.out.println("A");
		} else {
			assert d.size() == 1 && data.last_tuple_matches_first(d) &&
				data.last_date_time_matches_first(d): ASSERTION;
			// Since d.size is 1 and the last record of `data' matches
			// the single record in `d', there is no need to replace the
			// last record of `data' with the first record of `d'.
			assert last_append_changed_state == false: ASSERTION;
System.out.println("B");
		}
	}

// Removal

	/**
	* Clear `current_data'.
	**/
	public abstract void clear_data();

// Hook routines

	// Should guard conditions for 'append_data' be bypassed?
	protected boolean bypass_append_data_guards() {
		return false;
	}

	/**
	* Append data set `d' to the `current_data' without any guards.
	* Precondition: d != null && d.size() > 0
	# Precondition: current_data().last_date_time_matches_first(d);
	# Precondition: bypass_append_data_guards() || (d.size() > 1 ||
			! current_data().last_tuple_matches_first(d))
	# Postcondition: last_append_changed_state()
	**/
	private void append_data_without_guards(DataSet d) {
		assert d != null && d.size() > 0: PRECONDITION;
		assert current_data().last_date_time_matches_first(d): PRECONDITION;
		assert bypass_append_data_guards() || (d.size() > 1 ||
			! current_data().last_tuple_matches_first(d)): PRECONDITION;

System.out.println("[adwg] bypass_append_data_guards(): " +
bypass_append_data_guards());
		DataSet data = current_data();
		data.remove_last_record();
		data.append(d);
		last_append_changed_state = true;
	}

// Implementation - Attributes

	protected boolean last_append_changed_state;
}
