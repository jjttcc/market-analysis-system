/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import support.*;

public class IndicatorColors extends MA_Dialog {

	public IndicatorColors(Chart c) {
		super(c);
		panel = new Panel();
		gblayout = new GridBagLayout();
		panel.setLayout(gblayout);
		//panel.setSize(350, 350);
		add(panel);
		current_entries = new Hashtable();

		// Add a key listener to close the selection dialog if the
		// escape key is pressed while the focus is in the selection list.
		panel.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (e.getKeyCode() == e.VK_ESCAPE) {
					dialog.setVisible(false);
				}
		}});
		add_close_listener();
	}

	public void actionPerformed(ActionEvent e) {
		Label l;
		GridBagConstraints gbconstraints = new GridBagConstraints();
		String s, cmd;
		int old_size = current_entries.size();
		cmd = e.getActionCommand();
		boolean cmd_is_indicator = cmd != null && ! cmd.equals(getTitle());
		// If the newly chosen item is already in the current list, there
		// is nothing to do.
		if (cmd_is_indicator && current_entries.containsKey(cmd) &&
				! chart.replace_indicators) {
			return;
		}
		int j = 0, ilength, longest_ilength = 30;
		final int Length_increment = 30, Width_increment = 10,
			Dialog_xborder = 40, Dialog_yborder = 30;
		gbconstraints.gridx = 0; gbconstraints.gridy = gbconstraints.RELATIVE;
		panel.removeAll();
		current_entries.clear();
		for (int i = 0; i < chart.current_upper_indicators.size(); ++i, ++j) {
			s = (String) chart.current_upper_indicators.elementAt(i);
			add_indicator(s, true, j);
			ilength = s.length();
			if (ilength > longest_ilength) longest_ilength = ilength;
		}
		for (int i = 0; i < chart.current_lower_indicators.size(); ++i, ++j) {
			s = (String) chart.current_lower_indicators.elementAt(i);
			add_indicator(s, false, j);
			ilength = s.length();
			if (ilength > longest_ilength) longest_ilength = ilength;
		}
		// Don't set to visible if the event was caused by an update to
		// the indicator selection list.
		if (! cmd_is_indicator) {
			setVisible(true);
		}
		if (old_size != current_entries.size()) {
			setSize(longest_ilength * Width_increment + Dialog_xborder,
				j*Length_increment + Dialog_yborder);
		} else if (isVisible()) {
			// Ugly kludge to prevent the dialog window from becoming blank.
			Dimension original_size = getSize();
			Point original_pos = getLocation();
			setSize(longest_ilength * Width_increment + Dialog_xborder,
				original_size.height + inc);
			setLocation(original_pos.x + 1, original_pos.y + 1);
			inc = -inc;
		}
	}

	protected String title() { return "Indicator Colors"; }

	// Is indicator `s' in the list of currently selected indicators?
	boolean is_in_current_indicator_list(String s) {
		boolean result = false;
		int i;
		for (i = 0; ! result && i < chart.current_upper_indicators.size(); ++i)
		{
			if (s.equals(chart.current_upper_indicators.elementAt(i))) {
				result = true;
			}
		}
		for (i = 0; ! result && i < chart.current_lower_indicators.size(); ++i)
		{
			if (s.equals(chart.current_lower_indicators.elementAt(i))) {
				result = true;
			}
		}
		return result;
	}

	private void add_indicator(String i, boolean upper, int position) {
		GridBagConstraints gbconstraints = new GridBagConstraints();
		Label l;
		Button bar;
		Color color;
		final int Length_increment = 20, Dialog_border = 30;
		Panel p = new Panel(new BorderLayout());
		Panel insidep = new Panel(new BorderLayout());
		gbconstraints.gridx = 0; gbconstraints.gridy = gbconstraints.RELATIVE;
		l = new Label(i);
		p.add(l, "West");
		color = indicator_color(i, upper);
		l = new Label(Configuration.instance().color_name(color));
		p.add(insidep, "East");
		insidep.add(l, "West");
		bar = new Button("    ");
		bar.setBackground(color);

		// Add a key listener to close the selection dialog if the
		// escape key is pressed while the focus is in the selection list.
		bar.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (e.getKeyCode() == e.VK_ESCAPE) {
					dialog.setVisible(false);
				}
		}});

		insidep.add(bar, "East");
		gbconstraints.fill = GridBagConstraints.BOTH;
		gblayout.setConstraints(p, gbconstraints);
		panel.add(p);
		current_entries.put(i, new Integer(position));
	}

	private Color indicator_color(String i, boolean upper) {
		Color result;
		Configuration conf = Configuration.instance();
		result = conf.indicator_color(i, upper);
		if (result == null) {
			if (i.equals(chart.Volume)) result = conf.bar_color();
			else result = conf.line_color();
		}

		return result;
	}

	Panel panel;
	Hashtable current_entries;
	GridBagLayout gblayout;
	// Needed for ugly kludge in actionPerformed:
	static int inc = 1;
}
