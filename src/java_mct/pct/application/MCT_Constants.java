package pct.application;

import java.util.*;

// MAS Control Terminal constants
public interface MCT_Constants {
	// Settings key words
	public final static String binpath_key = "binpath";
	public final static String datafiles_key = "datafiles";
	public final static String command_line_cmd_key = "command_line_cmd";
	public final static String gui_cmd_key = "gui_cmd";
	public final static String server_cmd_key = "server_cmd";

	// Settings table
	public final static Hashtable settings = new Hashtable();

	// Name of file where settings are stored
	public final static String settings_file_name = "mct_settings";

	// Field separator used in scanning settings file
	public final static String settings_field_separator = ";";
}
