indexing
	description: "Top-level application interface - command-line driven"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
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

	GLOBAL_SERVER
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
			if message_ID = Logout_request then
				-- Logout requests are handled specially - simply remove the
				-- client's session.
				sessions.remove (session_key)
			else
				cmd := request_handlers @ message_ID
				cmd.set_active_medium (io_medium)
				if
					message_ID /= Login_request and
					sessions.has (session_key)
					-- A session is not needed for the login request command,
					-- since it will create one.
				then
					cmd.set_session(sessions @ session_key)
				end
				cmd.execute (message_body)
			end
		end

feature {NONE}

	tokenize_message is
			-- Input the next client request, blocking if necessary, and split
			-- the received message into `message_ID', `session_key',
			-- and `message_body'.
		local
			s, number: STRING
			i, j: INTEGER
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
				i := s.substring_index (Input_field_separator, 1)
			end
			if i <= 1 then
				message_ID := Error
				message_body := "Invalid message format: "
				message_body.append(s)
			else
				-- Extract the message ID.
				number := s.substring (1, i - 1)
				if not number.is_integer then
					message_body := "Message ID is not a valid integer: "
					message_body.append (message_ID.out)
					message_ID := Error
				elseif
					not request_handlers.has (number.to_integer) and
					number.to_integer /= Logout_request
				then
					message_body := "Invalid message ID: "
					message_body.append (message_ID.out)
					message_ID := Error
				else
					message_ID := number.to_integer
					j := s.substring_index (Input_field_separator,
							i + Input_field_separator.count)
					if j = 0 then
						message_body := "Invalid message format: "
						message_body.append (s)
						message_ID := Error
					else
						-- Extract the session key.
						number := s.substring (i + Input_field_separator.count,
												j - 1)
						if not number.is_integer then
							message_body :=
								"Session key is not a valid integer: "
							message_body.append (number)
							message_ID := Error
						else
							session_key := number.to_integer
							if not message_ID_and_key_valid then
								message_body := "Invalid session key: "
								message_body.append (number)
								message_body.append (", for message ID: ")
								message_body.append (message_ID.out)
								message_ID := Error
							else
								message_body := s.substring (
									j + Input_field_separator.count, s.count)
							end
						end
					end
				end
			end
		end

	make_request_handlers is
			-- Create the request handlers.
		local
			cmd: REQUEST_COMMAND
			rh: HASH_TABLE [REQUEST_COMMAND, INTEGER]
		do
			!!rh.make (0)
			!MARKET_DATA_REQUEST_CMD!cmd.make (market_list_handler)
			rh.extend (cmd, Market_data_request)
			!INDICATOR_DATA_REQUEST_CMD!cmd.make (market_list_handler)
			rh.extend (cmd, Indicator_data_request)
			!TRADING_PERIOD_TYPE_REQUEST_CMD!cmd.make (
				market_list_handler)
			rh.extend (cmd, Trading_period_type_request)
			!MARKET_LIST_REQUEST_CMD!cmd.make (market_list_handler)
			rh.extend (cmd, Market_list_request)
			!INDICATOR_LIST_REQUEST_CMD!cmd.make (market_list_handler)
			rh.extend (cmd, Indicator_list_request)
			!ERROR_RESPONSE_CMD!cmd
			rh.extend (cmd, Error)
			!LOGIN_REQUEST_CMD!cmd.make (market_list_handler)
			rh.extend (cmd, Login_request)
			request_handlers := rh
		ensure
			rh_set: request_handlers /= Void and not request_handlers.empty
		end

	initialize is
		do
			!!event_generator_builder.make
			!!function_builder.make
			make_request_handlers
		end

	message_ID_and_key_valid: BOOLEAN is
			-- Is the combination of message_ID and session_key valid?
		do
			if
				not sessions.has (session_key) and
				message_ID /= Login_request
			then
				Result := false
			else
				Result := true
			end
		end

feature {NONE}

	request_handlers: HASH_TABLE [REQUEST_COMMAND, INTEGER]
			-- Handlers of client requests received via io_medium

	session_key: INTEGER
			-- Session key for last client request

	message_ID: INTEGER
			-- ID of last client request

	message_body: STRING
			-- body of last client request

end -- class MAIN_GUI_INTERFACE
