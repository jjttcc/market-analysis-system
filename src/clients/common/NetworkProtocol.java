/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package common;

/** Constants specifying the components of the Market Analysis System 
network communication protocol */
public interface NetworkProtocol
{

	// Client request IDs
	final int market_data_request = 1;
	final int indicator_data_request = 2;
	final int trading_period_type_request = 3;
	final int market_list_request = 4;
	final int indicator_list_request = 5;
	final int login_request = 6;
	final int session_change_request = 7;
	final int logout_request = 8;
	final int event_data_request = 9;
	final int event_list_request = 10;
	final int all_indicators_request = 11;

	// Server response IDs
	final int error = 101;
	final int ok = 102;
	final int invalid_symbol = 103;
	final int warning = 104;
	final int invalid_period_type = 105;

	// Server response strings
	final String no_open_session_state = "no_open";
	final String open_interest_flag = "oi";

	// Subtokens
	final String start_date = "start_date";
	final String end_date = "end_date";

	// Field separators
	final String message_date_field_separator = "";
	final String message_time_field_separator = "";

	// String constants
	final String Eom = "";
	final String Eot = "";
	final String Compression_on_flag = "<@z@>";
	final String Message_field_separator = "\t";
	final String Message_record_separator = "\n";

	// Client request IDs
	final int time_delimited_market_data_request = 12;
	final int time_delimited_indicator_data_request = 13;

	// daily period type is needed for initialization.
	final String daily_period_type = "daily";

	// Field separators for date-time components of client requests
	final String client_request_date_field_separator = "/";
	final String client_request_time_field_separator = ":";
	final String client_request_date_time_range_separator = ";";
	final String client_request_date_time_separator = ",";
}
