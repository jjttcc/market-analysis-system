/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;

/** Tokenizer that reads a text file */
public class FileTokenizer extends Tokenizer {

// Initialization

	// If the file associated with `file_name' is not readable, an
	// exception is thrown.
	public FileTokenizer(String file_name) throws IOException {
		input_file = new File(file_name);
		reader = new FileReader(input_file);
		description = "input file: " + file_name;
	}

	public void tokenize(String field_separators) throws IOException {
		if (last_modification_time != 0) {
			// `tokenize' has already been called - create a new reader
			// to force the input contents to be read again.
			reader = new FileReader(input_file);
		}
		last_modification_time = input_file.lastModified();
		super.tokenize(field_separators);
	}

// Status report

	public boolean was_modified() {
		return input_file.lastModified() > last_modification_time;
	}

// Implementation

	private File input_file;
	// Last time `input_file' was modified
	private long last_modification_time = 0;
}
