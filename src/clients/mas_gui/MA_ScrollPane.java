/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.*;
import graph.*;
import support.Configuration;
import java.util.Vector;
import java.util.Properties;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import common.*;

/** Scroll pane that holds the Market Analysis graph and buttons */
public class MA_ScrollPane extends ScrollPane implements NetworkProtocol
{
	static Properties print_properties;
	static { print_properties = new Properties(); }

	public MA_ScrollPane(Vector period_types, int scrollbarDisplayPolicy,
				Chart parent_chart, Properties print_props)
	{
		super(scrollbarDisplayPolicy);

		if (print_props != null) print_properties = print_props;
		Configuration config = Configuration.instance();
		chart = parent_chart;
		_main_graph = new InteractiveGraph();
		_indicator_graph = new InteractiveGraph();
		GridBagLayout gblayout = new GridBagLayout();
		GridBagConstraints gbconstraints = new GridBagConstraints();
		period_type_choice = new Choice();
		initialize_period_type_choice(period_types);

		main_panel = new Panel(new BorderLayout());
		add(main_panel, "Center");
		graph_panel = new Panel(gblayout);
		main_panel.add (graph_panel, "Center");
		_left_button_panel = new Panel(new BorderLayout());
		Panel top_button_panel = new Panel(new GridLayout(3, 2));
		Panel bottom_button_panel = new Panel(new GridLayout(3, 2));
		main_panel.add (_left_button_panel, "West");
		_left_button_panel.add (top_button_panel, "North");
		_left_button_panel.add (bottom_button_panel, "South");
		//top_button_panel.add(new Button("Dummy1"));
		top_button_panel.add(period_type_choice);
		//bottom_button_panel.add(new Button("Dummy2"));

		// Set GridBagLayout constraints such that the main graph is at
		// the top and takes about 2/3 of available height and the
		// indicator graph is below the main graph and takes the remaining
		// 1/3 of the height and both graph panels grow/shrink when the
		// window is resized.
		gbconstraints.gridx = 0; gbconstraints.gridy = 0;
		gbconstraints.gridwidth = 9; gbconstraints.gridheight = 6;
		gbconstraints.weightx = 1; gbconstraints.weighty = 1;
		gbconstraints.fill = GridBagConstraints.BOTH;
		gblayout.setConstraints(_main_graph, gbconstraints);
		graph_panel.add(_main_graph);
		gbconstraints.gridx = 0; gbconstraints.gridy = 6;
		gbconstraints.gridwidth = 9; gbconstraints.gridheight = 3;
		gbconstraints.weightx = 1; gbconstraints.weighty = 1;
		gbconstraints.fill = GridBagConstraints.BOTH;
		gblayout.setConstraints(_indicator_graph, gbconstraints);
		graph_panel.add(_indicator_graph);
		_main_graph.set_framecolor(new Color(0,0,0));
		_main_graph.set_borderTop(0);
		_main_graph.set_borderBottom(1);
		_main_graph.set_borderLeft(0);
		_main_graph.set_borderRight(1);
		_main_graph.setGraphBackground(config.background_color());
		_main_graph.setSize(400, 310);

		_indicator_graph.set_framecolor(new Color(0,0,0));
		_indicator_graph.set_borderTop(0);
		_indicator_graph.set_borderBottom(1);
		_indicator_graph.set_borderLeft(0);
		_indicator_graph.set_borderRight(1);
		_indicator_graph.setGraphBackground(config.background_color());
		_indicator_graph.setSize(400, 150);
	}

	// The main graph - where the principal market data is displayed
	public Graph main_graph() {
		return _main_graph;
	}

	// The indicator graph - where the indicator data is displayed
	public Graph indicator_graph() {
		return _indicator_graph;
	}

	// Current selected period type
	public String current_period_type() {
		return period_type_choice.getSelectedItem();
	}

	// Delete all data from the main graph.
	public void clear_main_graph() {
		_main_graph.detachDataSets();
		main_graph_changed = true;
	}

	// Delete all data from the indicator graph.
	public void clear_indicator_graph() {
		_indicator_graph.detachDataSets();
		indicator_graph_changed = true;
	}

	// Add a data set to the main graph.
	public void add_main_data_set(DataSet d) {
		_main_graph.attachDataSet(d);
		main_graph_changed = true;
	}

	// Add a data set to the indicator graph.
	public void add_indicator_data_set(DataSet d) {
		_indicator_graph.attachDataSet(d);
		indicator_graph_changed = true;
	}

	// Repaint the graphs.
	public void repaint_graphs() {
		// The order matters - first repaint the main graph, then
		// the indicator graph.
		if (main_graph_changed) {
			_main_graph.repaint();
			main_graph_changed = false;
		}
		if (indicator_graph_changed) {
			_indicator_graph.repaint();
			indicator_graph_changed = false;
		}
	}

	//If all is true, loop through all selections in chart, asking it to
	//grab the data and print each one.
	public void print(boolean all) {
		Toolkit tk = getToolkit();
		PrintJob pj = tk.getPrintJob(chart,
			all? "All charts": chart.current_market, print_properties);
		if (pj != null) {
			if (all) {
				Vector selections = chart.market_selection.selections();
				for (int i = 0; i < selections.size(); ++i) {
					chart.request_data((String) selections.elementAt(i));
					if (chart.request_result() != Invalid_symbol) {
						print_current_chart(pj);
					}
				}
			}
			else {
				print_current_chart(pj);
			}
			pj.end();
		}
	}

	private void print_current_chart(PrintJob pj) {
			Graphics page = pj.getGraphics();
			Dimension size = graph_panel.getSize();
			Dimension pagesize = pj.getPageDimension();
			_main_graph.set_symbol(chart.current_market.toUpperCase());
			if (size.width <= pagesize.width) {
				// Center the output on the page.
				page.translate((pagesize.width - size.width)/2,
				   (pagesize.height - size.height)/2);
			} else {
				// The graph size is wider than a page, so print first
				// the left side, then the right side.  Assumption - it is
				// not larger than two pages.
				page.translate(15,
				   (pagesize.height - size.height)/2);
				graph_panel.printAll(page);
				page.dispose();
				page = pj.getGraphics();
				page.translate(pagesize.width - size.width - 13,
				   (pagesize.height - size.height)/2);
			}
			graph_panel.printAll(page);
			page.dispose();
			_main_graph.set_symbol(null);
	}

	// The left button panel component
	public Panel left_button_panel() { return _left_button_panel; }

// Implementation

	void initialize_period_type_choice(Vector period_types) {
		for (int i = 0; i < period_types.size(); ++i) {
			period_type_choice.add((String) period_types.elementAt(i));
		}
		period_type_choice.addItemListener(new ItemListener() {
			public void itemStateChanged(ItemEvent e) {
				String per_type;
				per_type = (String) e.getItem();
				if (! per_type.equals(_last_period_type)) {
					chart.notify_period_type_changed();
				}
				_last_period_type = per_type;
			}
		});
	}

	private InteractiveGraph _main_graph;
	private InteractiveGraph _indicator_graph;
	private Panel main_panel;
	private Panel graph_panel;
	private Panel _left_button_panel;
	// Did _main_graph change since it was last repainted?
	boolean main_graph_changed;
	// Did _indicator_graph change since it was last repainted?
	boolean indicator_graph_changed;
	Choice period_type_choice;
	Chart chart;
	String _last_period_type;
}
