/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.event.*;
import java.util.*;
import support.*;
import common.NetworkProtocol;
import application_support.*;
import application_library.*;
import graph_library.DataSet;
import graph.DrawableDataSet;

/** Listener for indicator selection */
public class IndicatorListener implements ActionListener, NetworkProtocol {
	public IndicatorListener(Chart c) {
		chart = c;
		chart_manager = chart.data_manager();
		data_builder = (DataSetBuilder) chart.data_builder();
		main_pane = chart.main_pane();
	}

	public void actionPerformed(java.awt.event.ActionEvent e) {
		retrieve_and_load_data(e);
	}

	private void retrieve_and_load_data(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		DrawableDataSet dataset = null;
		boolean retrieve_failed = false;
		try {
			if (chart.current_tradable() == null || no_change(selection)) {
				// No tradable is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(chart.No_upper_indicator) ||
					selection.equals(chart.No_lower_indicator) ||
					selection.equals(chart.Volume) ||
					selection.equals(chart.Open_interest))) {

				SynchronizedDataRequester data_requester =
					new SynchronizedDataRequester(data_builder,
					chart.current_tradable(), chart.current_period_type());
				GUI_Utilities.busy_cursor(true, chart);
				data_requester.execute_indicator_request(
					chart.indicator_id_for(selection));
				GUI_Utilities.busy_cursor(false, chart);
				if (data_requester.request_failed()) {
					new ErrorBox("Warning", "Error occurred retrieving " +
						"data for " + selection, chart);
					retrieve_failed = true;
				} else {
					dataset = (DrawableDataSet)
						data_requester.indicator_result();
				}
			}
		}
		catch (Exception ex) {
			chart.fatal("Exception occurred: ", ex);
		}
		if (! retrieve_failed) {
			process_data(dataset, selection);
		}
	}

	private void process_data(DrawableDataSet dataset, String selection) {
		DrawableDataSet maindata = chart_manager.last_tradable_result();
		MA_Configuration conf = MA_Configuration.application_instance();
		// Set graph data according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		if (MA_Configuration.application_instance().
				upper_indicators().containsKey(selection)) {
			if (! chart_manager.current_upper_indicators().isEmpty() &&
					chart_manager.replace_indicators()) {
				// Remove the old indicator data from the graph (and the
				// market data).
				main_pane.clear_main_graph();
				// Re-attach the market data.
				chart_manager.link_with_axis(maindata, null);
				main_pane.add_main_data_set(maindata);
				chart_manager.unselect_upper_indicators();
				chart_manager.current_upper_indicators().removeAllElements();
			}
			chart_manager.current_upper_indicators().addElement(selection);
			chart_manager.tradable_specification().select_indicator(selection);
			dataset.set_dates_needed(false);
			dataset.setColor(conf.indicator_color(selection, true));
			chart_manager.link_with_axis(dataset, selection);
			main_pane.add_main_data_set(dataset);
			chart_manager.tradable_specification().set_indicator_data(dataset,
				selection);
		} else if (selection.equals(chart.No_upper_indicator)) {
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
			// Re-attach the old market data without the indicator data.
			chart_manager.link_with_axis(maindata, null);
			main_pane.add_main_data_set(maindata);
			chart_manager.unselect_upper_indicators();
			chart_manager.current_upper_indicators().removeAllElements();
		} else if (selection.equals(chart.No_lower_indicator)) {
			main_pane.clear_indicator_graph();
			chart_manager.unselect_lower_indicators();
			chart_manager.current_lower_indicators().removeAllElements();
			chart.set_window_title();
		} else {
			if (selection.equals(chart.Volume)) {
				dataset = (DrawableDataSet) chart_manager.last_volume_result();
System.out.println("IL - process_data - last volume obtained - size: " +
dataset.size());	//@@@Don't remove this until this case has been tested.
			} else if (selection.equals(chart.Open_interest)) {
				dataset = (DrawableDataSet)
					chart_manager.last_open_interest_result();
System.out.println("IL - process_data - last open-interest obtained - size: " +
dataset.size());	//@@@Don't remove this until this case has been tested.
			}
			if (chart_manager.replace_indicators()) {
				main_pane.clear_indicator_graph();
				chart_manager.unselect_lower_indicators();
				chart_manager.current_lower_indicators().removeAllElements();
			}
			dataset.setColor(conf.indicator_color(selection, false));
			chart_manager.link_with_axis(dataset, selection);
			chart_manager.current_lower_indicators().addElement(selection);
			chart_manager.tradable_specification().select_indicator(selection);
			chart.set_window_title();
			chart.add_indicator_lines(dataset, selection);
			main_pane.add_indicator_data_set(dataset);
			chart_manager.tradable_specification().set_indicator_data(dataset,
				selection);
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

		if (! chart_manager.replace_indicators()) {
			if (vector_has(chart_manager.current_upper_indicators(), s) ||
					vector_has(chart_manager.current_lower_indicators(), s)) {
				result = true;
			}
		} else {
			if ((vector_has(chart_manager.current_upper_indicators(), s) &&
					chart_manager.current_upper_indicators().size() == 1) ||
					(vector_has(chart_manager.current_lower_indicators(), s) &&
					chart_manager.current_lower_indicators().size() == 1)) {
				result = true;
			}
		}

		return result;
	}

	private Chart chart;
	private ChartDataManager chart_manager;
	private DataSetBuilder data_builder;
	private MA_ScrollPane main_pane;
}
