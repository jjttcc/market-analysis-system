package common;

/** Constants specifying the components of the TA network 
communication protocol */
public interface NetworkProtocol
{

	// Client request IDs
	int Market_data_request = 1;
	int Indicator_data_request = 2;
	int Trading_period_type_request = 3;
	int Market_list_request = 4;
	int Indicator_list_request = 5;
	int Login_request = 6;
	int Session_change_request = 7;
	int Logout_request = 8;

	// Server response IDs
	int Error = 101;
	int OK = 102;

	// Subtokens
	String Start_date = "start_date";
	String End_date = "end_date";

	// Field separators
	String output_date_field_separator = "";

	// String constants
	String Eom = "";
	String Input_field_separator = "\t";
	String Output_field_separator = "\t";
	String Output_record_separator = "\n";
	String date_field_separator = "/";

	// Currently, only daily and weekly period types are supported.
	String daily_period_type = "daily";
	String weekly_period_type = "weekly";
}
