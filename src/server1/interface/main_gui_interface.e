indexing
	description: "Interface to the GUI client"
	author: "Jim Cochrane"
	date: "$Date$";
	note: "It is expected that, before `execute' is called, the first %
		%character of the input of io_medium has been read."
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAIN_GUI_INTERFACE inherit

	NON_PERSISTENT_CONNECTION_INTERFACE
		redefine
			io_medium, request_handlers, set_message_body
		end

	MAIN_APPLICATION_INTERFACE
		rename
			initialize as mai_initialize
		redefine
			event_generator_builder, function_builder
		end

	GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (fb: FACTORY_BUILDER) is
		require
			not_void: fb /= Void
		do
			mai_initialize (fb)
			initialize
		end

feature -- Access

	io_medium: COMPRESSED_SOCKET

	event_generator_builder: CL_BASED_MEG_EDITING_INTERFACE

	function_builder: CL_BASED_FUNCTION_EDITING_INTERFACE

feature -- Status setting

	post_process_io_medium is
		do
			event_generator_builder.set_input_device (io_medium)
			event_generator_builder.set_output_device (io_medium)
			function_builder.set_input_device (io_medium)
			function_builder.set_output_device (io_medium)
		end

feature {NONE} -- Hook routine implementations

	end_of_message (c: CHARACTER): BOOLEAN is
		do
			Result := c = Eom @ 1
		end

feature {NONE} -- Implementation

	make_request_handlers is
			-- Create the request handlers.
		local
			rh: like request_handlers
		do
			create rh.make (0)
			rh.extend (create {MARKET_DATA_REQUEST_CMD}.make (
				tradable_list_handler), Market_data_request)
			rh.extend ( create {INDICATOR_DATA_REQUEST_CMD}.make (
				tradable_list_handler), Indicator_data_request)
			rh.extend ( create {ALL_INDICATORS_REQUEST_CMD}.make (
				tradable_list_handler), All_indicators_request)
			rh.extend (create {TRADING_PERIOD_TYPE_REQUEST_CMD}.make (
				tradable_list_handler), Trading_period_type_request)
			rh.extend (create {SYMBOL_LIST_REQUEST_CMD}.make (
				tradable_list_handler), Market_list_request)
			rh.extend (create {INDICATOR_LIST_REQUEST_CMD}.make (
				tradable_list_handler), Indicator_list_request)
			rh.extend (create {LOGIN_REQUEST_CMD}.make (
				tradable_list_handler), Login_request)
			rh.extend (create {EVENT_LIST_REQUEST_CMD}.make (
				tradable_list_handler), Event_list_request)
			rh.extend (create {EVENT_DATA_REQUEST_CMD}.make (
				tradable_list_handler), Event_data_request)
			rh.extend (create {ERROR_RESPONSE_CMD}.make, Error)
			request_handlers := rh
		ensure
			rh_set: request_handlers /= Void and not request_handlers.is_empty
		end

	initialize is
		do
			create event_generator_builder.make
			create function_builder.make (tradable_list_handler)
			make_request_handlers
		end

	set_message_body (s: STRING; index: INTEGER) is
			-- Set `message_body' from string extracted from `s' @ `index'
			-- and set io_medium's compression on if specified in `s'.
		do
			if
				s.substring (index, index + Compression_on_flag.count - 1).
					is_equal (Compression_on_flag)
			then
				io_medium.set_compression (True)
				message_body := s.substring (index + Compression_on_flag.count,
					s.count)
			else
				io_medium.set_compression (False)
				message_body := s.substring (index, s.count)
			end
		end

feature {NONE}

	request_handlers: HASH_TABLE [MAS_REQUEST_COMMAND, HASHABLE]
			-- Handlers of client requests received via io_medium

end -- class MAIN_GUI_INTERFACE
