/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package mas;

// Remove any that are not needed:
import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.GenericServlet;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import support.IO_SocketConnection;

public final class MAS extends GenericServlet {

	public void service(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		String client_msg = null, server_response = null;
		try {
			log("(Version 1.0) Connected");
			log("Reading data...");
			client_msg = input_string(request.getReader());
			log("Finished reading.");
			log("Received \"" + client_msg + "\"");
			log("Forwarding to mas server");
			proxy().forward(client_msg);
			server_response = proxy().response();
			send_response(response, "mas answered: " + server_response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

//!!!!!Move this to a utility class:
	String input_string(Reader r) throws IOException {
		char[] buffer = new char[16384];
		int c = 0, i = 0;
		do {
			c = r.read();
			buffer[i] = (char) c;
			++i;
		} while (c != -1);
		return new String(buffer, 0, i - 1);
	}

// Implementation

	private void send_response(ServletResponse response, String msg) {
		try {
			PrintWriter writer =
				new PrintWriter(response.getOutputStream(), true);
			log("Sending message \"" + msg + "\" to client");
			writer.print(msg);
			writer.flush();
			writer.close();
			log("Data transmission complete.");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private MAS_Proxy proxy() {
		if (proxy_ == null) {
			proxy_ = new MAS_Proxy(new IO_SocketConnection(
				server_address().hostname(), server_address().port_number()));
		}
		return proxy_;
	}

	private ServerAddress server_address() {
		if (server_address_ == null) {
//!!!!Stubbed for now - change soon:
			server_address_ = new ServerAddress("localhost", 2004);
		}
		return server_address_;
	}

	private MAS_Proxy proxy_;

	private ServerAddress server_address_;
}
