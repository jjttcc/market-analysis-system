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

	CLIENT_REQUEST_HANDLER
		rename
			command_argument as message_body
		redefine
			message_body, request_handlers, setup_command, cleanup_session,
			session
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

	set_io_medium (arg: like io_medium) is
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

feature {NONE} -- Hook routine implementation

	setup_command (cmd: MAS_REQUEST_COMMAND) is
		do
			cmd.set_active_medium (io_medium)
		end

	request_error: BOOLEAN is
		do
			Result := request_id = Error
		end

	session: MAS_SESSION is
		do
			if sessions.has (session_key) then
				Result := sessions @ session_key
			end
		end

	cleanup_session is
		do
			sessions.remove (session_key)
		end

	process_request is
			-- Input the next client request, blocking if necessary, and split
			-- the received message into `request_id', `session_key',
			-- and `message_body'.
		local
			s, number: STRING
			i, j: INTEGER
		do
			create s.make (0)
			from
			until
				io_medium.last_character = eom @ 1 or not io_medium.readable
			loop
				s.extend (io_medium.last_character)
				io_medium.read_character
			end
			if s.is_empty then
				i := 0
			else
				i := s.substring_index (Input_field_separator, 1)
			end
			if i <= 1 then
				request_id := Error
				message_body := "Invalid message format: "
				message_body.append(s)
			elseif io_medium.last_character /= eom @ 1 then
				s.extend (io_medium.last_character)
				request_id := Error
				message_body := "End of message string not received with:%N"
				message_body.append(s)
			else
				-- Extract the request ID.
				number := s.substring (1, i - 1)
				if not number.is_integer then
					message_body := "request ID is not a valid integer: "
					message_body.append (number)
					request_id := Error
				elseif
					not request_handlers.has (number.to_integer) and
					number.to_integer /= Logout_request
				then
					message_body := "Invalid request ID: "
					message_body.append (number)
					request_id := Error
				else
					request_id := number.to_integer
					j := s.substring_index (Input_field_separator,
							i + Input_field_separator.count)
					if j = 0 then
						message_body := "Invalid message format: "
						message_body.append (s)
						request_id := Error
					else
						-- Extract the session key.
						number := s.substring (i + Input_field_separator.count,
												j - 1)
						if not number.is_integer then
							message_body :=
								"Session key is not a valid integer: "
							message_body.append (number)
							request_id := Error
						else
							session_key := number.to_integer
							if not session_valid then
								message_body := "Invalid session key: "
								message_body.append (number)
								message_body.append (", for request ID: ")
								message_body.append (request_id.out)
								request_id := Error
							else
								set_message_body (
									s, j + Input_field_separator.count)
							end
						end
					end
				end
			end
			check
				message_body_set: message_body /= Void
			end
		end

	is_logout_request (id: like request_id): BOOLEAN is
		do
			Result := id = Logout_request
		end

	is_login_request (id: like request_id): BOOLEAN is
		do
			Result := id = Login_request
		end

feature {NONE} -- Implementation

	make_request_handlers is
			-- Create the request handlers.
		local
			rh: like request_handlers
		do
			create rh.make (0)
			rh.extend (create {MARKET_DATA_REQUEST_CMD}.make (
				market_list_handler), Market_data_request)
			rh.extend ( create {INDICATOR_DATA_REQUEST_CMD}.make (
				market_list_handler), Indicator_data_request)
			rh.extend (create {TRADING_PERIOD_TYPE_REQUEST_CMD}.make (
				market_list_handler), Trading_period_type_request)
			rh.extend (create {MARKET_LIST_REQUEST_CMD}.make (
				market_list_handler), Market_list_request)
			rh.extend (create {INDICATOR_LIST_REQUEST_CMD}.make (
				market_list_handler), Indicator_list_request)
			rh.extend (create {LOGIN_REQUEST_CMD}.make (
				market_list_handler), Login_request)
			rh.extend (create {EVENT_LIST_REQUEST_CMD}.make (
				market_list_handler), Event_list_request)
			rh.extend (create {EVENT_DATA_REQUEST_CMD}.make (
				market_list_handler), Event_data_request)
			rh.extend (create {ERROR_RESPONSE_CMD}.make, Error)
			request_handlers := rh
		ensure
			rh_set: request_handlers /= Void and not request_handlers.is_empty
		end

	initialize is
		do
			create event_generator_builder.make
			create function_builder.make (market_list_handler)
			make_request_handlers
		end

	set_message_body (s: STRING; index: INTEGER) is
			-- Set `message_body' from string extracted from `s' @ `index'
			-- and set io_medium's compression on if specified in `s'.
		do
			if
				s.substring (index, index + Compression_on_flag.count - 1).
					is_equal(Compression_on_flag)
			then
				io_medium.set_compression (true)
				message_body := s.substring (index + Compression_on_flag.count,
					s.count)
			else
				io_medium.set_compression (false)
				message_body := s.substring (index, s.count)
			end
		end

feature {NONE}

	request_handlers: HASH_TABLE [MAS_REQUEST_COMMAND, HASHABLE]
			-- Handlers of client requests received via io_medium

	message_body: STRING
			-- body of last client request

	session_key: INTEGER
			-- Key for the current session, extracted by `process_request'

end -- class MAIN_GUI_INTERFACE
