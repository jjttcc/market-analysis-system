/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;
import java.net.*;

/** IO_Connection implemented as a socket */
public class IO_SocketConnection extends IO_Connection
{

	// Precondition: hostnm != null
	public IO_SocketConnection(String hostnm, int portnum) {
		assert hostnm != null;
		hostname = hostnm;
		port_number = portnum;
	}

// Access

	public IO_Connection new_object() {
		return new IO_SocketConnection(hostname, port_number);
	}

	public InputStream input_stream() throws IOException {
		return socket.getInputStream();
	}

	public OutputStream output_stream() throws IOException {
		return socket.getOutputStream();
	}

// Basic operations

	public void close() throws IOException {
		System.out.println("IO_SocketConnection.close called");
		socket.close();
	}

	public void open() throws IOException {
		System.out.println("IO_SocketConnection.open called");
		try {
			//It appears that the only way to connect a client socket is
			//to create a new one.
			socket = new Socket(hostname, port_number);
		}
		catch (UnknownHostException e) {
			throw new UnknownHostException("Don't know about host: " +
				hostname);
		}
		catch (IOException e) {
			throw new IOException("Couldn't get I/O for the connection to: " +
				hostname + "\n(" + e + ")");
		}
	}

// Implementation

	private Socket socket;
	String hostname;
	int port_number;
}
