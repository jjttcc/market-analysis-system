/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.io.*;
import java.awt.*;

public class WindowSettings implements Serializable {
	public WindowSettings(Dimension s, Point l) {
		size_ = s;
		location_ = l;
	}

	public Point location() { return location_; }
	public Dimension size() { return size_; }

	private Point location_;
	private Dimension size_;
}
