/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

package support;

import java.awt.*;
import java.awt.event.*;

public class ErrorBox extends Dialog {
	public ErrorBox(String title, String msg, Frame parent) {
		super(parent);
		Button ok_button = new Button(msg);
		add(ok_button, "Center"); setSize(8 * msg.length(), 65);
		setTitle(title); show();
		ok_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				setVisible(false); }});
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				setVisible(false); }});
		ok_button.addKeyListener(new KeyAdapter() {
			public void keyPressed(KeyEvent e) {
				setVisible(false); }});
	}
}
