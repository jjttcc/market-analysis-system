note
	description:
		"TRADABLE_LISTs that obtain their input data from files %
		%(fix - change to:) %
		%TRADABLE_LISTs that obtain their input data from sockets"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SOCKET_TRADABLE_LIST inherit

	INPUT_MEDIUM_BASED_TRADABLE_LIST
		rename
			make as parent_make
		redefine
			target_tradable_out_of_date, append_new_data
		end

create

	make

feature {SOCKET_LIST_BUILDER} -- Initialization

	make (the_symbols: DYNAMIC_LIST [STRING]; factory: TRADABLE_FACTORY;
			conn: INPUT_DATA_CONNECTION)
		do
			parent_make (the_symbols, factory)
			connection := conn
		end

feature {SOCKET_LIST_BUILDER} -- Access

	connection: INPUT_DATA_CONNECTION
			-- The "connection" to the data server

feature {SOCKET_LIST_BUILDER} -- Element change

	set_connection (arg: like connection)
			-- Set `connection' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			connection := arg
		ensure
			connection_set: connection = arg and connection /= Void
		end

feature {NONE} -- Hook routine implementations

	target_tradable_out_of_date: BOOLEAN
		local
			latest_date_time: DATE_TIME
		do
			connection.initiate_connection
			if connection.last_communication_succeeded then
print ("conn.connected: " + connection.connected.out + "%N")
				if not target_tradable.data.is_empty then
					-- Set `latest_date_time' to tradable's last
					-- date-time + 1 sec.
					latest_date_time := target_tradable.data.last.date_time +
						(create {DATE_TIME_DURATION}.make_definite (0, 0, 0, 1))
				end
				connection.request_data_for (current_symbol, intraday,
					latest_date_time)
				if connection.last_communication_succeeded then
					Result := not connection.server_response.is_empty
				else
					-- Report error - data request failed.!!!!!
				end
			else
				-- Report error - Failed to connect.!!!!!
			end
print ("tgt t out of date result: " + Result.out + "%N")
		ensure then
			not_out_of_date_if_failed:
				not connection.last_communication_succeeded implies not Result
		end

	append_new_data
		do
--!!! data has already been read into i_med:			setup_input_medium
			check
				input_medium.readable
			end
			if not fatal_error then
				tradable_factory.turn_start_input_from_beginning_off
				tradable_factory.set_product (target_tradable)
				tradable_factory.execute
				if tradable_factory.error_occurred then
					report_errors (target_tradable.symbol,
						tradable_factory.error_list)
					if tradable_factory.last_error_fatal then
						fatal_error := True
					end
				end
				tradable_factory.turn_start_input_from_beginning_on
				close_input_medium
			else
				-- A fatal error indicates that the current tradable
				-- is invalid, or not readable, or etc., so ensure
				-- that target_tradable is not set to this invalid
				-- object.
				target_tradable := Void
			end
--!!!!Stub - See 'append_new_data' in EXTENDED_FILE_BASED_TRADABLE_LIST for
--some likely shared algorithm components for this implementation.
--May be able to refactor - move shared logic to the parent, use the template
--method pattern.
		end

feature {NONE} -- Implementation

	initialize_input_medium
		do
--!!!If INPUT_DATA_CONNECTION is modified so that `request_data_for'
--"initiates" the connection, then this `initialize_input_medium'
--implementation should be replaced by
--`possible_replacement___initialize_input_medium', below.
			connection.initiate_connection
			if not connection.last_communication_succeeded then
				fatal_error := True
--!!!!Where/when should this error be reported?:
print ("Error occurred connecting to data supplier:%N" +
connection.error_report + "%N")
			else
				input_medium := connection.socket
				connection.request_data_for (current_symbol, intraday, Void)
				if not connection.last_communication_succeeded then
					fatal_error := True
--!!!!Where/when should this error be reported?:
print ("Error occurred requesting data:%N" +
connection.error_report + "%N")
				end
			end
		end

	possible_replacement___initialize_input_medium
--!!!!A possible replacement for the above `initialize_input_medium'
		do
			input_medium := connection.socket
			connection.request_data_for (current_symbol, intraday, Void)
			if not connection.last_communication_succeeded then
				fatal_error := True
--!!!!Where/when should this error be reported?:
print ("Error occurred requesting data:%N" +
connection.error_report + "%N")
			end
		end

invariant

end
