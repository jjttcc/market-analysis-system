/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import support.ErrorBox;

// The Market Analysis GUI menu bar
public class MA_MenuBar extends MenuBar {
	MA_MenuBar(Chart c, DataSetBuilder builder, Vector period_types) {
		data_builder = builder;
		parent = c;
		Menu file_menu = new Menu("File");
		Menu indicator_menu = new Menu("Indicators");
		Menu view_menu = new Menu("View");
		IndicatorSelection indicator_listener = new IndicatorSelection(parent);

		add(file_menu);
		add(indicator_menu);
		add(view_menu);
		parent.add_indicators(indicator_menu);

		// File menu items, with shortcuts
		MenuItem new_window, close_window, mkt_selection, print_cmd;
		MenuItem indicator_selection, print_all, quit;
		file_menu.add(new_window = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(close_window = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file_menu.addSeparator();
		file_menu.add(mkt_selection = new MenuItem("Select Market",
							new MenuShortcut(KeyEvent.VK_S)));
		file_menu.add(indicator_selection = new MenuItem("Select Indicator",
							new MenuShortcut(KeyEvent.VK_I)));
		file_menu.addSeparator();
		file_menu.add(print_cmd = new MenuItem("Print",
							new MenuShortcut(KeyEvent.VK_P)));
		file_menu.add(print_all = new MenuItem("Print all",
							new MenuShortcut(KeyEvent.VK_A)));
		file_menu.addSeparator();
		file_menu.add(
			quit = new MenuItem("Quit", new MenuShortcut(KeyEvent.VK_Q)));

		// Action listeners for file menu items
		new_window.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
				Chart chart = new Chart(new DataSetBuilder(data_builder), null);
			}
		});
		mkt_selection.addActionListener(parent.market_selections);
		indicator_selection.addActionListener(indicator_listener);
		close_window.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) { parent.close(); }
		});
		print_cmd.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			if (! (parent.current_market == null ||
					parent.current_market.length() == 0)) {
				parent.main_pane.print(false);
			}
			else {
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", parent);
			}
		}});
		print_all.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			if (! (parent.current_market == null ||
					parent.current_market.length() == 0)) {
				String original_market = parent.current_market;
				parent.print_all_charts();
				parent.request_data((String) original_market);
			}
			else {
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", parent);
			}
		}});
		quit.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) { parent.quit(0); }
		});

		// View menu items
		final MenuItem replace_toggle;
		final Menu period_menu = new Menu();
		final MenuItem indicator_colors_item = new MenuItem("Indicator Colors",
			new MenuShortcut(KeyEvent.VK_C));
		view_menu.add(replace_toggle = new MenuItem("",
							new MenuShortcut(KeyEvent.VK_R)));
		view_menu.add(indicator_colors_item);
		set_replace_indicator_label(replace_toggle);
		view_menu.add(period_menu);
		setup_period_menu(period_menu, period_types);
		final IndicatorColors indicator_colors = new IndicatorColors(parent);
		// Connect the indicator colors dialog/list with the corresponding
		// menu item:
		indicator_colors_item.addActionListener(indicator_colors);
		// Set up so that the indicator colors dialog/list will be updated
		// whenever an indicator is selected from the indicator menu item.
		indicator_listener.addActionListener(indicator_colors);
		// Set up so that the indicator colors dialog/list will be
		// updated whenever an indicator is selected from `indicator_menu':
		for (int i = 0; i < indicator_menu.getItemCount(); ++i) {
			indicator_menu.getItem(i).addActionListener(indicator_colors);
		}

		// Action listeners for view menu items
		replace_toggle.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
				parent.toggle_indicator_replacement();
				set_replace_indicator_label(replace_toggle);
			}
		});
	}

	private void set_period_type_label(Menu m) {
		m.setLabel("Period Type (" +
			parent.current_period_type + ")");
	}

	private void set_replace_indicator_label(MenuItem item) {
		if (parent.replace_indicators) {
			item.setLabel("Replace Indicators [on]");
		} else {
			item.setLabel("Replace Indicators [off]");
		}
	}

	private void setup_period_menu(final Menu period_menu, Vector ptypes) {
		MenuItem daily, weekly, monthly;
		Vector items = new Vector();
		String s;

		set_period_type_label(period_menu);
		for (int i = 0; i < ptypes.size(); ++i) {
			s = (String) ptypes.elementAt(i);
			if (s.toLowerCase().equals(daily_period.toLowerCase())) {
				period_menu.add(daily = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_D)));
				items.addElement(daily);
			}
			else if (s.toLowerCase().equals(weekly_period.toLowerCase())) {
				period_menu.add(weekly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_E)));
				items.addElement(weekly);
			}
			else if (s.toLowerCase().equals(monthly_period.toLowerCase())) {
				period_menu.add(monthly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_M)));
				items.addElement(monthly);
			}
			else {
				MenuItem other;
				period_menu.add(other = new MenuItem(s));
				items.addElement(other);
			}
		}
		for (int i = 0; i < items.size(); ++i) {
			final MenuItem item = (MenuItem) items.elementAt(i);
			item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
					parent.notify_period_type_changed(item.getLabel());
					set_period_type_label(period_menu);
				}
			});
		}
	}

	private DataSetBuilder data_builder;
	private Chart parent;
	private static final String daily_period = "Daily";
	private static final String weekly_period = "Weekly";
	private static final String monthly_period = "Monthly";
}
