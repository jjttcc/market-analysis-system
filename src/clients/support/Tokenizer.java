/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;

/** Abstraction for tokenizing an input stream, with an iterable interface */
public class Tokenizer {

// Initialization

	// Precondition: r != null && r.ready()
	// Postcondition:
	//   desc != null implies description().equals(desc)
	//   reader == r
	public Tokenizer(Reader r, String desc) throws IOException {
//		assert r != null && r.ready(): "Precondition";
		reader = r;
		description = desc;
//		assert desc == null || description().equals(desc): "Postcondition";
//		assert reader == r;
	}

	/** Tokenize (or re-tokenize) the contents of the input stream */
	// Postcondition: item returns the first tokenized field.
	public void tokenize(String field_separators) throws IOException {
		contents = null;
		exhausted = false;
		tokens = new StringTokenizer(contents(), field_separators);
		forth();
	}

// Access

	// Brief, user-understandable, description of this object
	public String description() {
		String result = "";
		if (description != null) {
			result = description;
		}
		return result;
	}

	/** The current tokenized item */
	public String item() {
		return item;
	}

	/** Contents of the input stream */
	public String contents() throws IOException {
		if (contents == null) {
			contents = Utilities.input_string(reader, true);
		}
		return contents;
	}

// Status report

	/** Are there no more tokenized items? */
	public boolean exhausted() {
		return exhausted;
	}

	// Has the input stream been modified since `tokenize' was last called?
	public boolean was_modified() {
		return false;	// No - Redefine in descendant if needed.
	}

// Cursor movement

	/** Advance to the next tokenized item. */
	public void forth() {
		if (tokens.hasMoreTokens()) {
			item = tokens.nextToken();
		} else {
			exhausted = true;
			item = null;
		}
	}

// Implementation

	protected Tokenizer() {
	}

// Implementation - attributes

	protected Reader reader;
	protected StringTokenizer tokens;
	protected String contents;
	protected String item;
	protected boolean exhausted;
	protected String description;
}
