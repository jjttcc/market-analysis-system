package pct.application;

import java.util.*;
import support.FileReaderUtilities;

// Plug-in to start a new MAS server process
public class NewServer extends MCT_Constants {
	public NewServer(Object pcontext) {
		super(pcontext);
	}

	int newport() {
		int result;
		while (true) {
			result = random.nextInt();
			if (result < 1024) {
				continue;
			}
			else if (result > 65535) {
				continue;
			}
			break;
		}

		return result;
	}

	public Object execute() {
		MCT_ComponentContext result = null;
		int port = newport();
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
			String hostname = property_value(pcthostname_property);
			result = new MCT_ComponentContext(hostname, port);
			String cmd = processed_command(
				(String) settings.get(server_cmd_key), result);
			cmd = globbed_command(cmd);
System.out.println("Trying to execute: " + cmd);
			Process p = runtime.exec(cmd);
			result.set_process(p);
		} catch (Exception e) {
			System.err.println("Error: failed to start mas server.");
		}
		return result;
	}

	String globbed_command(String cmd) {
		String sep = property_value("file.separator");
		String s = "", glob, directory, result = "";
		int last_sep_idx, tokcount;
		StringTokenizer t = new StringTokenizer(cmd, " ");
		for ( ; t.hasMoreTokens(); ) {
			s = t.nextToken();
			if (s.indexOf('*') != -1) {
				last_sep_idx = s.lastIndexOf(sep);
				if (last_sep_idx != -1) {
					glob = s.substring(last_sep_idx + 1);
					directory = s.substring(0, last_sep_idx);
				} else {
					glob = s;
					directory = ".";
				}
				String[] files = FileReaderUtilities.globlist(directory, glob);
				for (int i = 0; i < files.length; ++i) {
					result = result + directory + sep + files[i] + " ";
				}
			} else {
				result = result + s + " ";
			}
		}
		return result;
	}

	Runtime runtime;

	Random random = new Random();
}
