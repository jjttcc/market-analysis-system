package graph;

import java.awt.*;

// The lower graph, which displays indicator data
public class LowerGraph extends InteractiveGraph {

	public LowerGraph (MainGraph main_graph) {
		_main_graph = main_graph;
	}

	protected void draw_data(Graphics g, Rectangle r) {
		DataSet last_dataset;
		DataSet d;
		int i;

		// Only the last dataset's boundaries and reference values
		// need to be drawn, since they are all the same.
		last_dataset = (DataSet) dataset.elementAt(dataset.size() - 1);
		last_dataset.set_reference_values_needed(true);
		last_dataset.drawer().set_lower(true);
		last_dataset.drawer().set_boundaries_needed(true);
		for (i = 0; i < dataset.size() - 1; ++i) {
			d = (DataSet) dataset.elementAt(i);
			d.drawer().set_lower(true);
			d.draw_data(g, r);
		}
		last_dataset.draw_data(g, r);
		if (last_dataset.drawer().data_processed()) {
			last_dataset.draw_dates(g, r);
		}
	}

	protected void draw_as_empty(Graphics g, Rectangle r) {
		DataSet mainset = _main_graph.market_data();
		DataSet dummyset;
		BasicDrawer d;
		MarketDrawer md = null;
		if (mainset != null) {
			d = _main_graph.market_data().drawer();
			if (d != null) {
				md = _main_graph.market_data().drawer().market_drawer();
			}
		}
		dummyset = new DataSet(new LineDrawer(md));
		dummyset.drawer().set_lower(true);
		dummyset.drawer().set_boundaries_needed(true);
		dummyset.draw_data(g, r);
		if (md != null) {
			dummyset.set_dates(mainset.dates);
			dummyset.set_times(mainset.times);
			dummyset.draw_dates(g, r);
		}
	}

	// The graph for the main window
	private MainGraph _main_graph;
}
