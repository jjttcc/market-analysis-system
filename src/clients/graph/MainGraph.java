/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;

// The main (upper) graph, which displays basic market data and any
// indicators that have been assigned to the main graph
public class MainGraph extends InteractiveGraph {

	public MainGraph () {
		super();
	}

	// Main market data for the graph
	public DrawableDataSet market_data() {
		DrawableDataSet result = null;
		if (dataset.size() > 0) {
			result = (DrawableDataSet) dataset.get(0);
		}

		return result;
	}

	protected void draw_data(Graphics g, Rectangle r) {
		DrawableDataSet first_dataset;
		int i;

		// Only the first dataset's boundaries and reference values
		// need to be drawn, since they are all the same.
		first_dataset = (DrawableDataSet) dataset.get(0);
		first_dataset.drawer().set_boundaries_needed(true);
		first_dataset.set_reference_values_needed(true);
		for (i = 0; i < dataset.size(); ++i) {
			((DrawableDataSet) dataset.get(i)).draw_data(g, r);
		}
		if (first_dataset.drawer().data_processed()) {
			first_dataset.draw_dates(g, r);
		}
		if (symbol != null && symbol.length() > 0) {
			display_text("[" + symbol + "]", g);
		}
	}

	protected void draw_as_empty(Graphics g, Rectangle r) {
		DrawableDataSet ds = new DrawableDataSet(new LineDrawer(
			new PriceDrawer()));
		ds.drawer().set_boundaries_needed(true);
		ds.draw_data(g, r);
	}
}
