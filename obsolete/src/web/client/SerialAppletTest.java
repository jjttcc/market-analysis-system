/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

import java.applet.*;
import java.awt.*;
import java.net.*;
import java.io.*;

// Test applet that communicates with the servlet via serialization
public class SerialAppletTest extends Applet {
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

	// Send 'msg' to the servlet using serialization.
	protected void sendMsg(String msg) {
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
	protected String serverResponse() {
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
	protected String extractedMsg(ObjectInputStream input) {
		String msg = null;
		try {
			msg = (String) input.readObject();
			input.close();
		} catch (IOException e) {
			log(e.toString());
		} catch (ClassNotFoundException e) {
			log(e.toString());
		} catch (Exception e) {
			System.out.println(e);
		}
		return msg;
	}

// Implementation

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

	private void log(String msg) {
		logMsg = msg;
	}

	private String hostName = "";
	private int port = -1;
	private String logMsg;
	private URLConnection connection;

	private String servletPath = "/mas_webapp1/hello";
	private String serverAddress = null;
}
