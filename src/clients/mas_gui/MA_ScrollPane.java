import java.awt.*;
import graph.*;
import java.util.Vector;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;

/** Scroll pane that holds the TA graph and buttons */
public class TA_ScrollPane extends ScrollPane
{
	public TA_ScrollPane(Vector period_types, int scrollbarDisplayPolicy,
				TA_Chart parent_chart)
	{
		super(scrollbarDisplayPolicy);

		chart = parent_chart;
		_main_graph = new TA_GraphInteractive();
		_indicator_graph = new TA_GraphInteractive();
		period_type_choice = new Choice();
		initialize_period_type_choice(period_types);

		Panel main_panel = new Panel(new BorderLayout());
		add(main_panel, "Center");
		Panel graph_panel = new Panel(new BorderLayout());
		main_panel.add (graph_panel, "Center");
		Panel button_panel = new Panel(new BorderLayout());
		Panel top_button_panel = new Panel(new GridLayout(3, 2));
		Panel bottom_button_panel = new Panel(new GridLayout(3, 2));
		main_panel.add (button_panel, "West");
		button_panel.add (top_button_panel, "North");
		button_panel.add (bottom_button_panel, "South");
		//top_button_panel.add(new Button("Dummy1"));
		top_button_panel.add(period_type_choice);
		//bottom_button_panel.add(new Button("Dummy2"));

		graph_panel.add(_main_graph, "North");
		graph_panel.add(_indicator_graph, "South");
		_main_graph.framecolor = new Color(0,0,0);
		_main_graph.borderTop = 0;
		_main_graph.borderBottom = 1;
		_main_graph.borderLeft = 0;
		_main_graph.borderRight = 1;
		_main_graph.setGraphBackground(new Color(50,50,200));
		_main_graph.setSize(300, 250);

		_indicator_graph.framecolor = new Color(0,0,0);
		_indicator_graph.borderTop = 0;
		_indicator_graph.borderBottom = 1;
		_indicator_graph.borderLeft = 0;
		_indicator_graph.borderRight = 1;
		_indicator_graph.setGraphBackground(new Color(50,50,200));
		_indicator_graph.setSize(300, 160);
	}

	// The main graph - where the principal market data is displayed
	public TA_Graph main_graph() {
		return _main_graph;
	}

	// The indicator graph - where the indicator data is displayed
	public TA_Graph indicator_graph() {
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

	private TA_GraphInteractive _main_graph;
	private TA_GraphInteractive _indicator_graph;
	// Did _main_graph change since it was last repainted?
	boolean main_graph_changed;
	// Did _indicator_graph change since it was last repainted?
	boolean indicator_graph_changed;
	Choice period_type_choice;
	TA_Chart chart;
	String _last_period_type;
}
