/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;
import java.net.*;

/** IO_Connection implemented as an URLConnection */
public class IO_URL_Connection extends IO_Connection
{
	// Precondition: srvaddr != null
	public IO_URL_Connection(String srvaddr) throws MalformedURLException {
		assert srvaddr != null;

		server_address = srvaddr;
		url = new URL(server_address);
	}

// Access

	public IO_Connection new_object() throws MalformedURLException {
		return new IO_URL_Connection(server_address);
	}

	public InputStream input_stream() throws IOException {
		return connection.getInputStream();
	}

	public OutputStream output_stream() throws IOException {
		return connection.getOutputStream();
	}

// Basic operations

	public void close() {
		// Null routine
		System.out.println("IO_URL_Connection.close called");
	}

	public void open() throws IOException {
		assert url != null;
		System.out.println("IO_URL_Connection.open called");

		connection = url.openConnection();
		connection.setDoInput(true);
		connection.setDoOutput(true);
		connection.setUseCaches(false);
		connection.setRequestProperty ("Content-Type",
			"application/octet-stream");
		connection.connect();
	}

// Implementation

	private URLConnection connection;

	private URL url;

	private String server_address;
}
