import java.io.*;
import java.net.*;

public class GUI_Client implements NetworkProtocol
{
	GUI_Client()
	{
		scanner = new DataInspector();
	}

	public void execute(String[] args) throws IOException
	{
		String hname = "jupiter.milkyway.org";
		Integer port_number = new Integer(22224);
		BufferedReader stdIn = new BufferedReader(
										new InputStreamReader(System.in));
		String symb, ind;

		if (args.length > 0)
		{
			hname = args[0];
			if (args.length > 1)
			{
				port_number.parseInt (args[1]);
			}
		}

		do
		{
			connect (hname, port_number);
			// Send Market_list_request (and empty message body).
			send_msg (Market_list_request, "");
			System.out.print ("Select symbol:\n");
			receive_msg(in);
			close_connection();

			symb = stdIn.readLine();
			if (symb == null || symb.equals ("")) break;

			connect (hname, port_number);
			// Send Market_data_request, with symb - for weekly data.
			send_msg(Market_data_request, symb + "\tweekly");
			receive_msg(in);
			close_connection();

			connect (hname, port_number);
			// Send Indicator_list_request for symb.
			send_msg(Indicator_list_request, symb);
			System.out.print ("Select indicator:\n");
			receive_msg(in);
			//receive_market_data(in);
			close_connection();

			ind = stdIn.readLine();
			if (ind == null || ind.equals ("")) break;

			connect (hname, port_number);
			// Send Indicator_data_request, for ind, symb - for weekly data.
			send_msg(Indicator_data_request, ind + "\t" + symb + "\tweekly");
			receive_msg(in);
			close_connection();
		} while (true);

		stdIn.close();
	}

	void receive_msg (BufferedReader in) throws IOException
	{
		char c;

		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (last_rec_msgID == Error)
		{
			System.out.print("Error: ");
		}
		do
		{
			c = (char) in.read();
			if (c == '') break;
			System.out.print(c);
		} while (true);
		System.out.print(' ');
	}

//	void receive_market_data (BufferedReader in) throws IOException
//	{
//		char c;
//
//		scanner.getInt();
//		last_rec_msgID = scanner.lastInt();
//		if (last_rec_msgID == Error)
//		{
//			System.out.print("Error: ");
//		}
//		do
//		{
//			c = (char) in.read();
//			if (c == '') break;
//			System.out.print(c);
//		} while (true);
//		System.out.print(' ');
//	}

	void send_msg (int msgID, String msg)
	{
		out.print(msgID);
		out.print("\t" + msg);
		out.print(eom);
		out.flush();
	}

	void close_connection() throws IOException
	{
		out.close(); in.close(); echoSocket.close();
	}

	private void connect (String hname, Integer port_number)
	{
		try
		{
			//It appears that the only way to connect a client socket is
			//to create a new one!
			echoSocket = new Socket(hname, port_number.intValue());
			out = new PrintWriter(echoSocket.getOutputStream(), true);
			in = new BufferedReader(
						new InputStreamReader(echoSocket.getInputStream()));
			scanner.setReader(in);
		}
		catch (UnknownHostException e)
		{
			System.err.println("Don't know about host:");
			System.err.println(hname);
			System.exit(1);
		}
		catch (IOException e)
		{
			System.err.println("Couldn't get I/O for the connection to:");
			System.err.println(hname);
			System.exit(1);
		}
	}

	private Socket echoSocket;		// socket connection to server
	private PrintWriter out;		// output to server via socket
	private BufferedReader in;		// input from server via socket
	private DataInspector scanner;	// for scanning server messages
	private int last_rec_msgID;		// last message ID received from server
}
