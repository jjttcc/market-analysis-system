/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.awt.*;
import java.awt.event.*;
import java_library.support.*;

public class ErrorBox extends Dialog {
	public ErrorBox(String title, String msg, Frame parent) {
		super(parent);
//!!!!!!!!!!!!!!!!!!!:		make_contents(title, msg);
	}

	// Specify that 'System.exit(exit_val)' is to be called when the
	// error box is closed.
	public void set_exit_on_close(int exit_val) {
		exit = true;
		exit_value = exit_val;
	}

	private void make_contents(String title, String msg) {
		if (msg.length() > max_button_msg_length) {
			make_text(msg);
		} else {
			make_button(msg);
		}
		setTitle(title); show();
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				if (exit) {
					System.exit(exit_value);
				}
				setVisible(false); }});
	}

	private void make_text(String msg) {
		TextArea msgbox = new TextArea(msg, 480, 155,
			TextArea.SCROLLBARS_NONE);
		add(msgbox);
		msgbox.setEditable(false);
		setSize(480, 155);
		msgbox.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (exit) {
					System.exit(exit_value);
				}
				setVisible(false); }});
	}

	private void make_button(String msg) {
		Button ok_button = new Button(msg);
		add(ok_button, "Center"); setSize(8 * msg.length(), 65);
		ok_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (exit) {
					System.exit(exit_value);
				}
				setVisible(false); }});
		ok_button.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				if (exit) {
					System.exit(exit_value);
				}
				setVisible(false); }});
	}

	private boolean exit = false;
	private int exit_value;
	private static int max_button_msg_length = 26;
}
