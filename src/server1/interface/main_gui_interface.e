note
	description: "Interface to the GUI client"
	author: "Jim Cochrane"
	date: "$Date$";
	note1: "It is expected that, before `execute' is called, the first %
		%character of the input of io_medium has been read."
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAIN_GUI_INTERFACE inherit

	NON_PERSISTENT_CONNECTION_INTERFACE
		redefine
			io_medium, set_message_body
		end

	MAIN_APPLICATION_INTERFACE
		rename
			initialize as mai_initialize
		redefine
			event_generator_builder, function_builder
		end

	GUI_COMMUNICATION_PROTOCOL
		rename
			message_component_separator as message_field_separator
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

	make (fb: GLOBAL_OBJECT_BUILDER)
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

	post_process_io_medium
		do
			event_generator_builder.set_input_device (io_medium)
			event_generator_builder.set_output_device (io_medium)
			function_builder.set_input_device (io_medium)
			function_builder.set_output_device (io_medium)
		end

feature {NONE} -- Hook routine implementations

	end_of_message (c: CHARACTER): BOOLEAN
		do
			Result := c = eom @ 1
		end

feature {NONE} -- Implementation

	make_request_handlers
			-- Create the request handlers.
		local
			rh: like request_handlers
		do
			create rh.make (0)
			rh.extend (create {MARKET_DATA_REQUEST_CMD}.make (
				tradable_list_handler), market_data_request)
			rh.extend ( create {INDICATOR_DATA_REQUEST_CMD}.make (
				tradable_list_handler), indicator_data_request)
			rh.extend ( create {ALL_INDICATORS_REQUEST_CMD}.make (
				tradable_list_handler), all_indicators_request)
			rh.extend (create {TRADING_PERIOD_TYPE_REQUEST_CMD}.make (
				tradable_list_handler), trading_period_type_request)
			rh.extend (create {SYMBOL_LIST_REQUEST_CMD}.make (
				tradable_list_handler), market_list_request)
			rh.extend (create {INDICATOR_LIST_REQUEST_CMD}.make (
				tradable_list_handler), indicator_list_request)
			rh.extend (create {MAS_LOGIN_REQUEST_CMD}.make (
				tradable_list_handler,
				global_configuration.auto_data_update_on), login_request)
			rh.extend (create {EVENT_LIST_REQUEST_CMD}.make (
				tradable_list_handler), event_list_request)
			rh.extend (create {EVENT_DATA_REQUEST_CMD}.make (
				tradable_list_handler), event_data_request)
			rh.extend (create {ERROR_RESPONSE_CMD}.make, error)
			request_handlers := rh
		ensure
			rh_set: request_handlers /= Void and not request_handlers.is_empty
		end

	initialize
		do
			create event_generator_builder.make
			create function_builder.make (tradable_list_handler)
			make_request_handlers
		end

	set_message_body (s: STRING; index: INTEGER)
			-- Set `message_body' from string extracted from `s' @ `index'
			-- and set io_medium's compression on if specified in `s'.
		do
			if
				s.substring (index, index + compression_on_flag.count - 1).
					is_equal (compression_on_flag)
			then
				io_medium.set_compression (True)
				message_body := s.substring (index + compression_on_flag.count,
					s.count)
			else
				io_medium.set_compression (False)
				message_body := s.substring (index, s.count)
			end
		end

end -- class MAIN_GUI_INTERFACE
