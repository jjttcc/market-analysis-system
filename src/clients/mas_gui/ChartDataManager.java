/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;
import java.io.*;
import java_library.support.*;
import common.*;
import support.*;
import application_library.*;
import application_support.*;
import graph.*;


/**
* Objects that manage data and state information associated with a Chart
**/
public class ChartDataManager extends Logic implements NetworkProtocol,
	AssertionConstants {

// Initialization

	public ChartDataManager(DataSetBuilder builder, Chart the_owner) {
		data_builder = builder;
		owner = the_owner;

		Vector tradables;
		current_upper_indicators = new Vector();
		current_lower_indicators = new Vector();


		facilities = new ChartFacilities(owner);
		specification = new MA_ChartableSpecification("", "");
		tradable_specification = (MA_TradableSpecification)
			specification.tradable_specification();
		try {
			tradables = data_builder.tradable_list();
			if (! tradables.isEmpty()) {
				// Each tradable has its own period type list; but for now,
				// just retrieve the list for the first tradable and use
				// it for all tradables.
				period_types = data_builder.trading_period_type_list(
					(String) tradables.elementAt(0));
				if (data_builder.connection().error_occurred()) {
					facilities.abort(data_builder.connection().
						result().toString(), null);
				}
				reinitialize_current_period_type();
			} else {
				facilities.abort(TRADABLE_LIST_EMPTY_ERROR, null);
			}
		} catch (IOException e) {
			System.err.println(IO_EXCEPTION_ERROR + e + ABORTING_SUFFIX);
			e.printStackTrace();
			quit(-1);
		}
	}

// Access

	/**
	* Chart-related facilities
	**/
	public ChartFacilities facilities() {
		return facilities;
	}

	/**
	* List of all tradables in the server's database
	**/
	public Vector tradables() {
		Vector result = null;
		try {
			result = data_builder.tradable_list();
		}
		catch (IOException e) {
			System.err.println(IO_EXCEPTION_ERROR + e + ABORTING_SUFFIX);
			quit(-1);
		}
		return result;
	}

	/**
	* The current list of indicators for the upper part of the chart
	**/
	public Vector current_upper_indicators() {
		return current_upper_indicators;
	}

	/**
	* The current list of indicators for the lower part of the chart
	**/
	public Vector current_lower_indicators() {
		return current_lower_indicators;
	}

	/**
	* Indicators in user-specified order
	**/
	public Vector ordered_indicators() {
		if (ordered_indicator_list == null) {
			// Force creation of ordered_indicator_list, if it hasn't
			// yet been created.
			rebuild_indicators_if_needed();
		}
		return ordered_indicator_list;
	}

	/**
	* Symbol for current selected tradable
	**/
	public String current_tradable() {
		return tradable_specification.symbol();
	}

	/**
	* Current selected period_type
	**/
	public String current_period_type() {
		return specification.period_type();
	}

	/**
	* Valid trading period types for the current tradable
	**/
	public Vector period_types() {
		return period_types;
	}

	/**
	* The identifier value associated with indicator name `ind_name'
	**/
	public int indicator_id_for(String ind_name) {
		int result = -1;
		rebuild_indicators_if_needed();
		IndicatorSpecification ispec =
			tradable_specification.indicator_spec_for(ind_name);
		if (ispec != null) {
			result = ispec.identifier();
		}
		return result;
	}

	public Calendar latest_date_time() {
		return latest_date_time;
	}

	/**
	* The "specification" for chartable data request status
	**/
	public ChartableSpecification specification() {
		return specification;
	}

	/**
	* The "specification" for the current "tradable"
	**/
	public MA_TradableSpecification tradable_specification() {
		return tradable_specification;
	}

	/**
	* The object used to parse and build the requested data
	**/
	public AbstractDataSetBuilder data_builder() {
		return data_builder;
	}

	/**
	* Result of last request to the server
	**/
	public int request_result_id() {
		int result = 0;
		if (data_requester != null) {
				result = data_requester.request_result_id();
		}
		return result;
	}

// Element change

	// Reset the `current_period_type()' to a reasonable value.
	public void reinitialize_current_period_type() {
		set_current_period_type(initial_period_type(period_types));
	}

// Basic operations

	public void quit(int status) {
		owner.quit(status);
	}

	public void log_out_and_exit(int status) {
		owner.log_out_and_exit(status);
	}

	public void display_warning(String msg) {
		owner.display_warning(msg);
	}

	public void reset_period_types_menu() {
		owner.reset_period_types_menu();
	}

	// Request a new set of period types for tradable and, if the request
	// was successful, set `period_types' to the result.
	public void send_period_types_request(String tradable) {
		try {
			period_types = data_builder.trading_period_type_list(tradable);
		} catch (IOException e) {
			String errmsg = IO_EXCEPTION_ERROR + e + ABORTING_SUFFIX;
			owner.display_warning(errmsg);
			System.err.println(errmsg);
			e.printStackTrace();
			quit(-1);
		}
	}

	// Send a data request for the specified `tradable' and obtain the
	// resulting data sets.
	public void send_data_request(String tradable) {
		last_data_request_succeeded = true;
		DrawableDataSet main_dataset;
		List upper_indicator_datasets = null, lower_indicator_datasets = null;
		if (period_type_change || ! tradable.equals(current_tradable())) {
			data_requester = new SynchronizedDataRequester(data_builder,
				tradable, current_period_type());
			owner.turn_off_refresh();	// Prevent auto-refresh conflicts.
			GUI_Utilities.busy_cursor(true, owner);
			if (individual_period_type_sets &&
					! tradable.equals(current_tradable())) {
				facilities.reset_period_types(tradable, false);
			}
			main_dataset = main_tradable_data();
			if (last_data_request_succeeded) {
				update_indicator_list();
			}
			if (last_data_request_succeeded) {
				upper_indicator_datasets = upper_indicator_data();
			}
			if (last_data_request_succeeded) {
				lower_indicator_datasets = lower_indicator_data();
			}
			if (last_data_request_succeeded) {
				assert main_dataset != null && upper_indicator_datasets != null
					&& lower_indicator_datasets != null;
				// All data-set requests succeeded - plug them in.
				update_main_dataset(main_dataset);
				update_indicator_datasets(upper_indicator_datasets, true);
				update_indicator_datasets(lower_indicator_datasets, false);
				set_current_tradable(tradable);
				owner.set_window_title();
				owner.main_pane().repaint_graphs();
				period_type_change = false;
			}
			GUI_Utilities.busy_cursor(false, owner);
			owner.turn_on_refresh();
		}
	}

// Package-level access

	/**
	* Update `latest_date_time' to `d'.
	**/
	void update_latest_date_time(Calendar d) {
		latest_date_time = d;
	}

	/**
	* Set `current_upper_indicators' to `inds'.
	**/
	void set_current_upper_indicators(Vector inds) {
		current_upper_indicators = inds;
	}

	/**
	* Set `current_lower_indicators' to `inds'.
	**/
	void set_current_lower_indicators(Vector inds) {
		current_lower_indicators = inds;
	}

	/**
	* Should new indicator selections replace, rather than be added to,
	* existing indicators?
	**/
	boolean replace_indicators() {
		return replace_indicators;
	}

	/**
	* Set `replace_indicators' to `arg'.
	**/
	void set_replace_indicators(boolean arg) {
		replace_indicators = arg;
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed(String new_period_type) {
		if (! current_period_type().equals(new_period_type)) {
			set_current_period_type(new_period_type);
			period_type_change = true;
			if (current_tradable() != null) {
				owner.request_data(current_tradable());
			}
		}
	}

	/**
	* Unselect all upper indicators in the indicator specification.
	**/
	void unselect_upper_indicators() {
		Iterator i = current_upper_indicators.iterator();
		while (i.hasNext()) {
			tradable_specification.unselect_indicator((String) i.next());
		}
	}

	/**
	* Unselect all lower indicators in the indicator specification.
	**/
	void unselect_lower_indicators() {
		Iterator i = current_lower_indicators.iterator();
		while (i.hasNext()) {
			tradable_specification.unselect_indicator((String) i.next());
		}
	}

	/**
	* Link `d' with the appropriate indicator group, using `indicator_name'
	* as a key.  If `indicator_name' is null, the group for the main
	* (upper) graph will be used.  If `indicator_name' specifies an
	* indicator that is not a group member, no action is taken.
	**/
	void link_with_axis(DrawableDataSet d, String indicator_name) {
		if (indicator_groups == null) {
			indicator_groups = (IndicatorGroups) MA_Configuration.
				application_instance().indicator_groups().clone();
		}
		MonoAxisIndicatorGroup group;
		if (indicator_name == null) {
			indicator_name = indicator_groups.Maingroup;
		}
		group = (MonoAxisIndicatorGroup) indicator_groups.at(indicator_name);
		if (group != null) {
			group.attach_data_set(d);
		}
	}

	/**
	* The last result of a request for the main data set (o,h,l,c,...)
	* of the current tradable.
	**/
	DrawableDataSet last_tradable_result() {
		return (DrawableDataSet) data_requester.tradable_result();
	}

	/**
	* The last result of a request for the volume component of the
	* main data set of the current tradable.
	**/
	DrawableDataSet last_volume_result() {
		return (DrawableDataSet) data_requester.volume_result();
	}

	/**
	* The last result of a request for the open-interest component of the
	* main data set of the current tradable.
	**/
	DrawableDataSet last_open_interest_result() {
		return (DrawableDataSet) data_requester.open_interest_result();
	}

// Implementation - Element change

	private void set_current_period_type(String type) {
		specification.set_period_type(type);
	}

	private void set_current_tradable(String t) {
		tradable_specification.set_symbol(t);
	}

// Implementation

	// First period type to be displayed - daily, if it exists
	String initial_period_type(Vector types) {
		String result = null;
		String daily = MA_MenuBar.daily_period.toLowerCase();
		for (int i = 0; result == null && i < types.size(); ++i) {
			if (((String) types.elementAt(i)).toLowerCase().equals(daily)) {
				result = (String) types.elementAt(i);
			}
		}
		if (result == null) result = (String) types.elementAt(0);

		return result;
	}

	// If the "indicator list" is out of date, rebuild it.
	// Precondition: data_requester != null
	private void rebuild_indicators_if_needed() {
		assert data_requester != null: PRECONDITION;
		if (tradable_specification.all_indicator_specifications().size() == 0
				|| new_indicators) {
			new_indicators = false;
			Vector inds_from_server = data_requester.indicator_list_result();
			if (previous_open_interest != data_builder.has_open_interest() ||
					! Utilities.lists_match(inds_from_server,
					old_indicators_from_server)) {

				// The old indicators are not the same as the indicators
				// just obtained from the server (or there are not yet
				// any old indicators), so the indicator lists need to
				// be rebuilt.
				old_indicators_from_server = inds_from_server;
				make_indicator_lists(inds_from_server);
			}
			previous_open_interest = data_builder.has_open_interest();
		}
		if (data_builder.connection().error_occurred()) {
			owner.display_warning(INDICATOR_LIST_RETRIEVAL_FAILURE_ERROR);
		}
	}

	private void make_indicator_lists(Vector inds_from_server) {
		Enumeration ind_iter;
		String s;
		int ind_count = inds_from_server.size();
		Hashtable valid_indicators;
		if (ind_count > 0) {
			valid_indicators = new Hashtable(inds_from_server.size());
		} else {
			valid_indicators = new Hashtable();
		}
		ordered_indicator_list = new Vector();
		tradable_specification.clear_all_indicators();
		int i;
		for (i = 0; i < inds_from_server.size(); ++i) {
			Object o = inds_from_server.elementAt(i);
			valid_indicators.put(o, new Integer(i + 1));
		}
		// User-selected indicators, in order:
		ind_iter = MA_Configuration.application_instance().indicator_order().
			elements();
		Vector special_indicators = new Vector();
		special_indicators.addElement(NO_LOWER_INDICATOR);
		special_indicators.addElement(NO_UPPER_INDICATOR);
		special_indicators.addElement(VOLUME);
		if (data_builder.has_open_interest()) {
			special_indicators.addElement(OPEN_INTEREST);
		}
		// Insert into the indicator list all "user-configured" indicators
		// that are either in the list returned by the server or are one of
		// the special strings for no upper/lower indicator, volume, or
		// open interest.
		while (ind_iter.hasMoreElements()) {
			s = (String) ind_iter.nextElement();
			if (valid_indicators.containsKey(s)) {
				// Add valid indicators (from the server's point of view)
				// to both the tradable spec. and `ordered_indicator_list'.
				tradable_specification.add_indicator(new
					MA_IndicatorSpecification(((Integer)
					valid_indicators.get(s)).intValue(), s));
				ordered_indicator_list.addElement(s);
			}
			else {
				for (i = 0; i < special_indicators.size(); ++i) {
					if (s.equals(special_indicators.elementAt(i))) {
						// Add special indicators only to
						// `ordered_indicator_list'.
						ordered_indicator_list.addElement(s);
						special_indicators.removeElement(s);
						break;
					}
				}
			}
		}
		// Insert the special indicators (no-upper indicator, ...) if
		// they aren't already there.
		for (i = 0; i < special_indicators.size(); ++i) {
			s = (String) special_indicators.elementAt(i);
			if (tradable_specification.indicator_spec_for(s) == null) {
				tradable_specification.add_special_indicator(new
					MA_IndicatorSpecification(tradable_specification.
						all_indicator_specifications().size() + 1, s));
				ordered_indicator_list.addElement(s);
			}
		}

		// Update current_lower_indicators and current_upper_indicators:
		// remove any elements that are no longer valid.
		//@@@It might be a good idea to move knowledge of current upper
		// and lower indicators into 'tradable_specification' to move
		// some of this complexity into that class.
		Vector remove_list = new Vector();
		for (ind_iter = current_lower_indicators.elements();
				ind_iter.hasMoreElements(); ) {
			s = (String) ind_iter.nextElement();
			if (! ordered_indicator_list.contains(s)) {
				remove_list.addElement(s);
			}
		}
		for (i = 0; i < remove_list.size(); ++i) {
			while (current_lower_indicators.lastIndexOf(
				remove_list.elementAt(i)) != -1) {
				current_lower_indicators.removeElement(
					remove_list.elementAt(i));
			}
		}
		remove_list.removeAllElements();
		for (ind_iter = current_upper_indicators.elements();
				ind_iter.hasMoreElements(); ) {
			s = (String) ind_iter.nextElement();
			if (! ordered_indicator_list.contains(s)) {
				remove_list.addElement(s);
			}
		}
		for (i = 0; i < remove_list.size(); ++i) {
			while (current_upper_indicators.lastIndexOf(
					remove_list.elementAt(i)) != -1) {
				current_upper_indicators.removeElement(
					remove_list.elementAt(i));
			}
		}
		owner.update_indicators();
		// If the current upper and lower indicator lists are not empty,
		// they were loaded from the saved settings.  Make sure they
		// get marked as "selected".
		tradable_specification.select_indicators(current_upper_indicators);
		tradable_specification.select_indicators(current_lower_indicators);
	}

	// Set replace_indicators to its opposite state.
	protected void toggle_indicator_replacement() {
		replace_indicators = ! replace_indicators;
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	private void handle_nonexistent_sybmol(String symbol) {
		owner.handle_nonexistent_sybmol(symbol);
	}

	// Request and return the main (date/time,open,high,...) tradable data
	// set from the server.
	// Precondition: last_data_request_succeeded
	// Precondition: data_requester != null
	// Postcondition: implies(last_data_request_succeeded, result != null)
	private DrawableDataSet main_tradable_data() {
		DrawableDataSet result = null;
		assert last_data_request_succeeded: PRECONDITION;
		assert data_requester != null: PRECONDITION;
		try {
			data_requester.execute_tradable_request();
			if (! data_requester.request_failed()) {
				result = (DrawableDataSet) data_requester.tradable_result();
			} else {
				handle_main_data_request_error();
				last_data_request_succeeded = false;
			}
		} catch (Exception e) {
			facilities.fatal(SERVER_REQUEST_FAILURE_ERROR, e);
		}
		assert implies(last_data_request_succeeded, result != null):
			POSTCONDITION;
		return result;
	}

	// Request and return the "upper indicator" data sets from the server as
	// a list of "Pair"s, where the first member of the pair is the
	// indicator name and the second member of the pair is the data set.
	// Precondition: last_data_request_succeeded
	// Precondition: data_requester != null
	// Postcondition: result != null
	// Postcondition: implies(last_data_request_succeeded,
	//                   current_upper_indicators.size() == result.size())
	private List upper_indicator_data() {
		assert last_data_request_succeeded: PRECONDITION;
		assert data_requester != null: PRECONDITION;
		List result = new LinkedList();
		int count;
		String current_indicator;

		if (! current_upper_indicators.isEmpty()) {
			count = current_upper_indicators.size();
			for (int i = 0; last_data_request_succeeded && i < count; ++i) {
				current_indicator = (String)
					current_upper_indicators.elementAt(i);
				try {
					data_requester.execute_indicator_request(
						indicator_id_for(current_indicator));
					if (! data_requester.request_failed()) {
						result.add(new Pair(current_indicator, (DrawableDataSet)
							data_requester.indicator_result()));
					} else {
						last_data_request_succeeded = false;
						owner.display_warning(
							INDICATOR_DATA_RETRIEVAL_FAILURE_ERROR +
							current_indicator);
					}
				} catch (Exception e) {
					facilities.fatal(INDICATOR_DATA_RETRIEVAL_FAILURE_ERROR +
						current_indicator , e);
				}
			}
		}
		assert result != null: POSTCONDITION;
		assert implies(last_data_request_succeeded,
			current_upper_indicators.size() == result.size()): POSTCONDITION;
		return result;
	}

	// Request and return the "lower indicator" data sets from the server as
	// a list of "Pair"s, where the first member of the pair is the
	// indicator name and the second member of the pair is the data set.
	// Precondition: last_data_request_succeeded
	// Precondition: data_requester != null
	// Postcondition: result != null
	// Postcondition: implies(last_data_request_succeeded,
	//                current_lower_indicators.size() == result.size())
	private List lower_indicator_data() {
		assert last_data_request_succeeded: PRECONDITION;
		assert data_requester != null: PRECONDITION;
		List result = new LinkedList();
		int count;
		String current_indicator;

		if (! current_lower_indicators.isEmpty()) {
			count = current_lower_indicators.size();
			for (int i = 0; last_data_request_succeeded && i < count; ++i) {
				current_indicator = (String)
					current_lower_indicators.elementAt(i);
				if (current_indicator.equals(VOLUME)) {
					// (Nothing to retrieve from server)
					result.add(new Pair(current_indicator, (DrawableDataSet)
						data_requester.volume_result()));
				} else if (current_indicator.equals(OPEN_INTEREST)) {
					// (Nothing to retrieve from server)
					result.add(new Pair(current_indicator, (DrawableDataSet)
						data_requester.open_interest_result()));
				} else {
					try {
						data_requester.execute_indicator_request(
							indicator_id_for(current_indicator));
						if (! data_requester.request_failed()) {
							result.add(new Pair(current_indicator,
								(DrawableDataSet)
								data_requester.indicator_result()));
						} else {
							last_data_request_succeeded = false;
							owner.display_warning(
								INDICATOR_DATA_RETRIEVAL_FAILURE_ERROR +
								current_indicator);
						}
					} catch (Exception e) {
						facilities.fatal(EXCEPTION_ERROR, e);
					}
				}
			}
		}
		assert result != null: POSTCONDITION;
		assert implies(last_data_request_succeeded,
			current_lower_indicators.size() == result.size()): POSTCONDITION;
		return result;
	}

	// Update `owner's main data set to `d' and perform related state changes.
	// Precondition: d != null
	// Precondition: data_requester != null
	public void update_main_dataset(DrawableDataSet d) {
		assert d != null: PRECONDITION;
		assert data_requester != null: PRECONDITION;
		//Ensure that all graph's data sets are removed.
		owner.main_pane().clear_main_graph();
		owner.main_pane().clear_indicator_graph();
		latest_date_time = data_requester.latest_date_time();
		link_with_axis(d, null);
		owner.main_pane().add_main_data_set(d);
		tradable_specification.set_data(d);
	}

	// Update `owner's indicator data sets - upper indicators if `upper',
	// otherwise, lower indicators - to `datasets' and perform related
	// state changes.
	// Precondition: datasets != null
	public void update_indicator_datasets(List datasets, boolean upper) {
		assert datasets != null: PRECONDITION;
		MA_Configuration conf = MA_Configuration.application_instance();
		Iterator i = datasets.iterator();
		Pair p;
		String ind_name;
		DrawableDataSet dataset;
		while (i.hasNext()) {
			p = (Pair) i.next();
			ind_name = (String) p.first();
			dataset = (DrawableDataSet) p.second();
			dataset.setColor(conf.indicator_color(ind_name, upper));
			link_with_axis(dataset, ind_name);
			tradable_specification.set_indicator_data(dataset, ind_name);
			if (upper) {
				dataset.set_dates_needed(false);
				owner.main_pane().add_main_data_set(dataset);
			} else {
				owner.add_indicator_lines(dataset, ind_name);
				owner.main_pane().add_indicator_data_set(dataset);
			}
		}
	}

	// Ensure that the indicator list is up-to-date with respect to
	// the current tradable.
	// Precondition: last_data_request_succeeded
	// Precondition: data_requester != null
	private void update_indicator_list() {
		assert last_data_request_succeeded: PRECONDITION;
		assert data_requester != null: PRECONDITION;
		try {
			data_requester.execute_indicator_list_request();
			if (! data_requester.request_failed()) {
				// Force re-creation of indicator lists with the result
				// of the above request.
				new_indicators = true;
				rebuild_indicators_if_needed();
			} else {
				last_data_request_succeeded = false;
				owner.display_warning(INDICATOR_LIST_RETRIEVAL_FAILURE_ERROR);
			}
		} catch (Exception e) {
		}
	}

// Implementation - utilities

	// Handle main tradable data request error - report the error and take
	// any necessary actions.
	// Precondition: data_requester != null
	private void handle_main_data_request_error() {
		assert data_requester != null: PRECONDITION;

		String suffix = data_requester.request_failure_message().length() != 0?
			": " + data_requester.request_failure_message(): "";
		if (request_result_id() == Invalid_symbol) {
			handle_nonexistent_sybmol(data_requester.current_symbol());
		} else if (request_result_id() == Invalid_period_type) {
			facilities.handle_invalid_period_type(
				data_requester.current_symbol());
			individual_period_type_sets = true;
		} else {
			owner.display_warning(DATA_RETRIEVAL_FAILURE_ERROR +
				data_requester.current_symbol() + suffix);
		}
	}

// Implementation - attributes

	private DataSetBuilder data_builder;

	// The latest date-time in the data set associated with this chart
	Calendar latest_date_time;

	// Valid trading period types
	private Vector period_types;	// Vector of String

	// Has data_requester.execute_indicator_list_request been called since
	// the last call to `rebuild_indicators_if_needed'?
	private boolean new_indicators = true;

	// Indicators in user-specified order - includes no-upper/lower,
	// volume, and open-interest indicators
	private static Vector ordered_indicator_list;	// Vector of String

	// Has the period type just been changed?
	private boolean period_type_change;

	// Upper indicators currently selected for display
	private Vector current_upper_indicators;

	// Lower indicators currently selected for display
	private Vector current_lower_indicators;

	// Should new indicator selections replace, rather than be added to,
	// existing indicators?
	boolean replace_indicators;

	// Is the set of period types for each tradable to be handled
	// individually (because the sets differ between tradables)?
	boolean individual_period_type_sets;

	IndicatorGroups indicator_groups;

	// Saved result of data_builder.last_indicator_list(), used by
	// `indicators' to compare old list with new list
	private Vector old_indicators_from_server = null;

	// Did the previously retrieved data from the server contain an
	// open interest field?
	private boolean previous_open_interest;

	private ChartFacilities facilities;

	private MA_ChartableSpecification specification;

	private MA_TradableSpecification tradable_specification;

	// The chart that "owns" this data manager
	private Chart owner;

	SynchronizedDataRequester data_requester = null;

	private boolean last_data_request_succeeded;

// Implementation - constants

	private static final String NO_UPPER_INDICATOR = "No upper indicator";

	private static final String NO_LOWER_INDICATOR = "No lower indicator";

	private static final String VOLUME = "Volume";

	private static final String OPEN_INTEREST = "Open interest";


	private static final String TRADABLE_LIST_EMPTY_ERROR =
		"Server's list of tradables is empty.";

	private static final String IO_EXCEPTION_ERROR = "IO exception occurred: ";

	private static final String ABORTING_SUFFIX = " - aborting";

	private static final String INDICATOR_LIST_RETRIEVAL_FAILURE_ERROR =
		"Error occurred retrieving indicator list.";

	private static final String DATA_RETRIEVAL_FAILURE_ERROR =
		"Error occurred retrieving data for ";

	private static final String SERVER_REQUEST_FAILURE_ERROR =
		"Request to server failed: ";

	private static final String INDICATOR_DATA_RETRIEVAL_FAILURE_ERROR =
		"Indicator data request failed for ";

	private static final String EXCEPTION_ERROR = "Exception occurred";
}
