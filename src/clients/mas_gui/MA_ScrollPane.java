/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.util.Vector;
import java.util.Properties;
import common.*;
import application_support.*;
import graph_library.DataSet;
import graph.*;

/** Scroll pane that holds the Market Analysis graph and buttons */
public class MA_ScrollPane extends ScrollPane implements NetworkProtocol {
	static Properties print_properties;
	static { print_properties = new Properties(); }

	public MA_ScrollPane(Vector period_types, int scrollbarDisplayPolicy,
				Chart parent_chart, Properties print_props)
	{
		super(scrollbarDisplayPolicy);

		if (print_props != null) print_properties = print_props;
		MA_Configuration config = MA_Configuration.application_instance();
		chart = parent_chart;
		_main_graph = new MainGraph();
		_indicator_graph = new LowerGraph(_main_graph);
		GridBagLayout gblayout = new GridBagLayout();
		GridBagConstraints gbconstraints = new GridBagConstraints();

		main_panel = new Panel(new BorderLayout());
		add(main_panel, "Center");
		graph_panel = new Panel(gblayout);
		main_panel.add (graph_panel, "Center");

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

	// Delete all data from the main graph.
	public void clear_main_graph() {
		_main_graph.detachDataSets();
		main_graph_changed = true;
	}

	// Delete all data from the indicator graph.
	public void clear_indicator_graph() {
		_indicator_graph.detachDataSets();
	}

	// Add a data set to the main graph.
	public void add_main_data_set(DrawableDataSet d) {
		_main_graph.attachDataSet(d);
		main_graph_changed = true;
	}

	// Add a data set to the indicator graph.
	public void add_indicator_data_set(DrawableDataSet d) {
		_indicator_graph.attachDataSet(d);
	}

	// Repaint the graphs.
	public void repaint_graphs() {
		// The order matters - first repaint the main graph, then
		// the indicator graph.
		if (main_graph_changed) {
			_main_graph.repaint();
			main_graph_changed = false;
		}
		_indicator_graph.repaint();
	}

	//If all is true, loop through all selections in chart, asking it to
	//grab the data and print each one.
	public void print(boolean all) {
		Toolkit tk = getToolkit();
		PrintJob pj = tk.getPrintJob(chart,
			all? "All charts": chart.current_tradable, print_properties);
		if (pj != null) {
			if (all) {
				Vector selections = chart.market_selections.selections();
				for (int i = 0; i < selections.size(); ++i) {
					chart.request_data((String) selections.elementAt(i));
					if (chart.request_result_id() == Ok) {
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

	public void doLayout() {
		super.doLayout();
		if (getScrollbarDisplayPolicy() == SCROLLBARS_NEVER) {
			// Use this class's calculateChildSize() and re-do layout of child
			Component c = getComponent(0);
			Dimension cs = calculateChildSize();
			Insets i = getInsets();
			c.setBounds(i.left, i.top, cs.width, cs.height);
		}
	}

// Implementation

    /**
     * Determine the size to allocate the child component.
     * Overrides calculateChildSize() in ScollPane.
     * If the viewport area is bigger than the child's
     * preferred size then the child is allocated enough
     * to fill the viewport, otherwise the child is given
     * its preferred size.
     * Calls super.calculateChildSize().
     * If scrolling is disabled, the child is allocated enough
     * to fill the viewport.
     */
    Dimension calculateChildSize() {
		// Calculate the view size, accounting for border but not scrollbars
		// - don't use right/bottom insets since they vary depending
		//   on whether or not scrollbars were displayed on last resize.
		Dimension	size = getSize();
		Insets		insets = getInsets();
		int 		viewWidth = size.width - insets.left*2;
		int 		viewHeight = size.height - insets.top*2;

		// Determine whether or not horz or vert scrollbars will be displayed.
		boolean vbarOn;
		boolean hbarOn;
		Component child = getComponent(0);
		Dimension childSize = new Dimension(child.getPreferredSize());

		if (getScrollbarDisplayPolicy() == SCROLLBARS_AS_NEEDED) {
			vbarOn = childSize.height > viewHeight;
			hbarOn = childSize.width  > viewWidth;
		} else if (getScrollbarDisplayPolicy() == SCROLLBARS_ALWAYS) {
			vbarOn = hbarOn = true;
		} else { // SCROLLBARS_NEVER
			vbarOn = hbarOn = false;
		}

		// Adjust predicted view size to account for scrollbars.
		int vbarWidth = getVScrollbarWidth();
		int hbarHeight = getHScrollbarHeight();
		if (vbarOn) {
			viewWidth -= vbarWidth;
		}
		if (hbarOn) {
			viewHeight -= hbarHeight;
		}

		// If child is smaller than view, size it up.
		if ((childSize.width < viewWidth)
			|| (getScrollbarDisplayPolicy() == SCROLLBARS_NEVER)) {
			childSize.width = viewWidth;
		}
		if ((childSize.height < viewHeight)
			|| (getScrollbarDisplayPolicy() == SCROLLBARS_NEVER)) {
			childSize.height = viewHeight;
		}

		return childSize;
    }

	private void print_current_chart(PrintJob pj) {
			Graphics page = pj.getGraphics();
			Dimension size = graph_panel.getSize();
			Dimension pagesize = pj.getPageDimension();
			_main_graph.set_symbol(chart.current_tradable.toUpperCase());
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

// Implementation

	private MainGraph _main_graph;
	private LowerGraph _indicator_graph;
	private Panel main_panel;
	private Panel graph_panel;
	// Did _main_graph change since it was last repainted?
	boolean main_graph_changed;
	Choice period_type_choice;
	Chart chart;
	String _last_period_type;
}
