/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select an indicator to be displayed.
class IndicatorSelection extends Dialog implements ActionListener {
	public IndicatorSelection(Chart f) {
		super(f);
		int window_width = f.main_pane.getSize().width / 3 + 14;
		final int Min_window_height = 40, Hfactor = 16;
		main_frame = f;
		selection_list = new List();
		dialog = this;
		Panel panel = new Panel(new BorderLayout());
		Button close_button = new Button("Close");
		add(panel);
		panel.add(selection_list, "Center");
		panel.add(close_button, "South");
		setTitle("Indicators");
		Enumeration indicators = main_frame.ordered_indicators().elements();
		while (indicators.hasMoreElements()) {
			selection_list.add((String) indicators.nextElement());
		}
		indicator_listener = new IndicatorListener(main_frame);
		selection_list.addActionListener(indicator_listener);
		// Add action listener (anonymous class) to respond to
		// pressing of close button.
		close_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				dialog.setVisible(false);
		}});
		// Add a key listener to close the selection dialog if the
		// escape key is pressed while the focus is in the selection list.
		selection_list.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (e.getKeyCode() == e.VK_ESCAPE) {
					dialog.setVisible(false);
				}
		}});
		// Add a key listener to close the selection dialog if the
		// escape key is pressed while the focus is in the close button.
		close_button.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (e.getKeyCode() == e.VK_ESCAPE) {
					dialog.setVisible(false);
				}
		}});

		setSize(window_width, (selection_list.getItemCount() + 1) *
			Hfactor + Min_window_height);
	}

	public void actionPerformed(ActionEvent e) {
		GUI_Utilities.busy_cursor(true, main_frame);
		Point location = main_frame.getLocation();
		location.setLocation(location.x, location.y + 135);
		setLocation(location);
		show();
		GUI_Utilities.busy_cursor(false, main_frame);
	}

	public void remove_selection(String s) {
		selection_list.remove(s);
	}

	public void addActionListener(ActionListener l) {
		selection_list.addActionListener(l);
	}

	// The selections - type String
	public Vector selections() {
		Vector result = new Vector();
		int count = selection_list.getItemCount();
		for (int i = 0; i < count; ++i) {
			result.addElement(selection_list.getItem(i));
		}
		return result;
	}

	private List selection_list;
	private Dialog dialog;
	private Chart main_frame;
	private IndicatorListener indicator_listener;
}
