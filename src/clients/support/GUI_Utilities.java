/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

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
