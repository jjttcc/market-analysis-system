import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import graph.*;
import support.*;

/** Provides an interface for connecting and communicating with the server */
public class MA_Connection implements NetworkProtocol
{
	// args[0]: hostname, args[1]: port_number
	public MA_Connection(String[] args)
	{
		int field_specs[] = new int[6];
		// Hard-code these for now:
		field_specs[0] = MA_Parser.Date;
		field_specs[1] = MA_Parser.Open;
		field_specs[2] = MA_Parser.High;
		field_specs[3] = MA_Parser.Low;
		field_specs[4] = MA_Parser.Close;
		field_specs[5] = MA_Parser.Volume;
		data_parser = new MA_Parser(field_specs, Output_record_separator,
									Output_field_separator);
		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		field_specs = new int[2];
		field_specs[0] = MA_Parser.Date;
		field_specs[1] = MA_Parser.Close;
		indicator_parser = new MA_Parser(field_specs, Output_record_separator,
									Output_field_separator);
		scanner = new DataInspector();
		main_drawer = new_main_drawer();
		volume_drawer = new BarDrawer(main_drawer);
		data_parser.set_volume_drawer(volume_drawer);
		//Process args for the host, port.
		if (args.length > 0)
		{
			_hostname = args[0];
			if (args.length > 1)
			{
				_port_number = new Integer(_port_number.parseInt(args[1]));
			}
			else
			{
				_port_number = new Integer(33333);
			}
		}
		else
		{
			usage();
			System.exit(1);
		}
	}

	public String hostname() { return _hostname; }

	public Integer port_number() { return _port_number; }

	// Send a request for a login session key.
	// Postcondition: The key value received from the server is returned.
	public int send_login_request()
	{
		String session_key_str = "";
		int session_key = 0;
		Configuration conf = Configuration.instance();

		connect();
		send_msg(Login_request, conf.session_settings(), 0);
		try {
			session_key_str = receive_msg().toString();
		}
		catch (Exception e) {
			System.err.println("Fatal error: attempt to login to server " +
				"failed");
			System.exit(-1);
		}
		try {
			session_key = Integer.valueOf(session_key_str).intValue();
		}
		catch (Exception e) {
			System.err.println("Fatal error: received invalid key from " +
				"server: " + session_key_str);
			System.exit(-1);
		}

		return session_key;
	}

	// Send a logout request to the server to end the current session
	// and, if `exit' is true, exit with `status'.
	public void logout(boolean exit, int status, int session_key)
	{
		connect();
		send_msg(Logout_request, "", session_key);
		if (exit) System.exit(status);
	}

	// Send a request for data for market `symbol' with `period_type'.
	public void send_market_data_request(String symbol, String period_type,
			int session_key)
		throws Exception
	{
		connect();
		send_msg(Market_data_request, symbol + Input_field_separator +
					period_type, session_key);
		data_parser.parse(receive_msg().toString(), main_drawer);
		_last_market_data = data_parser.result();
		_last_market_data.set_drawer(main_drawer);
		_last_volume = data_parser.volume_result();
		if (_last_volume != null) {
			_last_volume.set_drawer(volume_drawer);
		}
		close_connection();
	}

	// Send a request for data for indicator `ind' for market `symbol' with
	// `period_type'.
	public void send_indicator_data_request(int ind, String symbol,
		String period_type, int session_key) throws Exception
	{
		connect();
		send_msg(Indicator_data_request, ind + Input_field_separator +
				symbol + Input_field_separator + period_type, session_key);
		// Note that a new indicator drawer is created each time parse is
		// called, since indicator drawer's should not be shared.
		indicator_parser.parse(receive_msg().toString(),
								new_indicator_drawer());
		_last_indicator_data = indicator_parser.result();
		close_connection();
	}

	// Send a request for the list of indicators for market `symbol'.
	public void send_indicator_list_request(String symbol,
		int session_key) throws IOException
	{
		StringBuffer mlist;
		_last_indicator_list = new Vector();
		connect();
		send_msg(Indicator_list_request, symbol, session_key);
		mlist = receive_msg();
		close_connection();
		StringTokenizer t = new StringTokenizer(mlist.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			_last_indicator_list.addElement(t.nextToken());
		}
	}

	// Data from last market data request
	public DataSet last_market_data()
	{
		return _last_market_data;
	}

	// Data from last indicator data request
	public DataSet last_indicator_data()
	{
		return _last_indicator_data;
	}

	// Volume data from last market data request
	public DataSet last_volume()
	{
		return _last_volume;
	}

	// Last requested indicator list
	public Vector last_indicator_list()
	{
		return _last_indicator_list;
	}

	// List of markets available from the server
	public Vector market_list(int session_key) throws IOException
	{
		StringBuffer mlist;

		if (markets == null)
		{
			markets = new Vector();
			connect();
			send_msg (Market_list_request, "", session_key);
			mlist = receive_msg();
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

	// List of all valid trading period types for `market'
	public Vector trading_period_type_list(String market,
			int session_key) throws IOException {
		StringBuffer tpt_list;
		Vector result;

		result = new Vector();
		connect();
		send_msg(Trading_period_type_request, market, session_key);
		tpt_list = receive_msg();
		close_connection();
		StringTokenizer t = new StringTokenizer(tpt_list.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			result.addElement(t.nextToken());
		}
		return result;
	}

// Implementation

	StringBuffer receive_msg() throws IOException
	{
		char c;
		StringBuffer result;

		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (last_rec_msgID == Error)
		{
			result = new StringBuffer("Fatal request protocol error: ");
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

		if (last_rec_msgID == Error)
		{
			System.err.println(result);
			// This error means there is a problem with the protocol of the
			// last request passed to the server.  Since this is a coding
			// error (probably in the client), it is treated as fatal.
			System.exit(-1);
		}
//System.out.println(result.toString());
		return result;
	}

	// Send the `msgID', the session key, and `msg' - with field delimiters.
	void send_msg (int msgID, String msg, int session_key)
	{
		out.print(msgID);
		out.print(Input_field_separator + session_key);
		out.print(Input_field_separator + msg);
		out.print(Eom);
		out.flush();
	}

	void close_connection() throws IOException
	{
		out.close(); in.close(); socket.close();
	}

	private void connect()
	{
		try
		{
			//It appears that the only way to connect a client socket is
			//to create a new one!
			socket = new Socket(_hostname, _port_number.intValue());
			out = new PrintWriter(socket.getOutputStream(), true);
			in = new BufferedReader(
						new InputStreamReader(socket.getInputStream()));
			scanner.setReader(in);
		}
		catch (UnknownHostException e)
		{
			System.err.println("Don't know about host: ");
			System.err.println(_hostname);
			System.exit(1);
		}
		catch (IOException e)
		{
			System.err.println("Couldn't get I/O for the connection to: " +
								_hostname);
			System.exit(1);
		}
	}

	private Drawer new_main_drawer() {
		Configuration c = Configuration.instance();
		Drawer result;

		switch (c.main_graph_drawer()) {
			case c.Candle_graph: result = new CandleDrawer(); break;
			case c.Regular_graph: result = new PriceDrawer(); break;
			default: result = new PriceDrawer(); break;
		}
		return result;
	}

	private Drawer new_indicator_drawer() {
		if (main_drawer == null) {
			System.out.println("Code defect: main_drawer is null");
			System.exit(-2);
		}
		return new LineDrawer(main_drawer);
	}

	private void usage()
	{
		System.err.println("Usage: MA_Client hostname port_number");
	}

	private String _hostname;
	private Integer _port_number;
	private Socket socket;			// socket connection to server
	private PrintWriter out;		// output to server via socket
	private BufferedReader in;		// input from server via socket
	private DataInspector scanner;	// for scanning server messages
	private int last_rec_msgID;		// last message ID received from server
	private Vector markets;			// Cached list of markets
		// result of last market data request
	private DataSet _last_market_data;
		// volume result from last market data request
	private DataSet _last_volume;
		// result of last indicator data request
	private DataSet _last_indicator_data;
		// result of last indicator list request
	private Vector _last_indicator_list;
	private MA_Parser data_parser;
	private MA_Parser indicator_parser;
	private Drawer main_drawer;		// draws tuples in main graph
	private Drawer volume_drawer;	// draws volume tuples
}
