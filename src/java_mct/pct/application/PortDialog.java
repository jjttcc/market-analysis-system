package pct.application;

import java.awt.*;
import java.awt.event.*;
import support.ErrorBox;

// Dialog to obtain host name and port number from the user
class PortDialog extends Dialog implements ActionListener {
	public PortDialog(Frame root, String default_hostname) {
		super(root, true);
		parent = root;
		hostname = default_hostname;
		this.add("Center", new Label(
			"Please enter the port number for the running server:"));
		Panel p = new Panel();
		p.setLayout(new FlowLayout());
		hostname_field = new TextField(hostname);
		hostname_field.addActionListener(this);
		p.add(hostname_field);
		port_field = new TextField(5);
		port_field.addActionListener(this);
		p.add(port_field);
		this.add("South", p);
		this.setSize(300,100);
		this.setLocation(100, 200);
	}  

	public String selected_hostname() {
		return hostname;
	}

	public int selected_port() {
		return port_number;
	}

	public void actionPerformed(ActionEvent e) {
		hostname = hostname_field.getText();
		String error = null;
		final int lowest = 1024; final int highest = 65535;
		try {
			port_number = Integer.parseInt(
				port_field.getText().trim());
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
	TextField hostname_field;
	TextField port_field;
	String hostname;
}
