/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// Listener that allows user to select a market to be displayed.
class MarketSelection implements ActionListener {
	public MarketSelection(Chart f) {
		main_frame = f;
		selection = new List();
		dialog = new Dialog(f);
		Panel panel = new Panel(new BorderLayout());
		Button close_button = new Button("Close");
		dialog.add(panel);
		panel.add(selection, "Center");
		panel.add(close_button, "South");
		dialog.setSize(80, 373);
		selection.setSize(80, 348);
		close_button.setSize(80, 25);
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
		dialog.show();
		GUI_Utilities.busy_cursor(false, main_frame);
	}

	String current_market() {
		return selection.getSelectedItem();
	}

	private List selection;
	private Dialog dialog;
	private Chart main_frame;
}
