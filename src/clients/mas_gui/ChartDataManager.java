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
public class ChartDataManager implements NetworkProtocol, AssertionConstants {

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
				facilities.abort("Server's list of tradables is empty.",
					null);
			}
		} catch (IOException e) {
			System.err.println("IO exception occurred: " + e + " - aborting");
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
			System.err.println("IO exception occurred, bye ...");
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
System.out.println("iif - ind name: " + ind_name);
System.out.println("iif - trspec: " + tradable_specification);
		rebuild_indicators_if_needed();
System.out.println("1");
		IndicatorSpecification ispec =
			tradable_specification.indicator_spec_for(ind_name);
System.out.println("2");
		if (ispec != null) {
			result = ispec.identifier();
System.out.println("3");
		}
else {
System.out.println("4");
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
		return request_result_id;
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
			String errmsg = "IO exception occurred: " + e + " - aborting";
			owner.display_warning(errmsg);
			System.err.println(errmsg);
			e.printStackTrace();
			quit(-1);
		}
	}

	// Send a data request for the specified tradable.
	public void send_data_request(String tradable) {
		DrawableDataSet dataset, main_dataset = null;
		data_requester = new SynchronizedDataRequester(data_builder, tradable,
			current_period_type());
		MA_Configuration conf = MA_Configuration.application_instance();

		owner.turn_off_refresh();	// Prevent auto-refresh conflicts.
		int count;
		String current_indicator;
		try {
		if (period_type_change || ! tradable.equals(current_tradable())) {
			// Redraw the data.
			if (individual_period_type_sets &&
					! tradable.equals(current_tradable())) {
				facilities.reset_period_types(tradable, false);
			}
			GUI_Utilities.busy_cursor(true, owner);
			try {
				data_requester.execute_tradable_request();
				if (! data_requester.request_failed()) {
					main_dataset = (DrawableDataSet)
						data_requester.tradable_result();
					// Ensure that the indicator list is up-to-date with
					// respect to `tradable'.
					data_requester.execute_indicator_list_request();
					// Force re-creation of indicator lists with the result
					// of the above request.
					new_indicators = true;
					rebuild_indicators_if_needed();
				} else {
					request_result_id = data_requester.request_result_id();
					new ErrorBox("Warning", "Error occurred retrieving " +
						"data for " + tradable, owner);
					// Handle request error.
					if (request_result_id == Invalid_symbol) {
						handle_nonexistent_sybmol(tradable);
					} else if (request_result_id == Invalid_period_type) {
						facilities.handle_invalid_period_type(tradable);
						individual_period_type_sets = true;
					} else if (request_result_id == Warning ||
							request_result_id == Error) {
						owner.display_warning("Error occurred retrieving " +
							"data for " + tradable);
					}
					GUI_Utilities.busy_cursor(false, owner);
					return;
				}
			}
			catch (Exception e) {
				facilities.fatal("Request to server failed: ", e);
			}
			//Ensure that all graph's data sets are removed.
			owner.main_pane().clear_main_graph();
			owner.main_pane().clear_indicator_graph();
			latest_date_time = data_requester.latest_date_time();
			assert main_dataset != null;
			link_with_axis(main_dataset, null);
			owner.main_pane().add_main_data_set(main_dataset);
			tradable_specification.set_data(main_dataset);
			if (! current_upper_indicators.isEmpty()) {
				// Retrieve the data for the newly requested tradable for
				// the upper indicators, add it to the upper graph and
				// draw the new indicator data and the tradable data.
				count = current_upper_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_upper_indicators.elementAt(i);
					try {
						data_requester.execute_indicator_request(
							indicator_id_for(current_indicator));
					} catch (Exception e) {
						facilities.fatal("Indicator data request failed", e);
					}
					dataset = (DrawableDataSet)
						data_requester.indicator_result();
					dataset.set_dates_needed(false);
					dataset.setColor(
						conf.indicator_color(current_indicator, true));
					link_with_axis(dataset, current_indicator);
					owner.main_pane().add_main_data_set(dataset);
					tradable_specification.set_indicator_data(dataset,
						current_indicator);
				}
			}
			set_current_tradable(tradable);
			owner.set_window_title();
			if (! current_lower_indicators.isEmpty()) {
				// Retrieve the indicator data for the newly requested
				// tradable for the lower indicators and draw it.
				count = current_lower_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_lower_indicators.elementAt(i);
					if (current_lower_indicators.elementAt(i).equals(
							Volume)) {
						// (Nothing to retrieve from server)
						dataset = (DrawableDataSet)
							data_requester.volume_result();
					} else if (current_lower_indicators.elementAt(i).equals(
							Open_interest)) {
						// (Nothing to retrieve from server)
						dataset = (DrawableDataSet)
							data_requester.open_interest_result();
					} else {
						try {
						data_requester.execute_indicator_request(
							indicator_id_for(current_indicator));
						} catch (Exception e) {
							facilities.fatal("Exception occurred", e);
						}
						dataset = (DrawableDataSet)
							data_requester.indicator_result();
					}
					if (dataset != null) {
						dataset.setColor(conf.indicator_color(
							current_indicator, false));
						link_with_axis(dataset, current_indicator);
						owner.add_indicator_lines(dataset, current_indicator);
						owner.main_pane().add_indicator_data_set(dataset);
						tradable_specification.set_indicator_data(dataset,
							current_indicator);
					}
				}
			}
			owner.main_pane().repaint_graphs();
			GUI_Utilities.busy_cursor(false, owner);
			period_type_change = false;
		}
		} finally {
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
			owner.display_warning("Error occurred retrieving indicator list.");
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
		special_indicators.addElement(No_lower_indicator);
		special_indicators.addElement(No_upper_indicator);
		special_indicators.addElement(Volume);
		if (data_builder.has_open_interest()) {
			special_indicators.addElement(Open_interest);
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

	private final String No_upper_indicator = "No upper indicator";

	private final String No_lower_indicator = "No lower indicator";

	private final String Volume = "Volume";

	private final String Open_interest = "Open interest";

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

	private int request_result_id;

	SynchronizedDataRequester data_requester = null;
}
