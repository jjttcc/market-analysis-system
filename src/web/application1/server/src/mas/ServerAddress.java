/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package mas;

// Network hostname and port number of the server process
public class ServerAddress {

	// Precondition: hostnm != null && port > 0
	public ServerAddress(String hostnm, int port) {
		assert hostnm != null && port > 0;

		hostname_ = hostnm;
		port_number_ = port;
	}

	public String hostname() {
		return hostname_;
	}

	public int port_number() {
		return port_number_;
	}

// Implementation

	private String hostname_;

	private int port_number_;
}
