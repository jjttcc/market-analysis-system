package pct.application;

import java.util.*;
import java.io.*;
import pct.*;
import support.FileReaderUtilities;

// MAS Control Terminal constants and related facilities
public class MCT_Constants {
	public MCT_Constants(Object pcontext) {
		parent_context = (MCT_ComponentContext) pcontext;
	}

	// Settings key words
	public final static String binpath_key = "binpath";
	public final static String datafiles_key = "datafiles";
	public final static String command_line_cmd_key = "command_line_cmd";
	public final static String gui_cmd_key = "gui_cmd";
	public final static String server_cmd_key = "server_cmd";
	public final static String server_termination_cmd_key =
		"server_termination_cmd";

	// Tokens for scanning setting components
	public final static String hostname_token = "hostname";
	public final static String port_token = "portnumber";

	// Settings table
	public final static Hashtable settings = new Hashtable();

	// Name of file where settings are stored
	public final static String settings_file_name = "mct_settings";

	// Field separator used in scanning settings file
	public final static String settings_field_separator = ";";

	// Path of the program configuration file
	static private String setting_file_path() {
		Properties p = new Properties(System.getProperties());
		String fname = settings_file_name;
		String result = p.getProperty(PCT_Tools.pctdir_property) +
			p.getProperty("file.separator") + fname;
		return result;
	}

	static {
		set_settings();
	}

	static void set_settings() {
		String s;
		String setting_file_path = setting_file_path();
		File f = new File(setting_file_path);
		if (! f.exists()) {
			PCT_Main.abort("MCT Settings file " + setting_file_path +
				" not found - aborting ...");
		}
		FileReaderUtilities file_util = null;
		try {
			file_util = new FileReaderUtilities(setting_file_path);
			file_util.tokenize("\n");
		}
		catch (IOException e) {
			PCT_Main.abort("I/O error occurred while reading file " +
				setting_file_path + ": " + e);
		}
		while (! file_util.exhausted()) {
			StringTokenizer t = new StringTokenizer(file_util.item(),
				settings_field_separator);
			s = t.nextToken();
//System.out.println("current item: " + file_util.item() + ", s: " + s);
			if (s.charAt(0) == '#') {}	// skip comment line
			else if (s.equals(binpath_key)) {
				settings.put(binpath_key, t.nextToken());
			}
			else if (s.equals(datafiles_key)) {
				settings.put(datafiles_key, t.nextToken());
			}
			else if (s.equals(command_line_cmd_key)) {
				settings.put(command_line_cmd_key, t.nextToken());
			}
			else if (s.equals(gui_cmd_key)) {
				settings.put(gui_cmd_key, t.nextToken());
			}
			else if (s.equals(server_cmd_key)) {
				settings.put(server_cmd_key, t.nextToken());
			}
			else if (s.equals(server_termination_cmd_key)) {
				settings.put(server_termination_cmd_key, t.nextToken());
			}
if (settings.containsKey(s))
System.out.println("Set " + s + " to: " + settings.get(s));
			file_util.forth();
		}
	}

	// Value from `settings' that corresponds to key extracted from `s',
	// with additional characters, if included
	String setting_for(String s) {
		StringTokenizer t = new StringTokenizer(s, "<>");
		String result = "";
		if (t.hasMoreTokens()) {
			result = (String) settings.get(t.nextToken());
		}
		if (t.hasMoreTokens()) {
			result = result + t.nextToken();
		}
		return result;
	}

	// Result of processing "[token]" `s' - empty if `s' is invalid or
	// if `parent_context' is null.
	String processed_token(String s) {
		StringTokenizer t = new StringTokenizer(s, "[]");
		String result = "";
		String word;
		if (t.hasMoreTokens() && parent_context != null) {
			word = t.nextToken();
			if (word.equals(hostname_token)) {
				result = parent_context.server_host_name();
			} else if (word.equals(port_token)) {
				result = "" + parent_context.server_port_number();
			}
			if (t.hasMoreTokens()) {
				result = result + t.nextToken();
			}
		}
		return result;
	}

	// `cmd', processed to replace <word> and [word] with appropriate
	// settings.
	String processed_command(String cmd) {
		String result = "", s, current_word;
		StringTokenizer t = new StringTokenizer(cmd, " ");
		while (t.hasMoreTokens()) {
			s = t.nextToken();
			if (s.charAt(0) == '<' && s.lastIndexOf('>') != -1) {
				current_word = setting_for(s);
			} else if (s.charAt(0) == '[' && s.lastIndexOf(']') != -1) {
				current_word = processed_token(s);
			} else {
				current_word = s;
			}
			if (result.equals("")) {
				result = current_word;
			} else {
				result = result + " " + current_word;
			}
		}
		return result;
	}

	MCT_ComponentContext parent_context;	// context of parent component
}
