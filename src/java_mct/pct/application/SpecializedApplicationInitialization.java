package pct.application;

import java.util.*;
import java.io.*;
import pct.*;
import support.FileReaderUtilities;

// ApplicationInitialization class specialed for the MAS Control Terminal
public class SpecializedApplicationInitialization
		extends ApplicationInitialization implements MCT_Constants {
	public SpecializedApplicationInitialization() {
	}

	static {
		_context = new MCT_ApplicationContext();
		set_settings();
System.out.println("settings: " + settings);
	}

	// Path of the program configuration file
	static private String setting_file_path() {
		Properties p = new Properties(System.getProperties());
		String fname = settings_file_name;
		String result = p.getProperty(PCT_Tools.pctdir_property) +
			p.getProperty("file.separator") + fname;
		return result;
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
if (settings.containsKey(s))
System.out.println("Set " + s + " to: " + settings.get(s));
			file_util.forth();
		}
	}
}
