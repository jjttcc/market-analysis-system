/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;

/**
 *  Font properties used by the application
 */
public class FontManager extends FontProperties {

// Initialization

	// Postcondition:
	//   saved_font() == g.getFont()
	//   graphics() == g
	FontManager(Graphics g) {
		graphics = g;
		saved_font = g.getFont();
	}

// Access

	public Graphics graphics() {
		return graphics;
	}

	public Font saved_font() {
		return saved_font;
	}

// Basic operations

	// Create a new font with the specified name, style, and size and
	// set graphics()'s font to the new font.
	public void set_new_font(String name, int style, int size) {
		graphics.setFont(new Font(name, style, size));
	}

	// Restore graphics()'s font to saved_font().
	public void restore_font() {
		graphics.setFont(saved_font);
	}

// Implementation - attributes

	private Graphics graphics;
	private Font saved_font;
}
