/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

package common;

/** Constants specifying the components of the Market Analysis System 
network communication protocol */
public interface NetworkProtocol
{

	// Client request IDs
	final int Market_data_request = 1;
	final int Indicator_data_request = 2;
	final int Trading_period_type_request = 3;
	final int Market_list_request = 4;
	final int Indicator_list_request = 5;
	final int Login_request = 6;
	final int Session_change_request = 7;
	final int Logout_request = 8;
	final int Event_data_request = 9;
	final int Event_list_request = 10;
	final int All_indicators_request = 11;

	// Server response IDs
	final int Error = 101;
	final int OK = 102;
	final int Invalid_symbol = 103;
	final int Warning = 104;
	final int Invalid_period_type = 105;

	// Server response strings
	final String No_open_session_state = "no_open";
	final String Open_interest_flag = "oi";

	// Subtokens
	final String Start_date = "start_date";
	final String End_date = "end_date";

	// Field separators
	final String Message_date_field_separator = "";
	final String Message_time_field_separator = "";

	// String constants
	final String Eom = "";
	final String Eot = "";
	final String Compression_on_flag = "<@z@>";
	final String Message_field_separator = "\t";
	final String Message_record_separator = "\n";

	// daily period type is needed for initialization.
	final String daily_period_type = "daily";
}
