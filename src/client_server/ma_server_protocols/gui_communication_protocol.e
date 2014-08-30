note

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class GUI_COMMUNICATION_PROTOCOL inherit

	MA_COMMUNICATION_PROTOCOL

feature -- Client request IDs

	tradable_data_request: INTEGER = 1
			-- Request for data for a specified tradable

	indicator_data_request: INTEGER = 2
			-- Request for data for a specified indicator for a
			-- specified tradable

	trading_period_type_request: INTEGER = 3
			-- Request for a list of all valid trading period types for a
			-- specified tradable

	tradable_list_request: INTEGER = 4
			-- Request for a list of all available tradables

	indicator_list_request: INTEGER = 5
			-- Request for a list of all available indicators for a
			-- specified tradable

	login_request: INTEGER = 6
			-- Login request from GUI client - to be responded to
			-- with a new session key and session state information

	session_change_request: INTEGER = 7
			-- Request for a change in session settings

	logout_request: INTEGER = 8
			-- Logout request from GUI client

	event_data_request: INTEGER = 9
			-- Request for a list of tradable events - trading signals, sorted
			-- by date, increasing

	event_list_request: INTEGER = 10
			-- Request for a list of all tradable event types valid for
			-- a particular tradable and trading-period type

	all_indicators_request: INTEGER = 11
			-- Request for a list of all known indicators

	time_delimited_tradable_data_request: INTEGER = 12
			-- Time-delimited request for data for a specified tradable

	time_delimited_indicator_data_request: INTEGER = 13
			-- Time-delimited request for indicator data for a
			-- specified tradable

	indicator_parameters_request: INTEGER = 14
			-- Request for parameter settings for a specified indicator
			-- (!!!!!!!for a specified tradable????!!!!)

	event_parameters_request: INTEGER = 15
			-- Request for parameter settings for a event type (...???!!!)

feature -- Server response IDs

	error: INTEGER = 101
			-- Response indicating that there was a problem receiving or
			-- parsing the client request

	ok: INTEGER = 102
			-- Response indicating that no errors occurred (and the active
			-- medium/socket will be closed)

	invalid_symbol: INTEGER = 103
			-- Response indicating that the server requested data for
			-- a symbol that is not in the database

	warning: INTEGER = 104
			-- Response indicating that a non-fatal error occurred

	invalid_period_type: INTEGER = 105
			-- Response indicating that the server requested data for
			-- a period type that is not in the database

	error_will_not_close: INTEGER = 201
			-- Response indicating that there was a problem receiving or
			-- parsing the client request and that the active medium
			-- (e.g., socket) will be kept open after this response is sent

	ok_will_not_close: INTEGER = 202
			-- "will-not-close" version of 'ok'

	invalid_symbol_will_not_close: INTEGER = 203
			-- "will-not-close" version of 'invalid_symbol'

	warning_will_not_close: INTEGER = 204
			-- "will-not-close" version of 'warning'

	invalid_period_type_will_not_close: INTEGER = 205
			-- "will-not-close" version of 'invalid_period_type'

feature -- Server response strings

	no_open_session_state: STRING = "no_open"
			-- Specification that there is no open field in the market data

	open_interest_flag: STRING = "oi"
			-- Specification that there is an open-interest field in
			-- the market data

feature -- Subtokens

	start_date: STRING = "start_date"
			-- Token specifying session setting for a start date

	end_date: STRING = "end_date"
			-- Token specifying session setting for an end date

feature -- Field separators

	message_date_field_separator: STRING = ""

	message_time_field_separator: STRING = ""

end
