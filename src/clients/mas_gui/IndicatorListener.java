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
		synchronized (data_builder) {
			retrieve_and_load_data(e);
		}
	}

//!!!: (obsolete)
	private void old_remove_retrieve_and_load_data(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		ChartableSpecification chartspec = chart.specification();
		TradableSpecification trspec =
			chartspec.specification_for(chart.current_tradable());
		DrawableDataSet dataset = null;
		boolean retrieve_failed = false;
		try {
String tradable = chart.current_tradable();
			if (trspec == null || no_change(selection)) {
				// No tradable is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(chart.No_upper_indicator) ||
					selection.equals(chart.No_lower_indicator) ||
					selection.equals(chart.Volume) ||
					selection.equals(chart.Open_interest))) {
				GUI_Utilities.busy_cursor(true, chart);
//!!!: (This procedure is obsolete.)
data_builder.send_indicator_data_request(
	chart.indicator_id_for(selection), tradable,
	chart.current_period_type());
				GUI_Utilities.busy_cursor(false, chart);
				if (data_builder.request_result_id() == Warning ||
						data_builder.request_result_id() == Error) {
					new ErrorBox("Warning", "Error occurred retrieving " +
						"data for " + selection, chart);
					retrieve_failed = true;
				} else {
					dataset = (DrawableDataSet)
						data_builder.last_indicator_data();
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
System.out.println("the NEW ret and LD - dataset size: " + dataset.size());
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
		DrawableDataSet maindata = main_pane.main_graph().first_data_set();
		MA_Configuration conf = MA_Configuration.application_instance();
		// Set graph data according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		if (MA_Configuration.application_instance().
				upper_indicators().containsKey(selection)) {
System.out.println("lmd type: " +
data_builder.last_market_data().getClass().getName());
//!!!: main_dataset = (DrawableDataSet) data_builder.last_market_data();
			if (! chart_manager.current_upper_indicators().isEmpty() &&
					chart_manager.replace_indicators()) {
				// Remove the old indicator data from the graph (and the
				// market data).
//!!!! Refactor into one or more procedures in Chart and call them here:
				main_pane.clear_main_graph();
				// Re-attach the market data.
				chart_manager.link_with_axis(maindata, null);
				main_pane.add_main_data_set(maindata);
//!!!I believe this is not needed because its main data is up to date,
//!!!but verify that this is so:
//chart.tradable_specification.set_data(maindata);
				chart_manager.unselect_upper_indicators();
				chart_manager.current_upper_indicators().removeAllElements();
// End refactor
			}
//!!!! Refactor into one or more procedures in Chart and call them here:
			chart_manager.current_upper_indicators().addElement(selection);
			chart_manager.tradable_specification().select_indicator(selection);
//!!!:dataset = (DrawableDataSet) data_builder.last_indicator_data();
			dataset.set_dates_needed(false);
			dataset.setColor(conf.indicator_color(selection, true));
			chart_manager.link_with_axis(dataset, selection);
			main_pane.add_main_data_set(dataset);
			chart_manager.tradable_specification().set_indicator_data(dataset, selection);
// End refactor
		} else if (selection.equals(chart.No_upper_indicator)) {
//!!!! Refactor into one or more procedures in Chart and call them here:
//!!!!Is this really the main data?
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
/*!!!:
DrawableDataSet data = (DrawableDataSet)
data_builder.last_market_data();
*/
			// Re-attach the old market data without the indicator data.
			chart_manager.link_with_axis(maindata, null);
			main_pane.add_main_data_set(maindata);
//!!!(See note above about main data.)
//chart.tradable_specification.set_data(maindata);
			chart_manager.unselect_upper_indicators();
			chart_manager.current_upper_indicators().removeAllElements();
// End refactor
		} else if (selection.equals(chart.No_lower_indicator)) {
//!!!! Refactor into one or more procedures in Chart and call them here:
			main_pane.clear_indicator_graph();
			chart_manager.unselect_lower_indicators();
			chart_manager.current_lower_indicators().removeAllElements();
			chart.set_window_title();
// End refactor
		} else {
			if (selection.equals(chart.Volume)) {
				// !!!Need to store the 'last volume' somewhere else -
				// data_builder.last_volume will get steppend on by the
				// auto-refresh thread.
				dataset = (DrawableDataSet) data_builder.last_volume();
			} else if (selection.equals(chart.Open_interest)) {
				// !!!Need to store the 'last open interest' somewhere else -
				// data_builder.last_open_interest will get steppend on by the
				// auto-refresh thread.
				dataset = (DrawableDataSet) data_builder.last_open_interest();
			} else {
//!!!: dataset = (DrawableDataSet) data_builder.last_indicator_data();
			}
			if (chart_manager.replace_indicators()) {
//!!!! Refactor into one or more procedures in Chart and call them here:
				main_pane.clear_indicator_graph();
				chart_manager.unselect_lower_indicators();
				chart_manager.current_lower_indicators().removeAllElements();
// End refactor
			}
//!!!! Refactor into one or more procedures in Chart and call them here:
			dataset.setColor(conf.indicator_color(selection, false));
			chart_manager.link_with_axis(dataset, selection);
			chart_manager.current_lower_indicators().addElement(selection);
			chart_manager.tradable_specification().select_indicator(selection);
			chart.set_window_title();
			chart.add_indicator_lines(dataset, selection);
			main_pane.add_indicator_data_set(dataset);
			chart_manager.tradable_specification().set_indicator_data(dataset,
				selection);
// End refactor
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
