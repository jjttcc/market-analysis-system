/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;

// The lower graph, which displays indicator data
public class LowerGraph extends InteractiveGraph {

	public LowerGraph (MainGraph main_graph) {
		_main_graph = main_graph;
	}

	protected void draw_data(Graphics g, Rectangle r) {
		DrawableDataSet last_dataset;
		DrawableDataSet d;
		int i;

		// Only the last dataset's boundaries and reference values
		// need to be drawn, since they are all the same.
		last_dataset = (DrawableDataSet) dataset.get(dataset.size() - 1);
		last_dataset.set_reference_values_needed(true);
		last_dataset.drawer().set_lower(true);
		last_dataset.drawer().set_boundaries_needed(true);
		for (i = 0; i < dataset.size() - 1; ++i) {
			d = (DrawableDataSet) dataset.get(i);
			d.drawer().set_lower(true);
			d.draw_data(g, r);
		}
		last_dataset.draw_data(g, r);
		// Call draw_dates on the last element of dataset that has dates:
		for (i = dataset.size() - 1; i >= 0; --i) {
			d = (DrawableDataSet) dataset.get(i);
			if (d.dates != null && d.drawer().data_processed()) {
				d.draw_dates(g, r);
				break;
			}
		}
		if (i < 0) {
			// No dataset with dates was found, so force dates to be drawn.
			draw_as_empty(g, r);
		}
	}

	protected void draw_as_empty(Graphics g, Rectangle r) {
System.out.println("draw as empty called");
		DrawableDataSet mainset = _main_graph.market_data();
		DrawableDataSet dummyset;
		BasicDrawer d;
		MarketDrawer md = null;
		if (mainset != null) {
System.out.println("1");
			d = _main_graph.market_data().drawer();
			if (d != null) {
System.out.println("2");
				md = _main_graph.market_data().drawer().market_drawer();
			}
		}
System.out.println("md: " + md);
		dummyset = new DrawableDataSet(new LineDrawer(md));
System.out.println("2a");
		dummyset.drawer().set_lower(true);
System.out.println("2b");
		dummyset.drawer().set_boundaries_needed(true);
System.out.println("2c");
		dummyset.draw_data(g, r);
System.out.println("3");
		if (md != null) {
System.out.println("4");
			dummyset.set_dates(mainset.dates);
			dummyset.set_times(mainset.times);
			dummyset.draw_dates(g, r);
System.out.println("5");
		}
	}

	// The graph for the main window
	private MainGraph _main_graph;
}
