
import java.util.Vector;
import java.io.*;
import support.FileReaderUtilities;

//!!!NOTE: Idea: instead of using the dynamic exec tool that the python
//version used, make it into a framework.  Specializing classes can
//provide application-specific facilities.

// GUI terminal that provides general program control facilities
public class ProgramControlTerminal extends PCT_Tools {

	ProgramControlTerminal(String cfg_filename, String prog_name) 
			throws Exception {
		config_file_name = cfg_filename;
		program_name = prog_name;
//System.out.println("PCT A");
		FileReaderUtilities cfgfile = config_file();
//System.out.println("PCT B");
		Vector lines = lines_from_file(cfgfile);
//System.out.println("PCT C");
		String sep = separator(lines);
		window_title = "Program Control Panel";
		quit = false;
//System.out.println("PCT C1");
		parse_and_process(lines, sep);
System.out.println("subcoms line, [1].prompt: " + subcomponents.size() + ", " +
((PCT_Component) subcomponents.elementAt(1)).prompt);
System.out.println("subcoms[2].prompt: " + subcomponents.size() + ", " +
((PCT_Component) subcomponents.elementAt(2)).prompt);
System.out.println("subcoms[0].prompt: " + subcomponents.size() + ", " +
((PCT_Component) subcomponents.elementAt(0)).prompt);
//System.out.println("PCT D");
		window = new PCT_Window(window_title);
//System.out.println("PCT E");
		for (int i = 0; i < subcomponents.size(); ++i) {
			window.add_button((PCT_Component) subcomponents.elementAt(i));
		}
		if (quit) window.add_quit_button();
	}

	//All lines from `f', one element per line
	Vector lines_from_file(FileReaderUtilities f) throws IOException {
		Vector result = new Vector();
		String newline = "\n";
		f.tokenize(newline);
		while (! f.exhausted()) {
			result.addElement(f.item());
//System.err.println("added " + f.item());
			f.forth();
		}
		return result;
	}

	// Set the arguments for the subcomponents' startup command.
	void set_args(Vector args) {
		for (int i = 0; i < subcomponents.size(); ++i) {
			((PCT_Component) subcomponents.elementAt(i)).prepend_cmd_args(args);
		}
	}

	void main_loop() {
		window.mainloop();
	}

	// Parse and process `lines' using separator `sep'.
	void parse_and_process(Vector lines, String sep) {
		subcomponents = new Vector();
		boolean in_sub = false;
		PCT_Component current_sub = null;
		for (int i = 0; i < lines.size(); ++i) {
			String l = (String) lines.elementAt(i);
			if (comment(l)) continue;
			String[] tuple = split(l, sep);
			String tuple_name = tuple[0];
//System.out.println("parse... tuple name, curr sub, insub, l: " + tuple_name +
//	", " + current_sub + ", " + in_sub + ", " + l);
//System.out.println("l: " + l);
			if (tuple_name.equals("terminal_name")) {
				window_title = tuple[1];
			}
			else if (tuple_name.equals("program_name")) {
				program_name = tuple[1];
			}
			else if (tuple_name.equals("quitbutton")) {
				quit = true;
			}
			else if (regex_match("^begin", tuple_name)) {
				current_sub = new PCT_Component(this);
//System.out.println("parse... curr sub set to: " + current_sub);
				in_sub = true;
			}
			else if (regex_match("^end", tuple_name)) {
				subcomponents.addElement(current_sub);
				in_sub = false;
			}
			else if (in_sub) {
//System.out.println("parse... in sub -");
//System.out.println("parse... tuple name, curr sub, insub: " + tuple_name +
//	", " + current_sub + ", " + in_sub);
				if (tuple_name.equals("prompt")) {
					current_sub.prompt = tuple[1];
				}
				else if (tuple_name.equals("startup_cmd")) {
					current_sub.set_startup_cmd(tuple[1]);
				}
				else if (tuple_name.equals("config_file_name")) {
					current_sub.config_file_name = tuple[1];
				}
				else if (tuple_name.equals("cmd_args")) {
					current_sub.add_cmd_arg(tuple[1]);
				}
				else if (tuple_name.equals("exit_after_startup_cmd")) {
					current_sub.exit_after_startup_cmd = 1;
				}
				else if (tuple_name.equals("import_module")) {
					String spec = tuple[1];
					if (! in_sub) {
						System.err.println("Error in cofig. file:\n" + 
							"Import spec. " + spec + " not within " +
							"sub-terminal spec.");
					}
					else current_sub.import_modules.addElement(tuple[1]);
				}
			}
			else {
				if (! regex_match("^separator", l))
					System.out.println("Invalid line in config. file: " + l +
						".\nMay be invalid because it is outside of " +
						"a sub-terminal spec.");
			}
		}
	}

	String window_title;
	boolean quit;
	PCT_Window window;
	Vector subcomponents;
	String program_name;
}
