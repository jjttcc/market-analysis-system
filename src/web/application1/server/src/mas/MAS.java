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
import support.ServerResponseUtilities;

public final class MAS extends GenericServlet {

	public void service(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		String client_msg = null, server_response = null;
		try {
			log("(Version 1.2) Connected");
			log("Forwarding request to the server.");
			proxy().forward(request.getReader());
			log("Message forwarded.");
			server_response = proxy().response();
			log("Server responded with: " + server_response);
			send_response(response, server_response);
		} catch (Exception e) {
			//!!!Make production-ready.
			log("Exception caught in 'service':\n", e);
			send_response(response,
				ServerResponseUtilities.warning_response_message(
				"Failed to connect to the server: " + e.getMessage()));
		}
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
			log("Creating proxy_");
			proxy_ = new MAS_Proxy(new IO_SocketConnection(
				server_address().hostname(), server_address().port_number()));
			log("proxy_ created");
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
