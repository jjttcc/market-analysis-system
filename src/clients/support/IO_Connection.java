/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;

/** Abstraction for an input/output connection */
abstract public class IO_Connection
{
// Access

	// A new instance copied from 'this'
	abstract public IO_Connection newObject() throws IOException;

	// The IO connection's input stream
	abstract public InputStream inputStream() throws IOException;

	// The IO connection's output stream
	abstract public OutputStream outputStream() throws IOException;

// Basic operations

	// Close the connection.
	abstract public void close() throws IOException;

	// Open the connection.
	abstract public void open() throws IOException;
}
