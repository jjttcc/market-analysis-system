// chap_10\Ex_3.java
// program to demonstrate action listeners and event handlers
package pct;

import pct.PCT_Component;
import java.awt.*;
import java.awt.event.*;


// Program Control Terminal GUI Window
class PCT_Window extends FrameWindowListener {
	PCT_Window(String title, int component_count) {
		super(title);
		++window_count;
//setSize(800, 460);
		setLayout(new GridLayout(0, component_count / 4 + 1));
		addWindowListener(this);
	}

	public void windowClosing(WindowEvent event)
	{
		close();
	}

	public void add_button(PCT_Component c) {
		final PCT_Button button = new PCT_Button(c.prompt(), c);
		button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
System.out.println("actPerf with btn, comp: " +
button + ", " + button.component);
					button.component.exec_startup_cmd();
					if (button.component.exit_after_startup_cmd()) {
System.out.println("actPerf - btn.comp.exit_after...");
						close();
					}
System.out.println("actPerf FINISHED with btn, comp: " +
button + ", " + button.component);
				} catch (Exception f) {
					report_startup_failure(f, button.component);
				}
		}});
		add(button);
	}

	public void add_quit_button() {
		Button button = new Button("quit");
		add(button);
		button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				close();
		}});
	}

	public void execute() {
		pack();
		show();
	}

	protected void report_startup_failure(Exception e, PCT_Component c) {
		System.err.println("Error - startup command failed (" +
			c.startup_cmd_class() + "." + c.startup_cmd_method() + ") [" +
			e + " More info needed?!!]");
	}

	protected void close() {
		dispose();
		--window_count;
		if (window_count == 0) {
			System.exit(0);
		}
	}

	static int window_count = 0;
}
