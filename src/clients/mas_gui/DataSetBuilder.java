/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.io.*;
import java.util.*;
import common.*;
import support.*;
import application_support.*;
import application_library.*;
import graph.*;
import graph_library.DataSet;

/** Data set builders that build "drawable" data sets */
public class DataSetBuilder extends AbstractDataSetBuilder {

// Initialization

	// Precondition: conn != null && opts != null
	public DataSetBuilder(Connection conn, StartupOptions opts) {
//		assert conn != null && opts != null;
		super(conn, opts);
	}

	public DataSetBuilder(DataSetBuilder dsb) {
		super(dsb);
	}

// Basic operations

	// Send a request for data for the tradable `symbol' with `period_type'.
/*
	public void send_market_data_request(String symbol, String period_type)
			throws Exception {
		connection.send_request(Market_data_request,
			symbol + Message_field_separator + period_type);
		if (connection.last_received_message_ID() == Ok) {
			String results = connection.result().toString();
			results = setup_parser_fieldspecs(results);
//!!!:data_parser.set_main_drawer(main_drawer);
//!!!Remove: data_parser.parse(results, main_drawer);
			data_parser.parse(results);
			last_market_data = (DrawableDataSet) data_parser.result();
			last_market_data.set_drawer(main_drawer);
			last_volume = (DrawableDataSet) data_parser.volume_result();
			if (last_volume != null) {
				last_volume.set_drawer(volume_drawer);
			}
			last_open_interest = (DrawableDataSet)
				data_parser.open_interest_result();
			if (last_open_interest != null) {
				last_open_interest.set_drawer(open_interest_drawer);
			}
			Calendar date = data_parser.latest_date_time();
			if (date != null) {
				last_latest_date_time = date;
			}
System.out.println("smdr - last ldt: " + last_latest_date_time);
		}
	}
*/

/*
	// Send a request for data for indicator `ind' for the tradable
	// `symbol' with `period_type'.
public void send_indicator_data_request(int ind, String symbol,
String period_type) throws Exception {
		connection.send_request(Indicator_data_request,
			ind + Message_field_separator + symbol +
			Message_field_separator + period_type);
		// Note that a new indicator drawer is created each time parse is
		// called, since indicator drawers should not be shared.
//!!!Remove: indicator_parser.parse(connection.result().toString(), new_indicator_drawer());

//!!!:data_parser.set_main_drawer(new_indicator_drawer());
		indicator_parser.parse(connection.result().toString());
		last_indicator_data = (DrawableDataSet) indicator_parser.result();
	}
*/

	// Send a time-delimited request for data for the tradable `symbol' with
	// `period_type' with the date-time range `start_date_time' ..
	// `end_date_time'.  If `end_date_time' is null, the current date-time
	// is used.
/*
	public void send_time_delimited_market_data_request(String symbol,
		String period_type, Calendar start_date_time, Calendar end_date_time)
			throws Exception {
System.out.println("sending request with " + symbol + ", " + period_type +
", " + start_date_time);
		connection.send_request(Time_delimited_market_data_request, symbol +
			Message_field_separator + period_type + Message_field_separator +
			date_time_range(start_date_time, end_date_time));
		if (connection.last_received_message_ID() == Ok) {
			String results = connection.result().toString();
			results = setup_parser_fieldspecs(results);
//!!!:data_parser.set_main_drawer(main_drawer);
//!!!Remove: data_parser.parse(results, main_drawer);
			data_parser.parse(results);
			last_market_data = (DrawableDataSet) data_parser.result();
			last_market_data.set_drawer(main_drawer);
			last_volume = (DrawableDataSet) data_parser.volume_result();
			if (last_volume != null) {
				last_volume.set_drawer(volume_drawer);
			}
			last_open_interest = (DrawableDataSet)
				data_parser.open_interest_result();
			if (last_open_interest != null) {
				last_open_interest.set_drawer(open_interest_drawer);
			}
			Calendar date = data_parser.latest_date_time();
			if (date != null) {
				last_latest_date_time = date;
			}
		}
	}
*/

	// Send a time-delimited request for data for indicator `ind' for
	// the tradable `symbol' with `period_type' with the date-time range
	// `start_date_time' .. `end_date_time'.  If `end_date_time' is null,
	// the current date-time is used.
/*
	public void send_time_delimited_indicator_data_request(int ind,
		String symbol, String period_type, Calendar start_date_time,
		Calendar end_date_time) throws Exception {
		connection.send_request(Time_delimited_indicator_data_request,
			ind + Message_field_separator + symbol +
			Message_field_separator + period_type + Message_field_separator +
			date_time_range(start_date_time, end_date_time));
// Note that a new indicator drawer is created each time parse is
// called, since indicator drawers should not be shared.

//!!!Remove:		indicator_parser.parse(connection.result().toString(), new_indicator_drawer());
		data_parser.set_main_drawer(new_indicator_drawer());
		indicator_parser.parse(connection.result().toString());
		last_indicator_data = (DrawableDataSet) indicator_parser.result();
	}
*/

	// Send a request for the list of indicators for tradable `symbol'.
/*
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
*/

// Hook routine implementations

	protected void postinit() {
		main_drawer = new_main_drawer();
		volume_drawer = new BarDrawer(main_drawer);
		((Parser) data_parser).set_volume_drawer(volume_drawer);
		open_interest_drawer = new LineDrawer(main_drawer);
		((Parser) data_parser).set_open_interest_drawer(open_interest_drawer);
	}

	protected void prepare_parser_for_market_data() {
		((Parser) data_parser).set_main_drawer(main_drawer);
	}

	protected void prepare_parser_for_indicator_data() {
		// Create a new indicator drawer, since indicator drawers should
		// not be shared.
		((Parser) indicator_parser).set_main_drawer(new_indicator_drawer());
	}

	protected void post_process_market_data(DataSet data, String symbol,
			String period_type) {

		((DrawableDataSet) data).set_drawer(main_drawer);
	}

	protected void post_process_indicator_data(DataSet data, String symbol,
			String period_type) {
	}

	protected void post_process_volume_data(DataSet data,
			String symbol, String period_type) {

		((DrawableDataSet) data).set_drawer(volume_drawer);
	}

	protected void post_process_open_interest_data(DataSet data,
			String symbol, String period_type) {

		((DrawableDataSet) data).set_drawer(open_interest_drawer);
	}

	protected AbstractParser new_main_parser() {
		return new Parser(main_field_specs, Message_record_separator,
			Message_field_separator);
	}

	protected AbstractParser new_indicator_parser(int[] field_specs) {
		return new Parser(field_specs, Message_record_separator,
			Message_field_separator);
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

	// Login to the server and initialize fields.
	// Precondition: connection != null && ! connection.logged_in()
	// Postcondition: connection.logged_in()
/*
	private void old_remove_initialize() throws Exception {
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
//		initialize_fieldspecs();
//		data_parser = new Parser(main_field_specs, Message_record_separator,
//									Message_field_separator);
		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		int indicator_field_specs[] = new int[2];
		indicator_field_specs[0] = Parser.Date;
		indicator_field_specs[1] = Parser.Close;
indicator_parser = new Parser(indicator_field_specs,
	Message_record_separator, Message_field_separator);
//...
//login_failed = false;
	}
*/

	private MarketDrawer main_drawer;	// draws data in main graph
	private IndicatorDrawer volume_drawer;	// draws volume data
	private IndicatorDrawer open_interest_drawer;	// draws open-interest
}
