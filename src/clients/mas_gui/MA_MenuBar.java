/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import support.ErrorBox;

// The Market Analysis GUI menu bar
public class MA_MenuBar extends MenuBar {

	MA_MenuBar(Chart c, DataSetBuilder builder, Vector period_types) {
		data_builder = builder;
		chart = c;
		menu_bar = this;
		Menu file_menu = new Menu("File");
		indicator_menu = new Menu("Indicators");
		Menu view_menu = new Menu("View");
		indicator_selection = new IndicatorSelection(chart);

		add(file_menu);
		add(indicator_menu);
		add(view_menu);

		// File menu items, with shortcuts
		MenuItem new_window, close_window, mkt_selection, print_cmd;
		MenuItem indicator_selection_menu, print_all, quit;
		file_menu.add(new_window = new MenuItem("New Window",
							new MenuShortcut(KeyEvent.VK_N)));
		file_menu.add(close_window = new MenuItem("Close Window",
							new MenuShortcut(KeyEvent.VK_W)));
		file_menu.addSeparator();
		file_menu.add(mkt_selection = new MenuItem("Select Tradable",
							new MenuShortcut(KeyEvent.VK_S)));
		file_menu.add(indicator_selection_menu =
			new MenuItem("Select Indicator", new MenuShortcut(KeyEvent.VK_I)));
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
				Chart new_chart = new Chart(new DataSetBuilder(data_builder),
					chart.serialize_filename, chart.options());
			}
		});
		mkt_selection.addActionListener(chart.market_selections);
		indicator_selection_menu.addActionListener(indicator_selection);
		close_window.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) { chart.close(); }
		});
		print_cmd.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			if (! (chart.current_tradable == null ||
					chart.current_tradable.length() == 0)) {
				chart.main_pane.print(false);
			}
			else {
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", chart);
			}
		}});
		print_all.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			if (! (chart.current_tradable == null ||
					chart.current_tradable.length() == 0)) {
				String original_tradable = chart.current_tradable;
				chart.print_all_charts();
				chart.request_data((String) original_tradable);
			}
			else {
				final ErrorBox errorbox = new ErrorBox("Printing error",
					"Nothing to print", chart);
			}
		}});
		quit.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) { chart.quit(0); }
		});

		// View menu items
		final MenuItem replace_toggle;
		period_menu = new Menu();
		final MenuItem indicator_colors_item = new MenuItem("Indicator Colors",
			new MenuShortcut(KeyEvent.VK_C));
		MenuItem next = new MenuItem("Next",
			new MenuShortcut(KeyEvent.VK_CLOSE_BRACKET));
		MenuItem previous = new MenuItem("Previous",
			new MenuShortcut(KeyEvent.VK_OPEN_BRACKET));
		view_menu.add(replace_toggle = new MenuItem("",
							new MenuShortcut(KeyEvent.VK_R)));
		view_menu.add(indicator_colors_item);
		set_replace_indicator_label(replace_toggle);
		setup_period_menu(period_menu, period_types);
		view_menu.add(period_menu);
		view_menu.add(next);
		view_menu.add(previous);
		indicator_colors = new IndicatorColors(chart);
		// Connect the indicator colors dialog/list with the corresponding
		// menu item:
		indicator_colors_item.addActionListener(indicator_colors);
		// Set up so that the indicator colors dialog/list will be updated
		// whenever an indicator is selected from the indicator menu item.
		indicator_selection.addActionListener(indicator_colors);
		update_indicator_menu();

		// Action listeners for view menu items
		replace_toggle.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
				chart.toggle_indicator_replacement();
				set_replace_indicator_label(replace_toggle);
			}
		});
		next.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
				menu_bar.next_tradable();
			}
		});
		previous.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
				menu_bar.previous_tradable();
			}
		});
	}

	void reset_period_types(Vector period_types) {
		period_menu.removeAll();
		setup_period_menu(period_menu, period_types);
	}

	// Update the indicator menu and the indicator selection list with the 
	// current indicator list.
	void update_indicators() {
		indicator_selection.update_indicators(false);
		update_indicator_menu();
	}

	private void update_indicator_menu() {
		indicator_menu.removeAll();
		chart.add_indicators(indicator_menu);
		// Set up so that the indicator colors dialog/list will be
		// updated whenever an indicator is selected from `indicator_menu':
		for (int i = 0; i < indicator_menu.getItemCount(); ++i) {
			indicator_menu.getItem(i).addActionListener(indicator_colors);
		}
	}

	private void set_period_type_label(Menu m) {
		m.setLabel("Period Type (" +
			chart.current_period_type + ")");
	}

	private void set_replace_indicator_label(MenuItem item) {
		if (chart.replace_indicators) {
			item.setLabel("Replace Indicators [on]");
		} else {
			item.setLabel("Replace Indicators [off]");
		}
	}

	private void setup_period_menu(final Menu period_menu, Vector ptypes) {
		MenuItem daily = null, weekly = null, monthly = null,
			quarterly = null, yearly = null, one_minute = null,
			two_minute = null, five_minute = null, ten_minute = null,
			fifteen_minute = null, thirty_minute = null, hourly = null;
		Vector items = new Vector();
		Vector other_items = new Vector();
		String s;

		set_period_type_label(period_menu);
		for (int i = 0; i < ptypes.size(); ++i) {
			s = (String) ptypes.elementAt(i);
			if (s.toLowerCase().equals(daily_period.toLowerCase())) {
				daily = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_D));
				items.addElement(daily);
			}
			else if (s.toLowerCase().equals(weekly_period.toLowerCase())) {
				weekly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_E));
				items.addElement(weekly);
			}
			else if (s.toLowerCase().equals(monthly_period.toLowerCase())) {
				monthly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_M));
				items.addElement(monthly);
			}
			else if (s.toLowerCase().equals(quarterly_period.toLowerCase())) {
				quarterly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_U));
				items.addElement(quarterly);
			}
			else if (s.toLowerCase().equals(yearly_period.toLowerCase())) {
				yearly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_Y));
				items.addElement(yearly);
			}
			else if (s.toLowerCase().equals(one_minute_period.toLowerCase())) {
				one_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_F));
				items.addElement(one_minute);
			}
			else if (s.toLowerCase().equals(two_minute_period.toLowerCase())) {
				two_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_G));
				items.addElement(two_minute);
			}
			else if (s.toLowerCase().equals(five_minute_period.toLowerCase())) {
				five_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_H));
				items.addElement(five_minute);
			}
			else if (s.toLowerCase().equals(ten_minute_period.toLowerCase())) {
				ten_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_J));
				items.addElement(ten_minute);
			}
			else if (s.toLowerCase().equals(
					fifteen_minute_period.toLowerCase())) {
				fifteen_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_K));
				items.addElement(fifteen_minute);
			}
			else if (s.toLowerCase().equals(
					thirty_minute_period.toLowerCase())) {
				thirty_minute = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_L));
				items.addElement(thirty_minute);
			}
			else if (s.toLowerCase().equals(hourly_period.toLowerCase())) {
				hourly = new MenuItem(s,
					new MenuShortcut(KeyEvent.VK_O));
				items.addElement(hourly);
			}
			else {
				MenuItem other;
				other = new MenuItem(s);
				items.addElement(other);
				other_items.addElement(other);
			}
		}
		MenuItem menuitems[] = { daily, weekly, monthly, quarterly, yearly,
			one_minute, two_minute, five_minute, ten_minute, fifteen_minute,
			thirty_minute, hourly };
		for (int i = 0; i < menuitems.length; ++i) {
			if (menuitems[i] != null) period_menu.add(menuitems[i]);
		}
		for (int i = 0; i < other_items.size(); ++i) {
			period_menu.add((MenuItem) other_items.elementAt(i));
		}
		for (int i = 0; i < items.size(); ++i) {
			final MenuItem item = (MenuItem) items.elementAt(i);
			item.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
					chart.notify_period_type_changed(item.getLabel());
					set_period_type_label(period_menu);
				}
			});
		}
	}

	// Change the current tradable to the next one in the tradable list or,
	// if it is the last one, to the first item in the tradable list.
	private void next_tradable() {
		List mlist = chart.market_selections.selection_list;
		int i = mlist.getSelectedIndex();
		if (i < 0) {
			if (mlist.getItemCount() >= 2) i = 1;
			else i = 0;
		}
		else if (mlist.getItemCount() - 1 <= i) {
			i = 0;
		} else {
			++i;
		}
		mlist.select(i);
		chart.request_data(mlist.getItem(i));
	}

	// Change the current tradable to the previous one in the tradable list or,
	// if it is the first one, to the last item in the tradable list.
	private void previous_tradable() {
		List mlist = chart.market_selections.selection_list;
		int i = mlist.getSelectedIndex();
		if (i <= 0) {
			i = mlist.getItemCount() - 1;
		} else {
			--i;
		}
		mlist.select(i);
		chart.request_data(mlist.getItem(i));
	}

	private DataSetBuilder data_builder;
	private Chart chart;
	private MA_MenuBar menu_bar;
	private IndicatorSelection indicator_selection;
	private Menu indicator_menu;
	private Menu period_menu;
	private IndicatorColors indicator_colors;
	public static final String daily_period = "Daily";
	public static final String weekly_period = "Weekly";
	public static final String monthly_period = "Monthly";
	public static final String quarterly_period = "Quarterly";
	public static final String yearly_period = "Yearly";
	public static final String one_minute_period = "1-minute";
	public static final String two_minute_period = "2-minute";
	public static final String five_minute_period = "5-minute";
	public static final String ten_minute_period = "10-minute";
	public static final String fifteen_minute_period = "15-minute";
	public static final String thirty_minute_period = "30-minute";
	public static final String hourly_period = "Hourly";
}
