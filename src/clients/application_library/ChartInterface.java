/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;

/** Market analysis GUI chart abstraction */
public interface ChartInterface {

	// Startup options
	public StartupOptions options();

	// List of all tradables in the server's database
	public Vector tradables();

	// indicators
	// Postcondition: result != null
	public Hashtable indicators();

	// Indicators in user-specified order
	public Vector ordered_indicators();

	// Result of last request to the server
	public int request_result_id();

	// Update the period-types menu to synchronize with `period_types'.
	public void reset_period_types_menu();

	// Display the specified warning message.
	public void display_warning(String msg);

	/** Log out of all sessions and exit. */
	public void log_out_and_exit(int status);

	/** Quit gracefully, sending a logout request for each open window. */
	public void quit(int status);

	// Current selected tradable
	public String current_tradable();

	// Current selected period_type
	public String current_period_type();

	// Valid trading period types for the current tradable
	public Vector period_types();

	// Request a new set of period types for tradable and, if the request
	// was successful, set `period_types' to the result.
	public void send_period_types_request(String tradable);

	// Reset the `current_period_type' to a reasonable value.
	public void reinitialize_current_period_type();

	// Send a data request for the specified tradable.
	public void send_data_request(String tradable);

}
