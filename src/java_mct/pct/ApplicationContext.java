package pct;

import java.awt.*;

// Global data needed by the application - subclass as needed
public class ApplicationContext {

	static public Frame root_window() {
		return _root_window;
	}

	static void set_root_window(Frame f) {
		_root_window = f;
	}

	static Frame _root_window;
}
