/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.event.*;
import java.awt.*;
import java.util.*;
import support.*;

// MA_Dialog that holds a selecton list
class DialogSelection extends MA_Dialog {
	public DialogSelection(Chart f) {
		super(f);
		selection_list = new java.awt.List();
		Panel panel = new Panel(new BorderLayout());
		Button close_button = new Button("Close");
		add(panel);
		panel.add(selection_list, "Center");
		panel.add(close_button, "South");
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
	}

	public void actionPerformed(ActionEvent e) {
		GUI_Utilities.busy_cursor(true, chart);
		show();
		GUI_Utilities.busy_cursor(false, chart);
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

	protected java.awt.List selection_list;
}
