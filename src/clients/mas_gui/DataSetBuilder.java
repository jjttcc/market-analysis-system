/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.util.*;
import common.*;
import graph.*;
import support.*;
import application_support.*;
import application_library.*;

/** Abstraction responsible for managing a connection and building DataSet
    instances from data returned from connection requests */
public class DataSetBuilder implements NetworkProtocol {

	// Precondition: conn != null && opts != null
	public DataSetBuilder(Connection conn, StartupOptions opts) {
//		assert conn != null && opts != null;
		connection_ = conn;
		options = opts;
		try {
			initialize();
		} catch (Exception e) {}
	}

	public DataSetBuilder(DataSetBuilder dsb) {
		try {
			connection_ = dsb.connection().new_object();
			options = dsb.options;
			initialize();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
		}
	}

	public Connection connection() {
		return connection_;
	}

	// Does the last received market data contain an open interest field?
	public boolean open_interest() {
		return _open_interest;
	}

	// Send a logout request to the server to end the current session
	// and, if `exit' is true, exit with `status'.
	public void logout(boolean exit, int status) {
		try {
			connection_.logout();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
		}
		if (exit) Configuration.terminate(status);
	}

	// Send a request for data for market `symbol' with `period_type'.
	public void send_market_data_request(String symbol, String period_type)
			throws Exception {
		connection_.send_request(Market_data_request,
			symbol + Message_field_separator + period_type);
		if (connection_.last_received_message_ID() == OK) {
			String results = connection_.result().toString();
			results = setup_parser_fieldspecs(results);
			data_parser.parse(results, main_drawer);
			_last_market_data = data_parser.result();
			_last_market_data.set_drawer(main_drawer);
			_last_volume = data_parser.volume_result();
			if (_last_volume != null) {
				_last_volume.set_drawer(volume_drawer);
			}
			_last_open_interest = data_parser.open_interest_result();
			if (_last_open_interest != null) {
				_last_open_interest.set_drawer(open_interest_drawer);
			}
		}
	}

	// Send a request for data for indicator `ind' for market `symbol' with
	// `period_type'.
	public void send_indicator_data_request(int ind, String symbol,
		String period_type) throws Exception {
		connection_.send_request(Indicator_data_request,
			ind + Message_field_separator + symbol +
			Message_field_separator + period_type);
		// Note that a new indicator drawer is created each time parse is
		// called, since indicator drawers should not be shared.
		indicator_parser.parse(connection_.result().toString(),
								new_indicator_drawer());
		_last_indicator_data = indicator_parser.result();
	}

	// Send a request for the list of indicators for tradable `symbol'.
	public void send_indicator_list_request(String symbol,
			String period_type) throws IOException {
		StringBuffer mlist;
		_last_indicator_list = new Vector();
		connection_.send_request(Indicator_list_request, symbol +
			Message_field_separator + period_type);
		mlist = connection_.result();
		StringTokenizer t = new StringTokenizer(mlist.toString(),
			Message_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			_last_indicator_list.addElement(t.nextToken());
		}
	}

	// Data from last market data request
	public DataSet last_market_data() {
		return _last_market_data;
	}

	// Data from last indicator data request
	public DataSet last_indicator_data() {
		return _last_indicator_data;
	}

	// Volume data from last market data request
	public DataSet last_volume() {
		return _last_volume;
	}

	// Open interest data from last market data request
	public DataSet last_open_interest() {
		return _last_open_interest;
	}

	// Last requested indicator list
	public Vector last_indicator_list() {
		return _last_indicator_list;
	}

	// List of available tradables
	public Vector tradable_list() throws IOException {
		StringBuffer mlist;

		if (tradables == null) {
			tradables = new Vector();
			connection_.send_request(Market_list_request, "");
			mlist = connection_.result();
			StringTokenizer t = new StringTokenizer(mlist.toString(),
				Message_record_separator, false);
			for (int i = 0; t.hasMoreTokens(); ++i) {
				tradables.addElement(t.nextToken());
			}
		}
		return tradables;
	}

	// List of all valid trading period types for `tradable'
	public Vector trading_period_type_list(String tradable) throws IOException {
		StringBuffer tpt_list;
		Vector result;

		result = new Vector();
		connection_.send_request(Trading_period_type_request, tradable);
		tpt_list = connection_.result();
		StringTokenizer t = new StringTokenizer(tpt_list.toString(),
			Message_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i) {
			result.addElement(t.nextToken());
		}
		return result;
	}

	// Message ID of last response from the server
	public int request_result_id() {
		return connection_.last_received_message_ID();
	}

	// Result of the last request to the server
	public String server_response() {
		String result = null;
		if (connection_.result() != null) {
			result = connection_.result().toString();
		}
		return result;
	}

	// Did the login process fail?
	public boolean login_failed() {
		return login_failed_;
	}

// Implementation

	private MarketDrawer new_main_drawer() {
		MA_Configuration c = MA_Configuration.application_instance();
		MarketDrawer result;

		if (c.main_graph_drawer() == c.Candle_graph) {
			result = new CandleDrawer();
		} else if (c.main_graph_drawer() == c.Regular_graph) {
			result = new PriceDrawer();
		} else {
			result = new PriceDrawer();
		}
		return result;
	}

	private IndicatorDrawer new_indicator_drawer() {
		if (main_drawer == null) {
			System.err.println("Code defect: main_drawer is null");
			Configuration.terminate(-2);
		}
		return new LineDrawer(main_drawer);
	}

	// Initialize main_field_specs - Include Parser.Open_interest if
	// `_open_interest' is true.
	// Precondition: main_field_specs.length >= 7
	private void initialize_fieldspecs() {
		int i = 0;
		MA_SessionState session_state =
			(MA_SessionState) connection_.session_state();
		for (int j = 0; j < main_field_specs.length; ++j) {
			main_field_specs[j] = Parser.Not_set;
		}
		main_field_specs[i++] = Parser.Date;
		if (session_state.open_field()) {
			main_field_specs[i++] = Parser.Open;
		}
		main_field_specs[i++] = Parser.High;
		main_field_specs[i++] = Parser.Low;
		main_field_specs[i++] = Parser.Close;
		main_field_specs[i++] = Parser.Volume;
		if (_open_interest) {
			main_field_specs[i++] = Parser.Open_interest;
		}
	}

	// Login to the server and initialize fields.
	// Precondition: connection_ != null && ! connection_.logged_in()
	// Postcondition: connection_.logged_in()
	private void initialize() throws Exception {
		tradables = options.symbols();
		login_failed_ = true;
		try {
			connection_.login();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
			throw e;
		}
		_open_interest = false;
		initialize_fieldspecs();
		data_parser = new Parser(main_field_specs, Message_record_separator,
									Message_field_separator);
		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		int indicator_field_specs[] = new int[2];
		indicator_field_specs[0] = Parser.Date;
		indicator_field_specs[1] = Parser.Close;
		indicator_parser = new Parser(indicator_field_specs,
			Message_record_separator, Message_field_separator);
		main_drawer = new_main_drawer();
		volume_drawer = new BarDrawer(main_drawer);
		data_parser.set_volume_drawer(volume_drawer);
		open_interest_drawer = new LineDrawer(main_drawer);
		data_parser.set_open_interest_drawer(open_interest_drawer);
		login_failed_ = false;
	}

	// Use `data' to determine whether there is an open-interest field
	// and, if necessary, set data_parser's field specs accordingly.
	// Precondition: data != null
	String setup_parser_fieldspecs(String data) {
		String result = data;
		boolean oi = false;
		String firstrecord = "";
		if (data.length() >= Open_interest_flag.length()) {
			firstrecord = data.substring(0, Open_interest_flag.length());
			if (firstrecord.substring(0, Open_interest_flag.length()).equals(
					Open_interest_flag)) {
				oi = true;
				result = data.substring(Open_interest_flag.length());
			}
		}
		if (oi) {
			if (! _open_interest) {
				_open_interest = true;
				initialize_fieldspecs();
				data_parser.set_field_specifications(main_field_specs);
			}
		} else {
			if (_open_interest) {
				_open_interest = false;
				initialize_fieldspecs();
				data_parser.set_field_specifications(main_field_specs);
			}
		}

		return result;
	}

	// tradables is shared by all windows
	private static Vector tradables;	// Cached list of tradables

	private Connection connection_;
		// result of last market data request
	private DataSet _last_market_data;
		// volume result from last market data request
	private DataSet _last_volume;
		// open interest result from last market data request
	private DataSet _last_open_interest;
		// result of last indicator data request
	private DataSet _last_indicator_data;
		// result of last indicator list request
	private Vector _last_indicator_list;
	private Parser data_parser;
	private Parser indicator_parser;
	private MarketDrawer main_drawer;	// draws data in main graph
	private IndicatorDrawer volume_drawer;	// draws volume data
	private IndicatorDrawer open_interest_drawer;	// draws open-interest
	private int main_field_specs[] = new int[7];
	// Does the last received market data contain an open interest field?
	private boolean _open_interest;
	// User-specified options
	private StartupOptions options;
	private boolean login_failed_;
}
