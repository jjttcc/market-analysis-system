package pct;

import java.awt.*;

// Button that has a PCT_Component
class PCT_Button extends Button {
	PCT_Button(String title, PCT_Component c) {
		super(title);
		component = c;
	}

	PCT_Component component;
}
