/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.io.*;
import java.util.*;
import java_library.support.*;
import support.*;
import common.NetworkProtocol;
import graph_library.DataSet;

/**
* Abstraction for managing a connection and building DataSet
* instances from data returned from connection requests
**/
abstract public class AbstractDataSetBuilder extends Lockable
	implements NetworkProtocol, AssertionConstants {

// Initialization

	/**
	* Precondition: conn != null && opts != null
	**/
	public AbstractDataSetBuilder(Connection conn, StartupOptions opts) {
		assert conn != null && opts != null: PRECONDITION;
		connection = conn;
		options = opts;
		try {
			initialize();
		} catch (Exception e) {}
	}

	public AbstractDataSetBuilder(AbstractDataSetBuilder dsb) {
		try {
			connection = dsb.connection().new_object();
			options = dsb.options;
			initialize();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
		}
	}

// Access

	/**
	* The current connection to the server
	**/
	public Connection connection() {
		return connection;
	}

	/**
	* Data from last market data request
	**/
	public DataSet last_market_data() {
		return last_market_data;
	}

	/**
	* Data from last indicator data request
	**/
	public DataSet last_indicator_data() {
		return last_indicator_data;
	}

	/**
	* Volume data from last market data request
	**/
	public DataSet last_volume() {
		return last_volume;
	}

	/**
	* Open interest data from last market data request
	**/
	public DataSet last_open_interest() {
		return last_open_interest;
	}

	/**
	* Latest date-time from last market data request - null if no data
	* was received from the last request.
	**/
	public Calendar last_latest_date_time() {
		return last_latest_date_time;
	}

	/**
	* Last requested indicator list
	**/
	public Vector last_indicator_list() {
		return last_indicator_list;
	}

	/**
	* List of available tradables
	**/
	public Vector tradable_list() throws IOException {
		StringBuffer mlist;

		if (tradables == null) {
			tradables = new Vector();
			connection.send_request(Market_list_request, "");
			mlist = connection.result();
			StringTokenizer t = new StringTokenizer(mlist.toString(),
				Message_record_separator, false);
			for (int i = 0; t.hasMoreTokens(); ++i) {
				tradables.addElement(t.nextToken());
			}
		}
		return tradables;
	}

	/**
	* List of all valid trading period types for `tradable'
	**/
	public Vector trading_period_type_list(String tradable) throws IOException {
		StringBuffer tpt_list;
		Vector result;

		result = new Vector();
		connection.send_request(Trading_period_type_request, tradable);
		tpt_list = connection.result();
		StringTokenizer t = new StringTokenizer(tpt_list.toString(),
			Message_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i) {
			result.addElement(t.nextToken());
		}
		return result;
	}

	/**
	* Message ID of last response from the server
	**/
	public int request_result_id() {
		return connection.last_received_message_ID();
	}

	/**
	* Result of the last request to the server
	**/
	public String server_response() {
		String result = null;
		if (connection.result() != null) {
			result = connection.result().toString();
		}
		return result;
	}

// Status report

	/**
	* Did the login process fail?
	**/
	public boolean login_failed() {
		return login_failed;
	}

	/**
	* Does the last received market data contain an open interest field?
	**/
	public boolean has_open_interest() {
		return open_interest;
	}

	/**
	* Did the last data request succeed?
	**/
	public boolean request_succeeded() {
		return ! io_error_occurred && request_result_id() == Ok;
	}

// Basic operations

	/**
	* Send a logout request to the server to end the current session
	* and, if `exit' is true, exit with `status'.
	**/
	public void logout(boolean exit, int status) {
		try {
			connection.logout();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
		}
		if (exit) Configuration.terminate(status);
	}

	/**
	* Send a request for data for the tradable `symbol' with `period_type'.
	* Postcondition: request_succeeded() implies last_market_data() != null
	**/
	public void send_market_data_request(String symbol, String period_type)
			throws Exception {

		dispatch_market_data_request(Market_data_request, symbol,
			period_type, null, false);
	}

	/**
	* Send a request for data for indicator `ind' for the tradable
	* `symbol' with `period_type'.
	* Postcondition: request_succeeded() implies last_indicator_data() != null
	**/
	public void send_indicator_data_request(int ind, String symbol,
		String period_type) throws Exception {

		dispatch_indicator_data_request(Indicator_data_request, ind, symbol,
			period_type, null, false);
	}

	/**
	* Send a time-delimited request for data for the tradable `symbol' with
	* `period_type' with the date-time range `start_date_time' ..
	* `end_date_time'.  If `end_date_time' is null, the current date-time
	* is used.
	* Postcondition: request_succeeded() implies last_market_data() != null
	**/
	public void send_time_delimited_market_data_request(String symbol,
		String period_type, Calendar start_date_time, Calendar end_date_time)
			throws Exception {

		dispatch_market_data_request(Time_delimited_market_data_request,
			symbol, period_type, nwutil.date_time_range(start_date_time,
			end_date_time), true);
	}

	/**
	* Send a time-delimited request for data for indicator `ind' for
	* the tradable `symbol' with `period_type' with the date-time range
	* `start_date_time' .. `end_date_time'.  If `end_date_time' is null,
	* the current date-time is used.
	* Postcondition: request_succeeded() implies last_indicator_data() != null
	**/
	public void send_time_delimited_indicator_data_request(int ind,
		String symbol, String period_type, Calendar start_date_time,
		Calendar end_date_time) throws Exception {

		dispatch_indicator_data_request(Time_delimited_indicator_data_request,
			ind, symbol, period_type,
			nwutil.date_time_range(start_date_time, end_date_time), true);
	}

	/**
	* Send a request for the list of indicators for tradable `symbol'.
	**/
	public void send_indicator_list_request(String symbol,
			String period_type) throws IOException {

		StringBuffer mlist;
		last_indicator_list = new Vector();
		connection.send_request(Indicator_list_request, symbol +
			Message_field_separator + period_type);
		mlist = connection.result();
		StringTokenizer t = new StringTokenizer(mlist.toString(),
			Message_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			last_indicator_list.addElement(t.nextToken());
		}
	}

// Hook routines

	// Perform any needed "post initialization".
	// Precondition: data_parser != null && indicator_parser != null
	protected void postinit() {
		// do nothing - redefine if needed.
	}

	// Perform any needed post processing on `data', the parsed result of
	// of a market data request.
	// `is_update' indicates whether `data' is the result of an update of
	// existing data (as opposed to a fresh set of data for a new tradable).
	abstract protected void post_process_market_data(DataSet data,
		String symbol, String period_type, boolean is_update);

	// Perform any needed post processing on `data', the parsed
	//  volume-data result of of a market data request.
	// `is_update' indicates whether `data' is the result of an update of
	// existing data (as opposed to a fresh set of data for a new tradable).
	abstract protected void post_process_volume_data(DataSet data,
		String symbol, String period_type, boolean is_update);

	// Perform any needed post processing on `data', the parsed
	//  open-interest-data result of of a market data request.
	// `is_update' indicates whether `data' is the result of an update of
	// existing data (as opposed to a fresh set of data for a new tradable).
	abstract protected void post_process_open_interest_data(DataSet data,
		String symbol, String period_type, boolean is_update);

	// Perform any needed post processing on `data', the parsed result of
	// of an indicator data request.
	// `is_update' indicates whether `data' is the result of an update of
	// existing data (as opposed to a fresh set of data for a new tradable).
	abstract protected void post_process_indicator_data(DataSet data,
		String symbol, String period_type, boolean is_update);

	protected void prepare_parser_for_market_data() {
		// do nothing - redefine if needed.
	}

	protected void prepare_parser_for_indicator_data() {
		// do nothing - redefine if needed.
	}

	abstract protected AbstractParser new_main_parser();

	abstract protected AbstractParser new_indicator_parser(int [] field_specs);

// Implementation

	// Dispatch the data request for tradable with `symbol', `period_type',
	// and, optionally, `appendix' to the server and parse and process
	// the result.
	// `is_update' indicates whether the request is for an update of existing
	// data (as opposed to being for a fresh set of data for a new tradable).
	public void dispatch_market_data_request(int request_id, String symbol,
			String period_type, String appendix, boolean is_update)
			throws Exception {

		io_error_occurred = false;
		String request = symbol + Message_field_separator + period_type;
		if (appendix != null && appendix.length() > 0) {
			request += Message_field_separator + appendix;
		}
		try {
			connection.send_request(request_id, request);
		} catch (IOException e) {
			io_error_occurred = true;
//!!!:			if (Configuration.debug()) {
				System.err.println("[Error: " + e + "]");
//			}
		}
		if (! io_error_occurred &&
				connection.last_received_message_ID() == Ok) {

			String results = connection.result().toString();
			results = setup_parser_fieldspecs(results);
			prepare_parser_for_market_data();
			data_parser.parse(results, is_update);
			last_market_data = data_parser.result();
			post_process_market_data(last_market_data, symbol, period_type,
				is_update);
			last_volume = data_parser.volume_result();
			if (last_volume != null) {
				post_process_volume_data(last_volume, symbol, period_type,
					is_update);
			}
			last_open_interest = data_parser.open_interest_result();
			if (last_open_interest != null) {
				post_process_open_interest_data(last_open_interest, symbol,
					period_type, is_update);
			}
			Calendar date = data_parser.latest_date_time();
			last_latest_date_time = date;
		}
	}

	// Dispatch the request for indicator data with indicator ID
	// `indicator_id' for tradable with `symbol', `period_type', and,
	// optionally, `appendix' to the server and parse and process the result.
	// `is_update' indicates whether the request is for an update of existing
	// data (as opposed to being for a fresh set of data for a new tradable).
	public void dispatch_indicator_data_request(int request_id,
			int indicator_id, String symbol, String period_type,
			String appendix, boolean is_update) throws Exception {

		io_error_occurred = false;
		String request = indicator_id + Message_field_separator + symbol +
			Message_field_separator + period_type;
		if (appendix != null && appendix.length() > 0) {
			request += Message_field_separator + appendix;
		}
		try {
			connection.send_request(request_id, request);
		} catch (IOException e) {
			io_error_occurred = true;
//!!!:			if (Configuration.debug()) {
				System.err.println("[Error: " + e + "]");
//			}
		}
		if (! io_error_occurred &&
				connection.last_received_message_ID() == Ok) {

			prepare_parser_for_indicator_data();
			indicator_parser.parse(connection.result().toString(), is_update);
			last_indicator_data = indicator_parser.result();
			post_process_indicator_data(last_indicator_data, symbol,
				period_type, is_update);
		}
	}

// Implementation - initialization

	// Initialize main_field_specs - Include AbstractParser.Open_interest if
	// `open_interest' is true.
	// Precondition: main_field_specs.length >= 7
	private void initialize_fieldspecs() {
		int i = 0;
		MA_SessionState session_state =
			(MA_SessionState) connection.session_state();
		for (int j = 0; j < main_field_specs.length; ++j) {
			main_field_specs[j] = AbstractParser.Not_set;
		}
		main_field_specs[i++] = AbstractParser.Date;
		if (session_state.open_field()) {
			main_field_specs[i++] = AbstractParser.Open;
		}
		main_field_specs[i++] = AbstractParser.High;
		main_field_specs[i++] = AbstractParser.Low;
		main_field_specs[i++] = AbstractParser.Close;
		main_field_specs[i++] = AbstractParser.Volume;
		if (open_interest) {
			main_field_specs[i++] = AbstractParser.Open_interest;
		}
	}

	// Login to the server and initialize fields.
	// Precondition: connection != null && ! connection.logged_in()
	// Postcondition: connection.logged_in()
	private void initialize() throws Exception {
		tradables = options.symbols();
		login_failed = true;
		try {
			connection.login();
		} catch (Exception e) {
			System.err.println(e);
			Configuration.terminate(1);
			throw e;
		}
		open_interest = false;
		initialize_fieldspecs();
		data_parser = new_main_parser();

		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		int indicator_field_specs[] = new int[2];
		indicator_field_specs[0] = AbstractParser.Date;
		indicator_field_specs[1] = AbstractParser.Close;
		indicator_parser = new_indicator_parser(indicator_field_specs);

		postinit();
		login_failed = false;
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
			if (! open_interest) {
				open_interest = true;
				initialize_fieldspecs();
				data_parser.set_field_specifications(main_field_specs);
			}
		} else {
			if (open_interest) {
				open_interest = false;
				initialize_fieldspecs();
				data_parser.set_field_specifications(main_field_specs);
			}
		}

		return result;
	}

// Implementation - attributes

	// tradables is shared by all windows
	protected static Vector tradables;	// Cached list of tradables

	protected Connection connection;

	private boolean io_error_occurred = false;

	// result of last market data request
	protected DataSet last_market_data;

	// volume result from last market data request
	protected DataSet last_volume;

	// open interest result from last market data request
	protected DataSet last_open_interest;

	// result of last indicator data request
	protected DataSet last_indicator_data;

	// result of last indicator list request
	protected Vector last_indicator_list;

	// latest date-time result from last market data request
	private Calendar last_latest_date_time;
	protected AbstractParser data_parser;
	protected AbstractParser indicator_parser;
	protected int main_field_specs[] = new int[7];

	// Does the last received market data contain an open interest field?
	private boolean open_interest;

	// User-specified options
	private StartupOptions options;
	private boolean login_failed;
	private static NetworkProtocolUtilities nwutil;
}
