/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import graph.*;
import support.*;

/** Abstraction responsible for managing a connection and building DataSet
    instances from data returned from connection requests */
public class DataSetBuilder implements NetworkProtocol
{
	// args[0]: hostname, args[1]: port_number
	public DataSetBuilder(String[] args) {
		String hostname = null;
		Integer port_number = null;
		//Process args for the host, port.
		if (args.length > 0)
		{
			hostname = args[0];
			if (args.length > 1)
			{
				port_number = new Integer(port_number.parseInt(args[1]));
			}
			else
			{
				port_number = new Integer(33333);
			}
		}
		else
		{
			usage();
			System.exit(1);
		}
		connection = new Connection(hostname, port_number);
		initialize();
		connection.login(Login_request);
	}

	public DataSetBuilder(DataSetBuilder dsb) {
		connection = new Connection(dsb.hostname(), dsb.port_number());
		initialize();
		connection.login(Login_request);
	}

	// Send a logout request to the server to end the current session
	// and, if `exit' is true, exit with `status'.
	public void logout(boolean exit, int status) {
		connection.logout(Logout_request);
		if (exit) System.exit(status);
	}

	// Send a request for data for market `symbol' with `period_type'.
	public void send_market_data_request(String symbol, String period_type)
			throws Exception {
		connection.send_request(Market_data_request,
			symbol + Input_field_separator + period_type);
		data_parser.parse(connection.result().toString(), main_drawer);
		_last_market_data = data_parser.result();
		_last_market_data.set_drawer(main_drawer);
		_last_volume = data_parser.volume_result();
		if (_last_volume != null) {
			_last_volume.set_drawer(volume_drawer);
		}
	}

	// Send a request for data for indicator `ind' for market `symbol' with
	// `period_type'.
	public void send_indicator_data_request(int ind, String symbol,
		String period_type) throws Exception
	{
		connection.send_request(Indicator_data_request,
			ind + Input_field_separator + symbol +
			Input_field_separator + period_type);
		// Note that a new indicator drawer is created each time parse is
		// called, since indicator drawers should not be shared.
		indicator_parser.parse(connection.result().toString(),
								new_indicator_drawer());
		_last_indicator_data = indicator_parser.result();
	}

	// Send a request for the list of indicators for market `symbol'.
	public void send_indicator_list_request(String symbol) throws IOException
	{
		StringBuffer mlist;
		_last_indicator_list = new Vector();
		connection.send_request(Indicator_list_request, symbol);
		mlist = connection.result();
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
	public Vector market_list() throws IOException
	{
		StringBuffer mlist;

		if (markets == null)
		{
			markets = new Vector();
			connection.send_request(Market_list_request, "");
			mlist = connection.result();
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
	public Vector trading_period_type_list(String market) throws IOException {
		StringBuffer tpt_list;
		Vector result;

		result = new Vector();
		connection.send_request(Trading_period_type_request, market);
		tpt_list = connection.result();
		StringTokenizer t = new StringTokenizer(tpt_list.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			result.addElement(t.nextToken());
		}
		return result;
	}

// Implementation

	private String hostname() { return connection.hostname(); }

	private Integer port_number() { return connection.port_number(); }

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

	private void usage() {
		System.err.println("Usage: MA_Client hostname port_number");
	}

	private void initialize() {
		int field_specs[] = new int[6];
		// Hard-code these for now:
		field_specs[0] = Parser.Date;
		field_specs[1] = Parser.Open;
		field_specs[2] = Parser.High;
		field_specs[3] = Parser.Low;
		field_specs[4] = Parser.Close;
		field_specs[5] = Parser.Volume;
		data_parser = new Parser(field_specs, Output_record_separator,
									Output_field_separator);
		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		field_specs = new int[2];
		field_specs[0] = Parser.Date;
		field_specs[1] = Parser.Close;
		indicator_parser = new Parser(field_specs, Output_record_separator,
									Output_field_separator);
		main_drawer = new_main_drawer();
		volume_drawer = new BarDrawer(main_drawer);
		data_parser.set_volume_drawer(volume_drawer);
	}

	private Connection connection;
	private Vector markets;			// Cached list of markets
		// result of last market data request
	private DataSet _last_market_data;
		// volume result from last market data request
	private DataSet _last_volume;
		// result of last indicator data request
	private DataSet _last_indicator_data;
		// result of last indicator list request
	private Vector _last_indicator_list;
	private Parser data_parser;
	private Parser indicator_parser;
	private Drawer main_drawer;		// draws tuples in main graph
	private Drawer volume_drawer;	// draws volume tuples
}
