package pct;

import java.awt.*;
import java.awt.event.*;

// Frame that implements a WindowListener with default methods
// Convenience class to work around lack of MI (can't use WindowAdapter) -
// Redefine any of the window... methods that need to do something.
class FrameWindowListener extends Frame implements WindowListener {
	FrameWindowListener(String title) {
		super(title);
	}

	public void windowClosed(WindowEvent event){}
	public void windowDeiconified(WindowEvent event){}
	public void windowIconified(WindowEvent event){}
	public void windowActivated(WindowEvent event){}
	public void windowDeactivated(WindowEvent event){}
	public void windowOpened(WindowEvent event){}
	public void windowClosing(WindowEvent event) {}
}
