/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

/* Module for editing the Configuration via name/value parameters
** To add a new setting-change capability, create a descendant of
** SettingChanger to handle the change and add it to 'changers' in the
** SettingChangerMap constructor.
*/

package support;

import java.util.*;

// ConfigurationModifier that uses name/value parameters as source
// specifications for the modifications
public class ParameterBasedConfigurationModifier extends ConfigurationModifier {

	//xxx
	// Precondition: names.length == values.length
	public ParameterBasedConfigurationModifier(String[] names,
			String[] values) {
		changers = new SettingChangerMap();
		contents = new Hashtable();
		for (int i = 0; i < names.length; ++i) {
			if (names[i] != null && values[i] != null) {
				contents.put(names[i], values[i]);
			}
		}
	}

	public void execute(Configuration c) {
System.out.println("PBCM.execute called");
		Enumeration e = contents.keys();
		SettingChanger changer;
		while (e.hasMoreElements()) {
			changer = changers.item(e.nextElement());
			if (changer != null) {
				changer.execute(c, (String) contents.get(changer.key()));
			}
		}
	}

// Implementation

	// The name/value-pair specifications
	private Hashtable contents;			// key: String, value: String
	// SettingChangers mapped to names
	private SettingChangerMap changers;	// key: String
}

// Changers of a specific Configuration setting
abstract class SettingChanger {
	// The key for the setting to be changed
	abstract String key();

	// Execute the setting change on 'c'.
	abstract void execute(Configuration c, String value);

	// Report error 'msg'.
	void report_error(String msg) {
		//@@Stub, for now
	}
}

// Map of each SettingChanger to its key
class SettingChangerMap {
	SettingChangerMap() {
		changers = new Hashtable();
		changers.put(BackgroundColorChanger.key_constant,
			new BackgroundColorChanger());
		changers.put(LineColorChanger.key_constant,
			new LineColorChanger());
		changers.put(BarColorChanger.key_constant,
			new BarColorChanger());
		changers.put(StickColorChanger.key_constant,
			new StickColorChanger());
		changers.put(ReferenceLineColorChanger.key_constant,
			new ReferenceLineColorChanger());
		changers.put(TextColorChanger.key_constant,
			new TextColorChanger());
		changers.put(BlackCandleColorChanger.key_constant,
			new BlackCandleColorChanger());
		changers.put(WhiteCandleColorChanger.key_constant,
			new WhiteCandleColorChanger());
		changers.put(GraphStyleChanger.key_constant,
			new GraphStyleChanger());
	}

	// The SettingChanger associated with 'key'
	SettingChanger item(Object key) {
		return (SettingChanger) changers.get(key);
	}

// Implementation

	private Hashtable changers;	// key: String, value: SettingChanger
}

// Setting changers for colors
abstract class ColorChanger extends SettingChanger {
	protected String key_value = "";
	String key() {
		return key_value;
	}
	void execute(Configuration c, String value) {
System.out.println("Setting " + key() + " to " + value);
		if (c.valid_color(value)) {
			c.set_color(key(), value);
		} else {
			report_error("Invalid color for " + key() + " specified: " +
				value);
System.out.println("Invalid color for " + key() + " specified: " + value);
		}
	}
}

// Setting changers for graph style - candle/regular
class GraphStyleChanger extends SettingChanger {
	static final String key_constant = Configuration.Main_graph_style;
	String key() {
		return key_constant;
	}
	void execute(Configuration c, String value) {
		String v = value.toLowerCase();
		if (v.equals(Configuration.Candle_style) ||
				v.equals(Configuration.Regular_style)) {
System.out.println("Setting " + key() + " to " + value);
			c.set_main_graph_style(value);
		} else {
			report_error("Invalid graph style specified: " + value);
System.out.println("Invalid graph style specified: " + value);
		}
	}
}

class BackgroundColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Background_color;
	BackgroundColorChanger() {
		key_value = key_constant;
	}
}

class LineColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Line_color;
	LineColorChanger() {
		key_value = key_constant;
	}
}

class BarColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Bar_color;
	BarColorChanger() {
		key_value = key_constant;
	}
}

class StickColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Stick_color;
	StickColorChanger() {
		key_value = key_constant;
	}
}

class ReferenceLineColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Reference_line_color;
	ReferenceLineColorChanger() {
		key_value = key_constant;
	}
}

class TextColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Text_color;
	TextColorChanger() {
		key_value = key_constant;
	}
}

class BlackCandleColorChanger extends ColorChanger {
	static final String key_constant = Configuration.Black_candle_color;
	BlackCandleColorChanger() {
		key_value = key_constant;
	}
}

class WhiteCandleColorChanger extends ColorChanger {
	static final String key_constant = Configuration.White_candle_color;
	WhiteCandleColorChanger() {
		key_value = key_constant;
	}
}
