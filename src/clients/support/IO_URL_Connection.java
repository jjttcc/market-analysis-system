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

		serverAddress = srvaddr;
		url = new URL(serverAddress);
	}

// Access

	public IO_Connection newObject() throws MalformedURLException {
		return new IO_URL_Connection(serverAddress);
	}

	public InputStream inputStream() throws IOException {
		return connection.getInputStream();
	}

	public OutputStream outputStream() throws IOException {
		return connection.getOutputStream();
	}

// Basic operations

	public void close() {
		// Null routine
	}

	public void open() throws IOException {
		assert url != null;

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

	private String serverAddress;
}
