/*
	* @version  $Revision$, $Date$.
	* @author   Jim Cochrane
*/

package masweb;

// Remove any that are not needed:
import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.GenericServlet;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

public final class Hello extends GenericServlet {

	protected void sendResponse(ServletResponse response, String msg) {
		ObjectOutputStream outputStream;
		try {
			outputStream = new ObjectOutputStream(response.getOutputStream());
			System.out.println("Sending message " + msg + " to client");
			outputStream.writeObject(msg);
			outputStream.flush();
			outputStream.close();
			System.out.println("Data transmission complete.");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void service(ServletRequest request,
			ServletResponse response)
			throws ServletException, IOException {
		ObjectInputStream input = null;
		String clientMsg = null;
		try {
			input = new ObjectInputStream(request.getInputStream());
			System.out.println("Connected");

			System.out.println("Reading data...");
			clientMsg = (String) input.readObject();
			System.out.println("Finished reading.");
			input.close();

			System.out.println("Received " + clientMsg);
			System.out.println("[Complete.]");
			sendResponse(response, "You said: " + clientMsg);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
