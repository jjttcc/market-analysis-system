import java.util.*;
import support.*;
import graph.DataSet;

/** Listener for indicator selection */
public class IndicatorListener implements java.awt.event.ActionListener {
	public IndicatorListener(Chart c) {
		chart = c;
		data_builder = chart.data_builder;
		main_pane = chart.main_pane;
	}

	public void actionPerformed(java.awt.event.ActionEvent e) {
		String selection = e.getActionCommand();
		DataSet dataset, main_dataset;
		Configuration conf = Configuration.instance();
		try {
			String market = chart.current_market;
			if (market == null ||
				vector_has(chart.current_upper_indicators, selection) ||
				vector_has(chart.current_lower_indicators, selection)) {
				// If no market is selected or the selection hasn't changed,
				// there is nothing to display.
				return;
			}
			if (! (selection.equals(chart.No_upper_indicator) ||
					selection.equals(chart.No_lower_indicator) ||
					selection.equals(chart.Volume))) {
				GUI_Utilities.busy_cursor(true, chart);
				data_builder.send_indicator_data_request(
					((Integer) chart.indicators().get(selection)).intValue(),
					market, chart.current_period_type);
				GUI_Utilities.busy_cursor(false, chart);
			}
		}
		catch (Exception ex) {
			System.err.println("Exception occurred: " + ex + ", bye ...");
			ex.printStackTrace();
			chart.quit(-1);
		}
		// Set graph data according to whether the selected indicator is
		// configured to go in the upper (main) or lower (indicator) graph.
		if (Configuration.instance().upper_indicators().containsKey(selection))
		{
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
		}
		else if (selection.equals(chart.No_upper_indicator)) {
			// Remove the old indicator and market data from the graph.
			main_pane.clear_main_graph();
			// Re-attach the market data without the indicator data.
			chart.link_with_axis(data_builder.last_market_data(), null);
			main_pane.add_main_data_set(data_builder.last_market_data());
			chart.current_upper_indicators.removeAllElements();
		}
		else if (selection.equals(chart.No_lower_indicator)) {
			main_pane.clear_indicator_graph();
			chart.current_lower_indicators.removeAllElements();
			chart.set_window_title();
		}
		else {
			if (selection.equals(chart.Volume)) {
				dataset = data_builder.last_volume();
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

	private boolean vector_has(Vector v, String s) {
		return Utilities.vector_has(v, s);
	}

	private Chart chart;
	private DataSetBuilder data_builder;
	private MA_ScrollPane main_pane;
}
