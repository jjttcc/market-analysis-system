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

	SERVER_PROTOCOL --!!!Source of requestID constants
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (fb: FACTORY_BUILDER; ifs: STRING) is
		require
			not_void: fb /= Void and ifs /= Void
		do
			input_field_separator := ifs
			mai_initialize (fb)
			initialize
		ensure
			fb_set: factory_builder = fb
			ifs_set: input_field_separator = ifs
		end

feature -- Access

	io_medium: IO_MEDIUM

	output_field_separator: STRING

	input_field_separator: STRING

	date_field_separator: STRING

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

	set_output_field_separator (arg: STRING) is
			-- Set output_field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_field_separator := arg
		ensure
			output_field_separator_set: output_field_separator = arg and
				output_field_separator /= Void
		end

	set_input_field_separator (arg: STRING) is
			-- Set input_field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_field_separator := arg
		ensure
			input_field_separator_set: input_field_separator = arg and
				input_field_separator /= Void
		end

	set_date_field_separator (arg: STRING) is
			-- Set date_field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date_field_separator := arg
		ensure
			date_field_separator_set: date_field_separator = arg and
				date_field_separator /= Void
		end

feature -- Basic operations

	execute is
		local
			cmd: REQUEST_COMMAND
		do
			check
				medium_set: io_medium /= Void
			end
			from
			until
				end_session
			loop
				tokenize_message
				cmd := request_handlers @ message_ID
				cmd.set_active_medium (io_medium)
				cmd.execute (message_body)
			end
		end

feature {NONE}

	tokenize_message is
			-- Input the next client request, blocking if necessary, and split
			-- the received message into `message_ID' and `message_body'.
		local
			s: STRING
			i: INTEGER
		do
			!!s.make (0)
			from
				io_medium.read_character
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
				message_ID := s.substring (1, i - 1).to_integer
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
			!MARKET_DATA_REQUEST_CMD!cmd.make (input_field_separator,
				factory_builder.market_list)
			rh.extend (cmd, Market_data_request)
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

	end_session: BOOLEAN
			-- Has session termination been requested?

	request_handlers: TABLE [REQUEST_COMMAND, INTEGER]
			-- Handers of client requests received via io_medium

	message_ID: INTEGER
			-- ID of last client request

	message_body: STRING
			-- body of last client request

end -- class MAIN_GUI_INTERFACE
