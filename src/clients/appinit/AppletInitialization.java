package appinit;

import java.io.*;
import java.applet.*;
import java.net.*;
import mas_gui.*;
import application_support.*;
import support.*;
import applet.*;

// Applet initialization utilities
public class AppletInitialization extends AppletTools {

	public AppletInitialization(Applet appl) {
		applet = appl;
	}

	// Initialize the applet configuration.
	public void initialize_configuration() {
		initialization_succeeded = false;
		try {
			Configuration.set_instance(new MA_Configuration(new Tokenizer(
				new StringReader(SelfContainedConfiguration.contents()),
				"configuration settings")));
			Configuration.set_ignore_termination(true);
			MA_Configuration.set_modifier(
				new ParameterBasedConfigurationModifier(
				parameter_names(), parameter_values(applet)));
			initialization_succeeded = true;
		} catch (IOException e) {
			init_error = "Initialization failed: " + e;
		}
	}

	// Did initialize_configuration succeed?
	public boolean initialization_succeeded() {
		return initialization_succeeded;
	}

	// If not `initialization_succeeded', an error status report
	public String init_error() {
		return init_error;
	}

	// The URL for the specified file name
	public URL url_for(String filename) {
		return url_for(filename, applet);
	}

	// Start the charting GUI.
	public void start_gui(DataSetBuilder builder, String sfname,
			StartupOptions options) {
		Chart chart = new Chart(builder, sfname, options);
	}

	private boolean initialization_succeeded;
	private Applet applet;
	private String init_error;
}
