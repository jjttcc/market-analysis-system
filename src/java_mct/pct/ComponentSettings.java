package pct;

import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.lang.reflect.*;
import pct.PCT_Component;
import pct.ProgramControlTerminal;

// Component setting knowledge
public class ComponentSettings extends Hashtable {
	public ComponentSettings() throws Exception {
		load_field_names();
		for (int i = 0; i < mainsettings.size(); ++i) {
			put(mainsettings.elementAt(i), Not_set);
		}
		for (int i = 0; i < subsettings.size(); ++i) {
			put(subsettings.elementAt(i), Not_set);
		}
	}

	void load_field_names() throws Exception {
		Field[] fields;
		Class mainclass = ProgramControlTerminal.class;
		Class subclass = PCT_Component.class;
		mainsettings = new Vector();
		subsettings = new Vector();
		fields = mainclass.getDeclaredFields();
		for (int i = 0; i < fields.length; ++i) {
			setup_field(fields[i].getName(), mainsettings);
		}
		fields = subclass.getDeclaredFields();
		for (int i = 0; i < fields.length; ++i) {
			setup_field(fields[i].getName(), subsettings);
		}
	}

	// If `f' is a valid "_setting" field, add it (minus the "_setting"
	// substring) to `settings'.
	void setup_field(String f, Vector settings) throws Exception {
System.err.println("checking for match on '" + f + "'");
//		Rex re = Rex.build(".*" + Setting_string);
//		RexResult result = re.match(f.toCharArray(), 0, f.length());
		int flen = f.length(); int slen = Setting_string.length();
		if (flen > slen &&
				f.substring(flen - slen, flen).equals(Setting_string)) {
//		if (result != null) {
			String s = f.substring(0, flen - slen);
System.err.println("\t<<<setup field adding " + s + ">>>");
			settings.addElement(s);
		}
	}

	// Process the tuple as a setting, using its first element as a key.
	// Precondition: tuple.length > 0; and no members of tuple are null
	// Postcondition: last_key_valid == ! get(tuple[0]).equals(Not_set)
	public void process(String[] tuple) {
		String key = tuple[0];
System.err.println("A - processing " + tuple[0] + " with key " + key);
		String s = (String) get(key);
System.err.println("B - s: '" + s + "'");
		last_key_valid_ = true;
		duplicate_setting_ = false;
System.err.println("C");
		if (s == null) {
System.err.println("D1");
			last_key_valid_ = false;
		}
		else {
			if (! s.equals(Not_set)) {
System.err.println("D2");
				duplicate_setting_ = true;
			}
			if (tuple.length > 1) {
System.err.println("E");
				if (tuple.length > 2 && tuple[2].equals(Addspec)) {
System.err.println("putting: " + s + "," + tuple[1]);
					put(key, s + Field_separator + tuple[1]);
				duplicate_setting_ = false;
System.err.println("Put: " + (String) get(key));
				} else {
					put(key, tuple[1]);
				}
System.err.println("F");
			}
			else {
System.err.println("G");
				// There is no value in this tuple (tuple[1]) - this means the
				// value should simply be set to a value other than Not_set.
				put(key, Set);
System.err.println("H");
			}
		}
	}

	// Was the last key `process'ed a valid key?
	public boolean last_key_valid() {
		return last_key_valid_;
	}

	// Was the last key `process'ed previously `process'ed?
	public boolean duplicate_setting() {
		return duplicate_setting_;
	}

	// Use `process'ed values to configure main component `comp'.
	public void set_main_settings(ProgramControlTerminal comp) {
System.err.println("set main settings");
		set_object_fields(comp, mainsettings, comp.getClass());
	}

	// Use `process'ed values to configure subcomponent `sub'.
	public void set_subcomponent_settings(PCT_Component sub) {
System.err.println("set subcomponent settings");
		set_object_fields(sub, subsettings, sub.getClass());
	}

	// Set all values associated with a setting key to Not_set.
	public void clear_values() {
System.err.println("clear values called");
		Enumeration keys = keys();
		String k;
		while (keys.hasMoreElements()) {
			k = (String) keys.nextElement();
			put(k, Not_set);
		}
	}

	// Set all subcomponent values associated with a setting key to Not_set.
	public void clear_subcomponent_values() {
System.err.println("clear subcomp values called");
		for (int i = 0; i < subsettings.size(); ++i) {
			put(subsettings.elementAt(i), Not_set);
		}
	}

	// Set all main values associated with a setting key to Not_set.
	public void clear_main_values() {
System.err.println("clear subcomp values called");
		for (int i = 0; i < mainsettings.size(); ++i) {
			put(mainsettings.elementAt(i), Not_set);
		}
	}

	// Set fields of `o', from `settings' and hashed values.
	protected void set_object_fields(Object o, Vector settings, Class c) {
System.err.println("set object fields");
		String key, fieldname, value;
		Field field = null;
		Class field_type = null;
		final Boolean True = new Boolean(true);
		for (int i = 0; i < settings.size(); ++i) {
			key = (String) settings.elementAt(i);
System.err.print("Using key: " + key);
System.err.println(" for object " + o + " for class " + c);
			fieldname = key + Setting_string;
			value = (String) get(key);
			if (! value.equals(Not_set)) {
				try {
System.err.println("Obtaining " + fieldname);
					field = c.getField(fieldname);
//					field = c.getField("prompt_setting");
System.err.println("x");
					field_type = field.getType();
System.err.println("y");
					if (field_type.equals(boolean.class)) {
						// Set boolean field to true.
System.err.println("setting field " + field.getName() + " to true");
						field.set(o, True);
System.err.println("z");
					}
					else if (field_type.equals(String.class)) {
						// Set String field to value.
System.err.println("setting field " + field.getName() + ", " + value);
						field.set(o, value);
					}
					else if (field_type.equals(Vector.class)) {
						// Append value to Vector field.
System.err.println("Appending to field " + field.getName() + ", " + value);
						Vector v = (Vector) field.get(o);
System.err.println("v is currently: " + v);
						insert_elements(v, value);
//						v.addElement(value);
System.err.println("after adding, v is now: " + v);
					}
				} catch (Exception e) {
					System.err.println("Fatal error - code defect in " +
						"set_subcomponent_settings for field " + fieldname +
						" - " + e);
					System.exit(-1);
				}
			}
		}
	}

	// Split `value' accordiing to Field_separator and insert the
	// results into `v'.
	private void insert_elements(Vector v, String value) {
		String[] parts = PCT_Tools.split(value, Field_separator);
		for (int i = 0; i < parts.length; ++i) {
			v.addElement(parts[i]);
		}
	}

	boolean last_key_valid_;
	boolean duplicate_setting_;
	Vector  mainsettings;	// settings for ProgramControlTerminal
	Vector  subsettings;	// settings for PCT_Component
	final String Setting_string = "_setting";
	final String Not_set = "";
	static final String Set = "<<set>>";
	static final String Addspec = "add";
	static final String Field_separator = ",";
}
