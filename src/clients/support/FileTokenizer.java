/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;

/** Tokenizer that reads a text file */
public class FileTokenizer extends Tokenizer {

	// If the file associated with `file_name' is not readable, an
	// exception is thrown.
	public FileTokenizer(String file_name) throws IOException {
		super(new FileReader(new File(file_name)), "input file: " + file_name);
	}
}
