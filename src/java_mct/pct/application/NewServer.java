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
//System.out.println("NewServer - " + server_cmd_key + ": " +
//settings.get(server_cmd_key));
			String hostname = property_value(pcthostname_property);
			result = new MCT_ComponentContext(hostname, port);
			String cmd = processed_command(
				(String) settings.get(server_cmd_key), result);
//System.out.println("cmd: " + cmd);
			cmd = globbed_command(cmd);
//System.out.println("cmd: " + cmd);
			Process p = runtime.exec(cmd);
			result.set_process(p);
//System.out.println("mct context created with hostname: " +
//((MCT_ComponentContext) result).server_host_name() +
//", port #: " + ((MCT_ComponentContext) result).server_port_number());
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
		tokcount = t.countTokens();
		if (tokcount > 0) {
			for (int i = 0; i < tokcount - 1; ++i) {
				result = result + t.nextToken() + " ";
			}
			s = t.nextToken();
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
				result = result + " " + directory + sep + files[i];
			}
		}
		return result;
	}

	Runtime runtime;

	Random random = new Random();
}
