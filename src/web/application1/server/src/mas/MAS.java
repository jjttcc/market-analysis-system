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

public final class MAS extends GenericServlet {

	public void service(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		String clientMsg = null;
		try {
			log("Connected");
			log("Reading data...");
			clientMsg = input_string(request.getReader());
			log("Finished reading.");
			log("Received \"" + clientMsg + "\"");
			log("[Complete.]");
			sendResponse(response, "You said: " + clientMsg);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

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

	private void sendResponse(ServletResponse response, String msg) {
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

	public void Oldservice(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		ObjectInputStream input = null;
		String clientMsg = null;
		try {
			input = new ObjectInputStream(request.getInputStream());
			log("Connected");
			log("Reading data...");
			clientMsg = (String) input.readObject();
			log("Finished reading.");
			input.close();
			log("Received " + clientMsg);
			log("[Complete.]");
			sendResponse(response, "You said: " + clientMsg);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

// Implementation

	private void OldsendResponse(ServletResponse response, String msg) {
		ObjectOutputStream outputStream;
		try {
			outputStream = new ObjectOutputStream(response.getOutputStream());
			log("Sending message " + msg + " to client");
			outputStream.writeObject(msg);
			outputStream.flush();
			outputStream.close();
			log("Data transmission complete.");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
