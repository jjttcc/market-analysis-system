/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;
import common.*;
import support.*;
import java.awt.*;

/** Abstraction for an input/output connection */
abstract public class IO_Connection
{
	// The IO connection's input stream
	abstract public InputStream input_stream();

	// The IO connection's output stream
	abstract public OutputStream output_stream();

	// Close the connection.
	abstract public void close();

	// Open the connection.
	abstract public void open();
}
