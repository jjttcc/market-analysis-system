import java.awt.*;
import graph.*;
import java.util.Vector;

/** Scroll pane that holds the TA graph and buttons */
public class TA_ScrollPane extends ScrollPane
{
	public TA_ScrollPane(Vector period_types, int scrollbarDisplayPolicy)
	{
		super(scrollbarDisplayPolicy);

		drawer = new BarDrawer();
		_main_graph = new G2Dint();
		_indicator_graph = new G2Dint();
		period_type_choice = new Choice();
		for (int i = 0; i < period_types.size(); ++i) {
			period_type_choice.add((String) period_types.elementAt(i));
		}

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
		top_button_panel.add(new Button("Go"));
		top_button_panel.add(period_type_choice);
		top_button_panel.add(new Button("Modify"));
		bottom_button_panel.add(new Button("Transact"));
		bottom_button_panel.add(new Button("Stall"));

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
	public Graph2D main_graph() {
		return _main_graph;
	}

	// The indicator graph - where the indicator data is displayed
	public Graph2D indicator_graph() {
		return _indicator_graph;
	}

	// Current selected period type
	String current_period_type() {
		return period_type_choice.getSelectedItem();
	}

// Implementation

	private G2Dint _main_graph, _indicator_graph;
	DataSet data;
	BarDrawer drawer;
	Choice period_type_choice;
}
