package pct;

import java.util.*;
import org.apache.regexp.*;
import support.FileReaderUtilities;

// ProgramControlTerminal utility functions
class PCT_Tools {

	void set_program_name(String s) {
		program_name = s;
	}

	// Split `s', using `fldsep' as the field separator.
	static String[] split(String s, String fldsep) {
		StringTokenizer t = new StringTokenizer(s, fldsep, false);
		String[] result = new String[t.countTokens()];
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			result[i] = t.nextToken();
		}
		return result;
	}

	// Does `s' match the regular expression `regex'?
	static boolean regex_match(String regex, String s) {
		boolean result = false;
		try {
			RE re = new RE(regex);
			result = re.match(s);
		}
		catch (Exception e) {
			System.err.println("Code defect in regex_match.");
			System.exit(-1);
		}
		return result;
	}

	// Open, readable configuration file
	FileReaderUtilities config_file()
			throws Exception {
		FileReaderUtilities result = null;
		String cfpath = config_file_path();
		try {
			result = new FileReaderUtilities(cfpath);
		}
		catch (Exception e) {
			throw new Exception(e.getMessage() +
				"Configuration file " + cfpath + " not found.");
		}
		return result;
	}

	// Is `l' a configuration-file comment?
	boolean comment(String l) {
		boolean result = l.charAt(0) == '#';
		return result;
	}

	// Path of the program configuration file
	private String config_file_path() {
		Properties p = new Properties(System.getProperties());
		String cfgfname = config_file_name;
		if (cfgfname == null || cfgfname == "") {
			cfgfname = p.getProperty(pctname_property, pct_default_name);
		}
		String result = p.getProperty(pctdir_property, ".") +
			p.getProperty("file.separator") + cfgfname;
		return result;
	}

	// Field separator exctracted from `lines'
	// Precondition: lines != null
	String separator(Vector lines) throws Exception {
		String result = "\t";
		for (int i = 0; i < lines.size(); ++i) {
			String line = (String) lines.elementAt(i);
			if (! comment(line)) {
				String[] words =  split(line, "=");
				if (words[0].equals(Separator_string)) {
					result = words[1];
					if ((result.length()) > 0) {
						break;
					} else {
						throw new Exception("invalid separator spec. " +
							"in config file: '" + line + "'");
					}
				}
			}
		}

		return result;
	}

	String program_name;
	static final String pctname_property = "pct.name";
	static final String pctdir_property = "pct.dir";
	static final String pct_default_name = "pct_config";
	String config_file_name;
	final String Separator_string = "separator";
}
