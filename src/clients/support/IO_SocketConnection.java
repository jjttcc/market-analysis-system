/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.io.*;
import java.net.*;

/** IO_Connection implemented as a socket */
public class IO_SocketConnection extends IO_Connection
{

	// Precondition: hostnm != null
	public IO_SocketConnection(String hostnm, int portnum) {
//		assert hostnm != null;
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
//		System.out.println("IO_SocketConnection.close called");
		socket.close();
	}

//!!!:
int open_count = 0;
	public void open() throws IOException {
//		System.out.println("IO_SocketConnection.open called");
		try {
			//The only way to connect a client socket is to create a new one.
			socket = new Socket();
			socket.setSoLinger(false, 0);
			socket.connect(new InetSocketAddress(hostname, port_number),
				timeout_value);
			socket.setSoTimeout(timeout_value);
		}
		catch (UnknownHostException e) {
			throw new UnknownHostException("Don't know about host: " +
				hostname);
		}
		catch (IOException e) {
			throw new IOException("Couldn't get I/O for the connection to: " +
				hostname + "\n(" + e + ")");
		}
//!!!:
++open_count;
if (open_count > 10) {
	timeout_value = 300;
}
	}

	// Report on 'socket' state for debugging.
	private void socket_report() {
		try {
			System.out.println("socket keep alive: " + socket.getKeepAlive());
			System.out.println("socket OOBInLine: " + socket.getOOBInline());
			System.out.println("socket ReuseAddress: " +
				socket.getReuseAddress());
			System.out.println("socket TcpNoDelay: " + socket.getTcpNoDelay());
			System.out.println("socket IsBound: " + socket.isBound());
			System.out.println("socket IsClosed: " + socket.isClosed());
			System.out.println("socket IsConnected: " + socket.isConnected());
			System.out.println("socket IsInputShutdown: " +
				socket.isInputShutdown());
			System.out.println("socket IsOutputShutdown: " +
				socket.isOutputShutdown());
			System.out.println("\n");
			System.out.println("socket solinger: " + socket.getSoLinger());
			System.out.println("socket soTimeout: " + socket.getSoTimeout());
		} catch (Exception e) {}
	}

// Implementation

	private Socket socket;
	String hostname;
	int port_number;

// Implementation - constants

	static int timeout_value = 10000;
}
