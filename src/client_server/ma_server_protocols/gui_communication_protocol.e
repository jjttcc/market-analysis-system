indexing

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class GUI_NETWORK_PROTOCOL inherit

	NETWORK_PROTOCOL

feature -- Client request IDs

	Market_data_request: INTEGER is 1
			-- Request for data for a specified market

	Indicator_data_request: INTEGER is 2
			-- Request for data for a specified indicator for a
			-- specified market

	Trading_period_type_request: INTEGER is 3
			-- Request for a list of all valid trading period types for a
			-- specified market

	Market_list_request: INTEGER is 4
			-- Request for a list of all available markets

	Indicator_list_request: INTEGER is 5
			-- Request for a list of all available indicators for a
			-- specified market

	Login_request: INTEGER is 6
			-- Request for a session key

	Session_change_request: INTEGER is 7
			-- Request for a change in session settings

feature -- Server response IDs

	Error: INTEGER is 101
			-- Response indicating that there was a problem receiving or
			-- parsing the client request

	OK: INTEGER is 102
			-- Response indicating that no errors occurred

feature -- Subtokens

	Start_date: STRING is "start_date"
			-- Token specifying session setting for a start date

	End_date: STRING is "end_date"
			-- Token specifying session setting for an end date

end -- class GUI_NETWORK_PROTOCOL
