/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;

/** Abstraction for tokenizing an input stream, with an iterable interface */
public class Tokenizer {

// Constructors

	// Precondition: r != null && r.ready()
	// Postcondition: desc != null implies description().equals(desc)
	public Tokenizer(Reader r, String desc) throws IOException {
//		assert r != null && r.ready(): "Precondition";
		reader = r;
		description_ = desc;
//		assert desc == null || description().equals(desc): "Postcondition";
	}

// Basic operations

	/** Tokenize the contents of the file */
	// Postcondition: item returns the first tokenized field.
	public void tokenize(String field_separators) throws IOException {
		tokens = new StringTokenizer(contents(), field_separators);
		item_ = tokens.nextToken();
	}

// Access

	// Brief, user-understandable, description of this object
	public String description() {
		String result = "";
		if (description_ != null) {
			result = description_;
		}
		return result;
	}

	/** The current tokenized item */
	public String item() {
		return item_;
	}

	/** Advance to the next tokenized item. */
	public void forth() {
		if (tokens.hasMoreTokens()) {
			item_ = tokens.nextToken();
		} else {
			exhausted_ = true;
			item_ = null;
		}
	}

	/** Are there no more tokenized items? */
	public boolean exhausted() {
		return exhausted_;
	}

	/** Contents of the file */
	public String contents() throws IOException {
		if (contents_ == null) {
			contents_ = Utilities.input_string(reader);
		}
		return contents_;
	}

	private Reader reader;
	private StringTokenizer tokens;
	private String contents_;
	private String item_;
	private boolean exhausted_;
	private String description_;
}
