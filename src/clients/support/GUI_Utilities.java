/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */
test

package support;

import java.awt.*;

public class GUI_Utilities extends Component {
	static public void busy_cursor(boolean on, Component c) {
		if (on) {
			c.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
		}
		else {
			c.setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
		}
	}
}
