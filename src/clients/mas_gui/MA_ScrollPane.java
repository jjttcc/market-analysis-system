import java.awt.*;
import graph.*;

public class TA_ScrollPane extends ScrollPane {

	private Graph2D main_graph, indicator_graph;
	DataSet data;
	BarDrawer drawer;

	public TA_ScrollPane()
	{
		int i;
		int j;

		drawer = new BarDrawer();
		main_graph = new Graph2D();
		indicator_graph = new Graph2D();

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
		top_button_panel.add(new Button("Stay"));
		top_button_panel.add(new Button("Modify"));
		bottom_button_panel.add(new Button("Transact"));
		bottom_button_panel.add(new Button("Stall"));

		graph_panel.add (main_graph, "Center");
		graph_panel.add (indicator_graph, "South");
		main_graph.framecolor = new Color(0,0,0);
		main_graph.borderTop = 0;
		main_graph.borderBottom = 1;
		main_graph.borderLeft = 0;
		main_graph.borderRight = 1;
		main_graph.setGraphBackground(new Color(50,50,200));
		main_graph.setSize(300, 200);

		indicator_graph.framecolor = new Color(0,0,0);
		indicator_graph.borderTop = 0;
		indicator_graph.borderBottom = 1;
		indicator_graph.borderLeft = 0;
		indicator_graph.borderRight = 1;
		indicator_graph.setGraphBackground(new Color(50,50,200));
		indicator_graph.setSize(300, 100);
	}
}
