/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

//import java.util.*;
//import java.text.*;
//import java.io.*;
//import common.Constants;
import common.NetworkProtocol;

/** Utilities for server responses to the GUI client */
public class ServerResponseUtilities implements NetworkProtocol {

	public ServerResponseUtilities() {}

	// Response to the client, built with 'msg_id' and 'msg'
	public static String response_message(int msg_id, String msg) {
		return new Integer(msg_id).toString() + Message_field_separator +
			msg + Eom;
	}

	// Error-status response to the client, built with 'msg'
	public static String error_response_message(String msg) {
		return response_message(Error, msg);
	}

	// Warning-status response to the client, built with 'msg'
	public static String warning_response_message(String msg) {
		return response_message(Warning, msg);
	}
}
