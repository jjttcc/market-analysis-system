/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package mas;

// Remove any that are not needed:
import java.io.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.GenericServlet;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.ServletConfig;
import java_library.support.*;
import support.IO_SocketConnection;
import support.ServerResponseUtilities;

public final class MAS extends GenericServlet implements AssertionConstants {

	public void init() {
		proxy_cache = new ManagedCache();
	}

	public void service(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		String client_msg = null, server_response = null;
		MAS_Proxy mas_proxy = null;
		String tag = thread_tag();
		log("Starting 'service' thread " + tag);
		try {
			log_tag("(Version 1.4) Connected", tag);
			log("Compiled at Fri Feb 21 22:37:18 MST 2003");
			log_tag("Reserving a proxy.", tag);
			mas_proxy = reserved_proxy();
			log_tag("Obtained proxy with code " + mas_proxy.hashCode(), tag);
			log_tag("Forwarding request to the server.", tag);
			mas_proxy.forward(request.getReader());
			log_tag("Message forwarded.", tag);
			server_response = mas_proxy.response();
			log_tag("Server responded with: " + snippet(server_response), tag);
			send_response(response, server_response);
		} catch (Throwable e) {
			log("Exception caught in 'service':\n", e);
			send_response(response,
				ServerResponseUtilities.warning_response_message(
				"Failed to connect to the server: " + e.getMessage()));
		} finally {
			if (mas_proxy != null) {
				proxy_cache.release(mas_proxy);
				log_tag("Released proxy with code " + mas_proxy.hashCode(),
					tag);
			}
		}
		log("Ending 'service' thread " + tag);
	}

// Implementation

	// Send 'msg' to the client via "response"'s output stream.
	private void send_response(ServletResponse response, String msg) {
		try {
			PrintWriter writer =
				new PrintWriter(response.getOutputStream(), true);
			log("Sending message \"" + snippet(msg) + "\" to client");
			writer.print(msg);
			writer.flush();
			writer.close();
			log("Data transmission complete.");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	// MAS_Proxy reserved for this thread
	// Postcondition: reserved: result != null && proxy_cache.reserved(result)
	private MAS_Proxy reserved_proxy() {
		log("MAS servlet reserving a proxy");
		MAS_Proxy result = null;
		if (proxy_cache.size() < Max_cache_size) {
			// There's room for another proxy - make one and insert it into
			// the table as "in-use".
			result = new MAS_Proxy(new IO_SocketConnection(
				server_address().hostname(), server_address().port_number()));
			// Mark 'result' as in-use.
			proxy_cache.extend_reserved(result);
			log("Proxy with hashcode " + result.hashCode() + " created");
		} else {
			// The table is full - obtain the first available proxy.
			result = (MAS_Proxy) proxy_cache.item();
		}
		assert proxy_cache.size() <= Max_cache_size: ASSERTION;
		assert result != null && proxy_cache.reserved(result): POSTCONDITION;
		return result;
	}

	// Address information for the locating the MAS server
	private ServerAddress server_address() {
		if (server_address_ == null) {
			ServletConfig config = getServletConfig();
			String srvr_hostnm = config.getInitParameter(
				Server_hostname_parameter_name);
			if (srvr_hostnm == null) {
				srvr_hostnm = Default_server_hostname;
			}
			String srvr_port = config.getInitParameter(
				Server_port_parameter_name);
			int srvr_port_value = -1;
			if (srvr_port != null) {
				try {
					srvr_port_value = new Integer(srvr_port).intValue();
				} catch (Exception e) {
					srvr_port_value = Default_server_port;
					log("Invalid port number specified for parameter " +
						Server_port_parameter_name + ": " + srvr_port);
				}
			}
			if (srvr_port_value == -1) {
				srvr_port_value = Default_server_port;
			}
			server_address_ = new ServerAddress(srvr_hostnm, srvr_port_value);
			log("Using server hostname/port: " + srvr_hostnm + ", " +
				srvr_port_value);
		}
		return server_address_;
	}

// Implementation - debugging

	int Msglength_limit = 1024;

	// "Snippet" from message, for debugging
	private String snippet(String msg) {
		int msg_end = msg.length() > Msglength_limit?
			Msglength_limit: msg.length();
		return msg.substring(0, msg_end);
	}

	// Log 'msg' with the specified tag.
	private void log_tag(String msg, String thread_tag) {
		log("(thread tag " + thread_tag + ") " + msg);
	}

	private Integer tagnumber = new Integer(0);

	// Tag for the current thread, for debugging
	private synchronized String thread_tag() {
		tagnumber = new Integer(tagnumber.intValue() + 1);
		return tagnumber.toString();
	}

// Implementation - attributes

	// Address information used to connect to the MAS server
	private ServerAddress server_address_;

	// Cache of proxies for efficient response
	private ManagedCache proxy_cache;

// Implementation - constants

	// Maximum allowed size of 'proxy_cache'
	private final int Max_cache_size = 5;

	// Name of MAS server machine hostname initialization parameter
	private final String Server_hostname_parameter_name = "mas-server-hostname";

	// Name of MAS server port initialization parameter
	private final String Server_port_parameter_name = "mas-server-port";

	// Default MAS server hostname, in case init. parameter not set
	private final String Default_server_hostname = "localhost";

	// Default MAS server port, in case init. parameter not set
	private final int Default_server_port = 2004;
}
