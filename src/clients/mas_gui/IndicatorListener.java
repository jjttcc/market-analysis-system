/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.event.*;
import java.util.*;
import support.*;
import common.NetworkProtocol;
import graph.DataSet;

/** Listener for indicator selection */
public class IndicatorListener implements ActionListener, NetworkProtocol {
	public IndicatorListener(Chart c) {
		chart = c;
		data_builder = chart.data_builder;
		main_pane = chart.main_pane;
	}

	public void actionPerformed(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		DataSet dataset, main_dataset;
		boolean retrieve_failied = false;
		Configuration conf = Configuration.instance();
		try {
			String tradable = chart.current_tradable;
			if (tradable == null || no_change(selection)) {
				// If no tradable is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(chart.No_upper_indicator) ||
					selection.equals(chart.No_lower_indicator) ||
					selection.equals(chart.Volume) ||
					selection.equals(chart.Open_interest))) {
				GUI_Utilities.busy_cursor(true, chart);
				data_builder.send_indicator_data_request(
					((Integer) chart.indicators().get(selection)).intValue(),
					tradable, chart.current_period_type);
				GUI_Utilities.busy_cursor(false, chart);
				if (data_builder.request_result_id() == Warning ||
						data_builder.request_result_id() == Error) {
					new ErrorBox("Warning", "Error occurred retrieving " +
						"data for " + selection, chart);
					retrieve_failied = true;
				}
			}
		}
		catch (Exception ex) {
			chart.fatal("Exception occurred: ", ex);
		}
		if (retrieve_failied) {
			// null statement
		}
		// Set graph data according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		else if (Configuration.instance().upper_indicators().containsKey(
				selection)) {
			main_dataset = data_builder.last_market_data();
			if (! chart.current_upper_indicators.isEmpty() &&
					chart.replace_indicators) {
				// Remove the old indicator data from the graph (and the
				// market data).
				main_pane.clear_main_graph();
				// Re-attach the market data.
				chart.link_with_axis(main_dataset, null);
				main_pane.add_main_data_set(main_dataset);
				chart.current_upper_indicators.removeAllElements();
			}
			chart.current_upper_indicators.addElement(selection);
			dataset = data_builder.last_indicator_data();
			dataset.set_dates_needed(false);
			dataset.set_color(conf.indicator_color(selection, true));
			chart.link_with_axis(dataset, selection);
			main_pane.add_main_data_set(dataset);
		} else if (selection.equals(chart.No_upper_indicator)) {
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
			// Re-attach the market data without the indicator data.
			chart.link_with_axis(data_builder.last_market_data(), null);
			main_pane.add_main_data_set(data_builder.last_market_data());
			chart.current_upper_indicators.removeAllElements();
		} else if (selection.equals(chart.No_lower_indicator)) {
			main_pane.clear_indicator_graph();
			chart.current_lower_indicators.removeAllElements();
			chart.set_window_title();
		} else {
			if (selection.equals(chart.Volume)) {
				dataset = data_builder.last_volume();
			} else if (selection.equals(chart.Open_interest)) {
				dataset = data_builder.last_open_interest();
			} else {
				dataset = data_builder.last_indicator_data();
			}
			if (chart.replace_indicators) {
				main_pane.clear_indicator_graph();
				chart.current_lower_indicators.removeAllElements();
			}
			dataset.set_color(conf.indicator_color(selection, false));
			chart.link_with_axis(dataset, selection);
			chart.current_lower_indicators.addElement(selection);
			chart.set_window_title();
			chart.add_indicator_lines(dataset, selection);
			main_pane.add_indicator_data_set(dataset);
		}
		main_pane.repaint_graphs();
	}

	// Does `v' contain `s' by value?
	private boolean vector_has(Vector v, String s) {
		return Utilities.vector_has(v, s);
	}

	// Is a change not needed with selection `s'?
	private boolean no_change(String s) {
		boolean result = false;

		if (! chart.replace_indicators) {
			if (vector_has(chart.current_upper_indicators, s) ||
					vector_has(chart.current_lower_indicators, s)) {
				result = true;
			}
		} else {
			if ((vector_has(chart.current_upper_indicators, s) &&
					chart.current_upper_indicators.size() == 1) ||
					(vector_has(chart.current_lower_indicators, s) &&
					chart.current_lower_indicators.size() == 1)) {
				result = true;
			}
		}

		return result;
	}

	private Chart chart;
	private DataSetBuilder data_builder;
	private MA_ScrollPane main_pane;
}
