/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;

/** Utilities for reading a text file */
//!!!!!!!!!!Change name to FileTokenizer.
public class FileReaderUtilities extends Tokenizer {

	// If the file associated with `file_name' is not readable, an
	// exception is thrown.
	public FileReaderUtilities(String file_name) throws IOException {
		super(new FileReader(new File(file_name)), "input file: " + file_name);
	}
}
