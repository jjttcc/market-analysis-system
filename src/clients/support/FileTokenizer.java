package support;

import java.util.*;
import java.io.*;

/** Utilities for reading a text file */
public class FileReaderUtilities
{
	public FileReaderUtilities(String file_name)
	{
		file = new File(file_name);
	}

	/** Tokenize the contents of the file */
	// Postcondition: item returns the first tokenized field.
	public void tokenize(String field_separators) throws IOException
	{
		tokens = new StringTokenizer(contents(), field_separators);
		_item = tokens.nextToken();
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
testcvs
