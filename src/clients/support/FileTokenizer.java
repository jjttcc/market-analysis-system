/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;

/** Utilities for reading a text file */
public class FileReaderUtilities
{
	// If the file associated with `file_name' is not readable, an
	// exception is thrown.
	public FileReaderUtilities(String file_name) throws IOException
	{
		file = new File(file_name);
		if (! file.canRead()) {
			throw new IOException("File " + file_name + " does not exist " +
				"or cannot be read.");
		}
	}

	/** Tokenize the contents of the file */
	// Postcondition: item returns the first tokenized field.
	public void tokenize(String field_separators) throws IOException
	{
		tokens = new StringTokenizer(contents(), field_separators);
		_item = tokens.nextToken();
	}

	// Result of expanding, in directory `dir', `glob' (e.g., "*.java")
	// into a list of files
	// Precondition: dir != null && glob != null
     public static String[] globlist(String dir, final String glob) {
		File directory = new File(dir);

		String[] result = directory.list(new FilenameFilter() {
			public boolean accept(File f, String s) {
				boolean acc_result = false;
				if (glob.equals("*")) acc_result = true;
				else if (glob.endsWith("*")) {
					String firstPart = glob.substring(0,glob.length()-1);
					acc_result = s.startsWith(firstPart);
				}
				else if (glob.startsWith("*")) {
					String lastPart = glob.substring(1,glob.length());
					acc_result = s.endsWith(lastPart);
				}
				return acc_result;
			}
		});

		return result;
     }

	/** The current tokenized item */
	public String item()
	{
		return _item;
	}

	/** Advance to the next tokenized item. */
	public void forth()
	{
		if (tokens.hasMoreTokens())
		{
			_item = tokens.nextToken();
		}
		else
		{
			_exhausted = true;
			_item = null;
		}
	}

	/** Are there no more tokenized items? */
	public boolean exhausted()
	{
		return _exhausted;
	}

	/** Contents of the file */
	public String contents() throws IOException
	{
		if (_contents == null)
		{
			FileReader reader = new FileReader(file);
			char[] buffer = new char[(int) file.length()];
			reader.read(buffer);
			_contents = new String(buffer);
		}

		return _contents;
	}

	private File file;
	
	private StringTokenizer tokens;

	private String _contents;

	private String _item;

	boolean _exhausted;
}
