/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import application_support.*;

/**
 *  Abstraction for drawing time-related data
 */
abstract public class TemporalDrawer extends Drawer {

	// mkd is the associated market drawer and is_ind specifies whether
	// this DateDrawer is associated with indicator data.
	TemporalDrawer(BasicDrawer d) {
		_market_drawer = d.market_drawer();
		main_drawer = d;
		conf = MA_Configuration.application_instance();
	}

	public MarketDrawer market_drawer() { return _market_drawer; }

	public int data_length() {
		int result = 0;
		if (data() != null) {
			result = ((String[]) data()).length;
		}
		return result;
	}

	// Postcondition: result = market_drawer().data_processed()
	public boolean main_data_processed() {
		return market_drawer().data_processed();
	}

	public boolean is_indicator() {
		return main_drawer.is_indicator();
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return 1; }

	public int[] x_values() {
		return _market_drawer.x_values();
	}

	// Precondition: main_data_processed()
	public void draw_data(Graphics g, Rectangle b) {
		if (! main_data_processed()) {
			throw new Error("draw_data: Precondition violation: " +
				"main_data_processed");
				
		}
		Rectangle bounds;

		if (is_indicator()) {
			bounds = main_drawer.main_bounds(b);
		} else {
			bounds = b;
		}
		draw_tuples(g, bounds);
	}

	protected abstract void draw_tuples(Graphics g, Rectangle bounds);

	protected int label_y_value(Rectangle bounds) {
		Rectangle refbounds = main_drawer.bottom_reference_bounds(bounds);
		return bounds.y + bounds.height + Label_y_offset;
	}

	protected int label_x_value(int firstx, int secondx) {
		return -(int) ((secondx - firstx) * Label_x_factor);
	}

	final int Too_far_left = 7;

	final int Label_y_offset = 12;

	final double Label_x_factor = .025;

	protected MA_Configuration conf;

	protected MarketDrawer _market_drawer;

	protected BasicDrawer main_drawer;
}
