/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.awt.*;
import java.awt.event.*;
import application_library.*;

// Dialog for MA client
public abstract class MA_Dialog extends Dialog implements ActionListener {

	public MA_Dialog(Chart c) {
		super(c);
		chart = c;
		dialog = this;
		WindowSettings ws = null;
		if (save_settings()) {
			ws = chart.settings_for(title());
		}
		if (ws != null) {
			setLocation(ws.location());
			setSize(ws.size());
			size_was_set = true;
		} else {
			Point location = chart.getLocation();
			location.setLocation(location.x, location.y + 135);
			setLocation(location);
			size_was_set = false;
		}
		if (save_settings()) {
			chart.register_dialog_for_save_settings(this);
		}
		if (title() != null) setTitle(title());
	}

	// Add event listener for window close requests.
	void add_close_listener() {
		addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { dialog.setVisible(false); }
		});
	}

	// The title for this dialog window - redefine if needed
	protected String title() { return ""; }

	// Should the window position and location be saved on exit and
	// resotred on startup?  true by default - redefine if needed.
	protected boolean save_settings() { return true; }

	Chart chart;
	Dialog dialog;
	protected boolean size_was_set;
}
