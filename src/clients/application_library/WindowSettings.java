/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.awt.*;

class WindowSettings implements Serializable {
	public WindowSettings(Dimension s, Point l) {
		size_ = s;
		location_ = l;
	}

	public Point location() { return location_; }
	public Dimension size() { return size_; }

	private Point location_;
	private Dimension size_;
}
