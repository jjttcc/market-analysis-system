/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import common.*;

/** Global configuration settings - singleton */
public class Configuration implements NetworkProtocol {

// Access

	public String session_settings() {
		return "";
	}

	// The singleton instance
	public static Configuration instance() {
		if (_instance == null) {
			_instance = new Configuration(input_source);
		}
		return _instance;
	}

// Status report

	// Should a call to 'terminate' be ignored?
	public static boolean ignore_termination() {
		return ignore_termination_;
	}

	// Is "debugging" on?
	public static boolean debug() {
		return debug_;
	}

// Element change

	// Set the input source to be used for configuration input.
	// Note: either, but not both of, set_input_source or set_instance
	//   should be called before using the other features.
	public static void set_input_source(Tokenizer insrc) {
		input_source = insrc;
	}

	// Set the singleton instance to 'instance'.
	// Note: either, but not both of, set_input_source or set_instance
	//   should be called before using the other features.
	public static void set_instance(Configuration instance) {
		_instance = instance;
	}

	// Set whether calls to 'terminate' should be ignored.
	public static void set_ignore_termination(boolean value) {
		ignore_termination_ = value;
	}

	// Set 'debug'.
	public static void set_debug(boolean value) {
		debug_ = value;
	}

// Basic operations

	// If not ignore_termination(), terminate the process.
	public static void terminate(int status) {
		if (! ignore_termination_) {
			System.exit(status);
		}
	}

// Implementation

	protected Configuration(Tokenizer in_source) {
	}

// Implementation - attributes

	protected static boolean ignore_termination_ = false;
	protected static boolean debug_ = false;
	protected static Configuration _instance;
	protected static Tokenizer input_source;
}
