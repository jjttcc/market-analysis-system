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
		assert r != null && r.ready(): "Precondition";
		reader = r;
		description_ = desc;
System.out.println("Tokenizer() returning");
		assert desc == null || description().equals(desc): "Postcondition";
	}

// Basic operations

	/** Tokenize the contents of the file */
	// Postcondition: item returns the first tokenized field.
	public void tokenize(String field_separators) throws IOException {
		tokens = new StringTokenizer(contents(), field_separators);
		item_ = tokens.nextToken();
System.out.println("Tokenizer.tokenize returning");
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
System.out.println("Tokenizer.item called");
		return item_;
	}

	/** Advance to the next tokenized item. */
	public void forth() {
System.out.println("Tokenizer.forth called");
		if (tokens.hasMoreTokens()) {
			item_ = tokens.nextToken();
		} else {
			exhausted_ = true;
			item_ = null;
		}
	}

	/** Are there no more tokenized items? */
	public boolean exhausted() {
System.out.println("Tokenizer.exhausted called");
		return exhausted_;
	}

	/** Contents of the file */
	public String contents() throws IOException {
System.out.println("Tokenizer.contents called");
		if (contents_ == null) {
			contents_ = Utilities.input_string(reader);
		}
System.out.println("Tokenizer.contents - size: " + contents_.length());
		return contents_;
	}

	private Reader reader;
	private StringTokenizer tokens;
	private String contents_;
	private String item_;
	private boolean exhausted_;
	private String description_;
}
