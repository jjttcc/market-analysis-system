indexing
	description: "Socket-based connections to an outside data supplier - %
		%Intended as a parent class to descendants implementing a protocol %
		%based on the data supplier they are associated with - i.e., using %
		%the strategy pattern"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

deferred class INPUT_DATA_CONNECTION inherit

	CLIENT_CONNECTION
		export
		redefine
			socket, server_type, receive_and_process_response
		end

	DATA_SUPPLIER_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

	INPUT_SOCKET_CLIENT

	DATE_TIME_PROTOCOL
		export
			{NONE} all
		end

feature -- Access

	socket: INPUT_SOCKET_DEBUG

--!!!!:	tradable_list: TRADABLE_LIST
			-- The tradable list associated with this connection

	symbol_list: LIST [STRING]
			-- List of available symbols - obtained by calling
			-- `request_symbols'.

	daily_data_available: BOOLEAN
			-- Is daily data available from the data supplier?

	intraday_data_available: BOOLEAN
			-- Is intraday data available from the data supplier?

feature -- Basic operations

	initiate_connection is
			-- Initiate the connection to the data supplier.
		do
			connect_to_supplier
		ensure
			socket_exists_if_no_error:
				last_communication_succeeded implies socket /= Void
			socket_connected_iff_no_error:
				last_communication_succeeded = connected
		end

	request_initial_data is
			-- Request `daily_data_available', `intraday_data_available',
			-- and `symbol_list' from the data supplier.
		do
			request_daily_and_intraday_data_status
			if last_communication_succeeded then
				request_symbols
			end
		ensure
			symbol_list_exists_if_successful: last_communication_succeeded
				implies symbol_list /= Void
		end

	request_daily_and_intraday_data_status is
			-- Request from the data supplier whether daily and intraday
			-- data are available.
		require
			connected: connected
		do
			request_daily_data_status
			if last_communication_succeeded then
				request_intraday_data_status
			end
		end

	request_symbols is
			-- Request the symbol list from the data supplier
		require
			connected: connected
		do
initiate_connection
			send_request (symbol_list_request_msg, True)
			if last_communication_succeeded then
				symbol_list := socket.all_records
			end
if not socket.is_closed then
	socket.close
end
		ensure
			symbol_list_exists_if_successful: last_communication_succeeded
				implies symbol_list /= Void
		end

	request_daily_data_status is
			-- Request from the data supplier whether daily data are available.
		require
			connected: connected
		do
initiate_connection
if last_communication_succeeded then
			daily_data_available := False
			send_request (daily_data_available_request_msg, True)
			if
				last_communication_succeeded and socket.all_records /= Void and
				not socket.all_records.is_empty and
				not socket.all_records.first.is_empty
			then
				if socket.all_records.first @ 1 = true_response then
					daily_data_available := True
				elseif socket.all_records.first @ 1 /= false_response then
					last_communication_succeeded := False
					error_report := invalid_server_response + ": " +
						socket.all_records.first
				end
			elseif last_communication_succeeded then
				last_communication_succeeded := False
				check
					socket.all_records = Void or socket.all_records.is_empty or
					socket.all_records.first.is_empty
				end
				error_report := empty_server_response
			end
else
	-- An error occurred.!!!
end
if not socket.is_closed then
	socket.close
end
		end

	request_intraday_data_status is
			-- Request from the data supplier whether intraday data
			-- are available.
		require
			connected: connected
		do
initiate_connection
			intraday_data_available := False
			send_request (intraday_data_available_request_msg, True)
			if
				last_communication_succeeded and socket.all_records /= Void and
				not socket.all_records.is_empty and
				not socket.all_records.first.is_empty
			then
				if socket.all_records.first @ 1 = true_response then
					intraday_data_available := True
				elseif socket.all_records.first @ 1 /= false_response then
					last_communication_succeeded := False
					error_report := invalid_server_response + ": " +
						socket.all_records.first
				end
			elseif last_communication_succeeded then
				last_communication_succeeded := False
				check
					socket.all_records = Void or socket.all_records.is_empty or
					socket.all_records.first.is_empty
				end
				error_report := empty_server_response
			end
if not socket.is_closed then
	socket.close
end
		end

	request_data_for (symbol: STRING; intraday: BOOLEAN;
		start_date_time: DATE_TIME) is
			-- Request data for `requester's current tradable identified
			-- by `symbol' - intraday data if `intraday'; otherwise daily.
			-- Use `start_date_time' as the start date/time for the
			-- request if it is not void; otherwise send an empty date
			-- range (meaning obtain all available data for the tradable).
		require
			connected: connected
			last_communication_succeeded: last_communication_succeeded
		do
--!!!!!????:
--initiate_connection
			send_request (tradable_data_request_msg (
				symbol, intraday, start_date_time), True)
--!!!!!????:
--if not socket.is_closed then
--	socket.close
--end
		ensure
			socket_exists_if_no_error:
				last_communication_succeeded implies socket /= Void
			socket_connected_iff_no_error:
				last_communication_succeeded = connected
		end

feature {NONE} -- Hook routines

	connect_to_supplier is
			-- Create `socket' and use it to connect to the data supplier
			-- as the first step in querying for new data.
		deferred
		end

feature {NONE} -- Hook routine implementations

	server_type: STRING is "data server "

	end_of_message (c: CHARACTER): BOOLEAN is
		do
			check
				not_used: False --!!!Verify not used.
			end
			Result := False -- Not used (I think!!!!)
		end

	receive_and_process_response is
		do
			socket.pre_process_input
			server_response := socket.last_input_string
			if socket.error_occurred then
				last_communication_succeeded := False
				error_report := socket.error_string
			end
		end

feature {NONE} -- Implementation

	tradable_data_request_msg (symbol: STRING; intraday: BOOLEAN;
			start_time: DATE_TIME): STRING is
		do
			Result := tradable_data_request.out + message_component_separator +
			date_time_range (start_time, Void) + message_component_separator +
			data_flags (intraday) + message_component_separator + symbol +
			client_request_terminator
		end

	symbol_list_request_msg: STRING is
		do
			Result := symbol_list_request.out + client_request_terminator
		end

	daily_data_available_request_msg: STRING is
		do
			Result := daily_avail_req.out + client_request_terminator
		end

	intraday_data_available_request_msg: STRING is
		do
			Result := intra_avail_req.out + client_request_terminator
		end

	data_flags (intraday: BOOLEAN): STRING is
			-- intraday/non-intraday flag
		do
			Result := "" -- Default to daily.
			if intraday then
				Result := intraday_data_flag
			end
		end

feature {NONE} -- Implementation - Constants

	Timeout_seconds: INTEGER is
		indexing
			once_status: global
		once
			Result := 10
		end

invariant

end
