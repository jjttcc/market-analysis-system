indexing
	description: "Top-level application interface - command-line driven"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAIN_GUI_INTERFACE inherit

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

creation

	make

feature -- Initialization

	make (fb: FACTORY_BUILDER) is
		require
			not_void: fb /= Void
		do
			mai_initialize (fb)
			initialize
		ensure
			fb_set: factory_builder = fb
		end

feature -- Access

	io_medium: IO_MEDIUM

	event_generator_builder: CL_BASED_MEG_EDITING_INTERFACE

	function_builder: CL_BASED_FUNCTION_EDITING_INTERFACE

feature -- Status setting

	set_io_medium (arg: IO_MEDIUM) is
			-- Set io_medium to `arg'.
		require
			arg_not_void: arg /= Void
		do
			io_medium := arg
			event_generator_builder.set_input_device (io_medium)
			event_generator_builder.set_output_device (io_medium)
			function_builder.set_input_device (io_medium)
			function_builder.set_output_device (io_medium)
		ensure
			io_medium_set: io_medium = arg and io_medium /= Void
		end

feature -- Basic operations

	execute is
			-- Note: It is expected that the first character of the input
			-- of io_medium has been read.
		local
			cmd: REQUEST_COMMAND
		do
			check
				medium_set: io_medium /= Void
			end
			tokenize_message
			cmd := request_handlers @ message_ID
			cmd.set_active_medium (io_medium)
			cmd.execute (message_body)
		end

feature {NONE}

	tokenize_message is
			-- Input the next client request, blocking if necessary, and split
			-- the received message into `message_ID' and `message_body'.
		local
			s, msgid: STRING
			i: INTEGER
		do
			!!s.make (0)
			from
			until
				io_medium.last_character = eom @ 1
			loop
				s.extend (io_medium.last_character)
				io_medium.read_character
			end
			if s.empty then
				i := 0
			else
				i := s.substring_index (input_field_separator, 1)
			end
			if i <= 1 then
				message_ID := Error
				message_body := "Invalid message format"
			else
				msgid := s.substring (1, i - 1)
				if not msgid.is_integer then
					message_ID := Error
					message_body := "Message ID is not a valid integer."
				else
					message_ID := msgid.to_integer
				end
				message_body := s.substring (i + input_field_separator.count,
												s.count)
			end
		end

	make_request_handlers is
			-- Create the request handlers.
		local
			cmd: REQUEST_COMMAND
			rh: HASH_TABLE [REQUEST_COMMAND, INTEGER]
		do
			!!rh.make (0)
			!MARKET_DATA_REQUEST_CMD!cmd.make (factory_builder.market_list)
			rh.extend (cmd, Market_data_request)
			!INDICATOR_DATA_REQUEST_CMD!cmd.make (factory_builder.market_list)
			rh.extend (cmd, Indicator_data_request)
			!TRADING_PERIOD_TYPE_REQUEST_CMD!cmd.make (
				factory_builder.market_list)
			rh.extend (cmd, Trading_period_type_request)
			!MARKET_LIST_REQUEST_CMD!cmd.make (factory_builder.market_list)
			rh.extend (cmd, Market_list_request)
			!INDICATOR_LIST_REQUEST_CMD!cmd.make (factory_builder.market_list)
			rh.extend (cmd, Indicator_list_request)
			!ERROR_RESPONSE_CMD!cmd
			rh.extend (cmd, Error)
			request_handlers := rh
		ensure
			rh_set: request_handlers /= Void and not request_handlers.empty
		end

	initialize is
		do
			-- !!!Use the cl-based ones as stubs for now:
			!!event_generator_builder.make
			!!function_builder.make
			make_request_handlers
		end

feature {NONE}

	request_handlers: TABLE [REQUEST_COMMAND, INTEGER]
			-- Handers of client requests received via io_medium

	message_ID: INTEGER
			-- ID of last client request

	message_body: STRING
			-- body of last client request

end -- class MAIN_GUI_INTERFACE
