/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection implements ActionListener {
	public MarketSelection(Chart f) {
		int window_width = f.main_pane.getSize().width / 10 - 4;
		main_frame = f;
		selection = new List();
		dialog = new Dialog(f);
		Panel panel = new Panel(new BorderLayout());
		Button close_button = new Button("Close");
		dialog.add(panel);
		panel.add(selection, "Center");
		panel.add(close_button, "South");
		dialog.setSize(window_width, 373);
		selection.setSize(window_width, 348);
		close_button.setSize(window_width, 25);
		panel.setSize(window_width, 373);
		Vector ml = main_frame.markets();
		for (int i = 0; i < ml.size(); ++i) {
			selection.add((String) ml.elementAt(i));
		}
		// Add action listener (anonymous class) to respond to
		// stock selection from list.
		selection.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				main_frame.request_data(selection.getSelectedItem());
		}});
		// Add action listener (anonymous class) to respond to
		// pressing of close button.
		close_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				dialog.setVisible(false);
		}});
		// Add a key listener to close the selection dialog if the
		// escape key is pressed while the focus is in the selection list.
		selection.addKeyListener(new KeyAdapter() {
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
	}

	public void actionPerformed(ActionEvent e) {
		GUI_Utilities.busy_cursor(true, main_frame);
		Point location = main_frame.getLocation();
		location.setLocation(location.x, location.y + 135);
		dialog.setLocation(location);
		dialog.show();
		GUI_Utilities.busy_cursor(false, main_frame);
	}

	public String current_market() {
		return selection.getSelectedItem();
	}

	public void remove_selection(String s) {
		selection.remove(s);
	}

	private List selection;
	private Dialog dialog;
	private Chart main_frame;
}
