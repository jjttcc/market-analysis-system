indexing

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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
			-- Login request from GUI client - to be responded to
			-- with a new session key and session state information

	Session_change_request: INTEGER is 7
			-- Request for a change in session settings

	Logout_request: INTEGER is 8
			-- Logout request from GUI client

	Event_data_request: INTEGER is 9
			-- Request for a list of market events - trading signals, sorted
			-- by date, increasing

	Event_list_request: INTEGER is 10
			-- Request for a list of all market event types valid for
			-- a particular tradable and trading-period type

feature -- Server response IDs

	Error: INTEGER is 101
			-- Response indicating that there was a problem receiving or
			-- parsing the client request

	OK: INTEGER is 102
			-- Response indicating that no errors occurred

	Invalid_symbol: INTEGER is 103
			-- Response indicating that the server requested data for
			-- a symbol that is not in the database

	Warning: INTEGER is 104
			-- Response indicating that a non-fatal error occurred

feature -- Server response strings

	No_open_session_state: STRING is "no_open"
			-- Specification that there is no open field in the market data

	Open_interest_flag: STRING is "oi"
			-- Specification that there is an open-interest field in
			-- the market data

feature -- Subtokens

	Start_date: STRING is "start_date"
			-- Token specifying session setting for a start date

	End_date: STRING is "end_date"
			-- Token specifying session setting for an end date

feature -- Field separators

	output_date_field_separator: STRING is ""

	output_time_field_separator: STRING is ""

end -- class GUI_NETWORK_PROTOCOL
