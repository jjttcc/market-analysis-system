/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.zip.*;
import common.*;
import graph.*;
import support.*;

/** A Connection that receives compressed data from the server */
public class CompressedConnection extends Connection
{

	// args[0]: hostname, args[1]: port_number
	public CompressedConnection(IO_Connection io_conn) {
		super(io_conn);
	}

	public Connection new_object() throws IOException {
		return new CompressedConnection(io_connection.new_object());
	}

// Implementation

	protected Reader new_reader() {
		Reader result = null;
		try {
			result = new BufferedReader(new InputStreamReader(
				new InflaterInputStream(io_connection.input_stream(),
				new Inflater(), 850000)));
		} catch (Exception e) {
			System.err.println("Failed to read from server (" + e + ")");
			Configuration.terminate(1);
		}
//System.out.println("decompressing");
		return result;
	}

	// Send the `msgID', the session key, the compression-on flag,
	// and `msg' - with field delimiters according to the client/server
	// protocol.
	void send_msg(int msgID, String msg, int session_key) {
		out.print(msgID);
		out.print(Message_field_separator + session_key);
		out.print(Message_field_separator + Compression_on_flag + msg);
		out.print(Eom);
		out.flush();
	}
}
