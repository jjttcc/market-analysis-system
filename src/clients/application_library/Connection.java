import java.io.*;
import java.net.*;
import java.util.*;

public class TA_Connection implements NetworkProtocol
{
	TA_Connection(String[] args)
	{
		scanner = new DataInspector();
		//Process args for the host, port.
		//!!This is probably not quite right:
		if (args.length > 0)
		{
			hostname = args[0];
			if (args.length > 1)
			{
				port_number.parseInt (args[1]);
			}
		}
	}

	// Send a request for data for market `symbol' with `period_type'.
	public void send_market_data_request(String symbol, String period_type)
		throws IOException
	{
		connect();
		// Send Market_data_request, with symbol - for weekly data.
		send_msg(Market_data_request, symbol + Input_field_separator +
					period_type);
		_last_market_data = receive_msg(in);
		close_connection();
	}

	// Send a request for data for indicator `ind' for market `symbol' with
	// `period_type'.
	public void send_indicator_data_request(String ind, String symbol,
		String ptype) throws IOException
	{
		connect();
		// Send Indicator_data_request, for ind, symbol - for weekly data.
		send_msg(Indicator_data_request, ind + Input_field_separator +
					symbol + Input_field_separator + ptype);
		_last_indicator_data = receive_msg(in);
		close_connection();
	}

	// Send a request for the list of indicators for market `symbol'.
	public void send_indicator_list_request(String symbol) throws IOException
	{
		StringBuffer mlist;
		_last_indicator_list = new Vector();
		connect();
		// Send Indicator_list_request for symbol.
		send_msg(Indicator_list_request, symbol);
		mlist = receive_msg(in);
		close_connection();
		StringTokenizer t = new StringTokenizer(mlist.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			_last_indicator_list.addElement(t.nextToken());
		}
	}

	// Data from last market data request
	public StringBuffer last_market_data()
	{
		return _last_market_data;
	}

	// Data from last indicator data request
	public StringBuffer last_indicator_data()
	{
		return _last_indicator_data;
	}

	// Last requested indicator list
	public Vector last_indicator_list()
	{
		return _last_indicator_list;
	}

	// List of markets available from the server
	public Vector market_list() throws IOException
	{
		StringBuffer mlist;

		if (markets == null)
		{
			markets = new Vector();
			connect();
			// Send Market_list_request (and empty message body).
			send_msg (Market_list_request, "");
			mlist = receive_msg(in);
			close_connection();
			StringTokenizer t = new StringTokenizer(mlist.toString(),
				Output_record_separator, false);
			for (int i = 0; t.hasMoreTokens(); ++i)
			{
				markets.addElement(t.nextToken());
			}
		}
		return markets;
	}

	StringBuffer receive_msg (BufferedReader in) throws IOException
	{
		char c;
		StringBuffer result;

		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (last_rec_msgID == Error)
		{
			result = new StringBuffer("Error: ");
		}
		else
		{
			result = new StringBuffer();
		}
		do
		{
			c = (char) in.read();
			if (c == '') break;
			result.append(c);
		} while (true);

		return result;
	}

	void send_msg (int msgID, String msg)
	{
		out.print(msgID);
		out.print(Input_field_separator + msg);
		out.print(Eom);
		out.flush();
	}

	void close_connection() throws IOException
	{
		out.close(); in.close(); echoSocket.close();
	}

	private void connect()
	{
		try
		{
			//It appears that the only way to connect a client socket is
			//to create a new one!
			echoSocket = new Socket(hostname, port_number.intValue());
			out = new PrintWriter(echoSocket.getOutputStream(), true);
			in = new BufferedReader(
						new InputStreamReader(echoSocket.getInputStream()));
			scanner.setReader(in);
		}
		catch (UnknownHostException e)
		{
			System.err.println("Don't know about host:");
			System.err.println(hostname);
			System.exit(1);
		}
		catch (IOException e)
		{
			System.err.println("Couldn't get I/O for the connection to:");
			System.err.println(hostname);
			System.exit(1);
		}
	}

	private String hostname;
	private Integer port_number;
	private Socket echoSocket;		// socket connection to server
	private PrintWriter out;		// output to server via socket
	private BufferedReader in;		// input from server via socket
	private DataInspector scanner;	// for scanning server messages
	private int last_rec_msgID;		// last message ID received from server
	private Vector markets;		// Cached list of markets
		// result of last market data request
	private StringBuffer _last_market_data;
		// result of last indicator data request
	private StringBuffer _last_indicator_data;
		// result of last indicator list request
	private Vector _last_indicator_list;
}
