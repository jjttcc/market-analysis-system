package pct.application;

import java.awt.*;
import java.awt.event.*;
import support.ErrorBox;

// Dialog to obtain a port number from the user
class PortDialog extends Dialog implements ActionListener {
	public PortDialog(Frame root) {
		super(root, true);
		parent = root;
		this.add("Center", new Label(
			"Please enter the port number for the running server:"));
		Panel p = new Panel();
		p.setLayout(new FlowLayout());
		TextField text = new TextField(5);
		text.addActionListener(this);
		p.add(text);
		this.add("South", p);
		this.setSize(300,100);
		this.setLocation(100, 200);
	}  

	public int result() {
		return port_number;
	}

	public void actionPerformed(ActionEvent e) {
		String error = null;
		final int lowest = 1024; final int highest = 65535;
		try {
			port_number = Integer.parseInt(e.getActionCommand().trim());
			if (port_number < lowest || port_number > highest) {
				error = "Number out of range - must be between " + lowest +
					" and " + highest;
				throw new Exception ("");
			}
			this.setVisible(false);
			this.dispose();
		} catch (Exception ex) {
			if (error == null) error = "Invalid port number";
			else error = "Invalid port number - " + error;
			new ErrorBox("Input error",  error, parent);
		}
	}

	Frame parent;
	int port_number = 0;
}
