/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.io.*;

// Test applet that communicates with the servlet via serialization
public class MAS_Applet extends Applet {
	public void paint(Graphics g) {
		if (logMsg != null) {
			g.drawString(logMsg, 5, 50);
		}
	}

	public void init() {
		try {
			initialize();
			sendMsg("I am your client!");
			log("srvr: " + serverResponse());
		} catch (Exception e) {
			log("Connection failed: " + e.toString());
		}
	}

// Implementation

	// Send 'msg' to the servlet using serialization.
	private void sendMsg(String msg) {
		ObjectOutputStream output = null;
		try {
			connection.connect();
			output = new ObjectOutputStream(connection.getOutputStream());
			// Serialize the object.
			output.writeObject(msg);
			output.flush();
			output.close();
		} catch (IOException e) {
		  log(e.toString());
		}
	}

	// Response from the server
	private String serverResponse() {
		ObjectInputStream input = null;
		String result = null;
		try {
			connection.connect();
			input = new ObjectInputStream(connection.getInputStream());
			result = extractedMsg(input);
			if (result == null || result.length() == 0) {
				result = "(Server returned empty message.)";
			}
		} catch (Exception e) {
			result = "ERROR: " + e.toString();
		}
		return result;
	}

	// Message extracted from 'input'
	// Precondition: input /= null
	private String extractedMsg(ObjectInputStream input) {
		String result = null;
		try {
			result = (String) input.readObject();
			input.close();
		} catch (IOException e) {
			log(e.toString());
		} catch (ClassNotFoundException e) {
			log(e.toString());
		} catch (Exception e) {
			System.out.println(e);
		}
		return result;
	}

// Implementation - initialization

	// Postcondition: hostName != null && serverAddress != null &&
	//    port > 0 && connection != null
	private void initialize() throws Exception {
		URL hostURL = getCodeBase();
		hostName = hostURL.getHost();
		port = hostURL.getPort();
		if (port == -1)
		{
			port = 80;
		}
		serverAddress = "http://" + hostName + ":" + port + servletPath;
		connection = serverConnection();
		assert hostName != null && serverAddress != null && port > 0 &&
			connection != null;
	}

// Implementation - utilities

	// Connection to the server for binary input and ouput with caching off
	// Precondition: serverAddress != null
	private URLConnection serverConnection() throws Exception {
		URLConnection result = (new URL(serverAddress)).openConnection();

		result.setDoInput(true);
		result.setDoOutput(true);
		result.setUseCaches (false);
		result.setRequestProperty ("Content-Type",
			"application/octet-stream");
		return result;
	}

	private void log(String msg) {
		logMsg = msg;
	}

// Implementation - attributes

	private String hostName = "";
	private int port = -1;
	private String logMsg;
	private URLConnection connection;

	private String servletPath = "/mas/mas";
	private String serverAddress = null;
}
