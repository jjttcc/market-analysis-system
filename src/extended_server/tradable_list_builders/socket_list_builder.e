indexing
	description: "Builder of SOCKET_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class SOCKET_LIST_BUILDER inherit

	LIST_BUILDER

creation

	make

feature -- Initialization

	make (factory: TRADABLE_FACTORY; portnum: INTEGER) is
		do
			make_factories (factory)
			port_number := portnum
		end

feature -- Access

	daily_list: SOCKET_TRADABLE_LIST

	intraday_list: SOCKET_TRADABLE_LIST

	port_number: INTEGER

feature -- Basic operations

	build_lists is
		local
			input_connection: EXPERIMENTAL_INPUT_DATA_CONNECTION
		do
			create input_connection.make (port_number)
--!!!!:input_connection.initiate_connection
			input_connection.request_initial_data
			if input_connection.last_communication_succeeded then
				if input_connection.daily_data_available then
					create daily_list.make (input_connection.symbol_list,
						tradable_factory, input_connection)
				end
				if input_connection.intraday_data_available then
					create intraday_list.make (input_connection.symbol_list,
						intraday_tradable_factory, input_connection)
				end
--!!!!!!: if l /= Void then
--create Result.make (l, factory, input_connection)
--input_connection.set_tradable_list (Result)
			else
				--!!!Report error.
			end
			if daily_list = Void and intraday_list = Void then
				-- fulfill the postcondition
				create daily_list.make (create {LINKED_LIST [STRING]}.make,
					tradable_factory, input_connection)
			end
		end

end
