/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;

/** Market analysis GUI chart facilities */
public class ChartFacilities {

	public ChartFacilities(ChartInterface c) {
		chart = c;
	}

// Implementation

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	public void handle_invalid_period_type(String tradable) {
		reset_period_types(tradable, true);
		if (chart.period_types().size() > 0) {
			chart.reinitialize_current_period_type();
			chart.send_data_request(tradable);
		} else {
			chart.display_warning("No valid period types for " + tradable);
		}
	}

	// Reset `chart.period_types' and rebuild the period-types menu item based
	// on `tradable'.
	public void reset_period_types(String tradable,
			boolean force_current_type_change) {
		boolean change_current_type = true;
		chart.send_period_types_request(tradable);
		if (chart.period_types().size() > 0) {
			if (! force_current_type_change) {
				// Set change_current_type to false if
				// `current_period_type' is in `period_types'.
				Enumeration types = chart.period_types().elements();
				while (types.hasMoreElements()) {
					String s = (String) types.nextElement();
					if (chart.current_period_type().equals(s)) {
						change_current_type = false;
						break;
					}
				}
			}
			if (change_current_type) {
				chart.reinitialize_current_period_type();
			}
		}
		chart.reset_period_types_menu();
	}

	// Print fatal error and exit after saving settings.
	public void fatal(String s, Exception e) {
		System.err.println("Fatal error: " + s);
		if (chart.current_tradable() != null) {
			System.err.println("Current symbol is " + chart.current_tradable());
		}
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		chart.quit(-1);
	}

	// Same as `fatal' except `save_settings' is not called.
	public void abort(String s, Exception e) {
		System.err.println("Fatal error: " + s);
		if (chart.current_tradable() != null) {
			System.err.println("Current symbol is " + chart.current_tradable());
		}
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		chart.log_out_and_exit(-1);
		// If still running, ignore-termination flag is on -
		// Display the error message.
		chart.display_warning(s != null? s: "Error encountered");
	}

	private ChartInterface chart;
}
