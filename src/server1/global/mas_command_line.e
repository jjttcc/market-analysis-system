indexing
	description: "Parser of command-line arguments for Market Analysis %
		%System server application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_COMMAND_LINE inherit

	COMMAND_LINE

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	ERROR_SUBSCRIBER

creation {PLATFORM_DEPENDENT_OBJECTS}

	make

feature {NONE} -- Initialization

	process_remaining_arguments is
		do
			create {LINKED_LIST [INTEGER]} port_numbers.make
			create special_date_settings.make (date_format_prefix)
			special_date_settings.add_error_subscriber (Current)
			opening_price := True
			from
				main_setup_procedures.start
			until
				main_setup_procedures.exhausted
			loop
				main_setup_procedures.item.call ([])
				main_setup_procedures.forth
			end
			if not use_db then
				set_use_external_data_source
				if not use_external_data_source then
					set_use_web
					if not use_web then
						set_file_names
					end
				end
			else
				set_keep_db_connection
			end
			initialization_complete := True
		end

feature -- Access

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := concatenation (<<"Usage: ", command_name,
				" [options] [input_file ...]%NOptions:%N",
				"  <number>             ",
				"Use port <number> for socket communication%N",
				"  -f <sep>             Use Field separator <sep>%N",
				"  -i <ext>             ",
				"Include Intraday data from files with %
				%extension <ext>%N",
				"  -d <ext>             Include Daily data from files %
				%with extension <ext>%N",
				"  -v                   Print Version number%N",
				"  -h                   Print this Help message%N",
				"  -s                   Use Strict error checking%N",
				"  -p                   ",
				"Get data from database (Persistent store)%N",
				"  -w                   ",
				"Get data from the Web (HTTP request)%N",
				"  -x                   Use an external data source%N",
				"  -n                   No caching of intraday data%N",
				"  -b                   Run in Background%N",
				"  -debug               Debug mode - print internal %
				%calculation state, etc.%N",
				"  ", no_volume_spec,
				"           Data has no volume field%N",
				"  ", no_open_spec,
				"             Data has no open field%N",
				usage_indent, special_format_option_spec, "%N">>)
		end

feature -- Access -- settings

	port_numbers: LIST [INTEGER]
			-- Port numbers for server sockets

	opening_price: BOOLEAN
			-- Does the data include opening price?
			-- False if `no_open_spec' is specified.

	no_volume: BOOLEAN
			-- Does the data exclude the volume field?
			-- True if `no_volume_spec' is specified.

	no_high: BOOLEAN
			-- Does the data exclude the "highest-price" field?
			-- @@Always False for now - may be made configurable in the future.

	no_low: BOOLEAN
			-- Does the data exclude the "lowest-price" field?
			-- @@Always False for now - may be made configurable in the future.

	field_separator: STRING
			-- Field separator for (input) market data - Void if not set

	record_separator: STRING
			-- Record separator for (input) market data - Void if not set

	intraday_extension: STRING
			-- File-name extension for intraday data

	daily_extension: STRING
			-- File-name extension for daily data

	file_names: LIST [STRING]
			-- Market data input file names

	symbol_list: LIST [STRING] is
			-- Market data input symbols
		do
			if symbol_list_implementation = Void and use_db then
				set_symbol_list
			end
			Result := symbol_list_implementation
		end

	background: BOOLEAN
			-- Is the server run in the background?
			-- True if "-b" is found.

	use_db: BOOLEAN
			-- Is a database to be used for market data?
			-- True if "-p" is found (p = persistent store)

	use_web: BOOLEAN
			-- Are HTTP GET requests to be used to retrieve market data?
			-- True if "-w" is found

	use_external_data_source: BOOLEAN
			-- Is an external data source to be used to obtain market data?

	keep_db_connection: BOOLEAN
			-- If use_db, should the database remain connected until the
			-- process terminates instead of connecting and disconnecting
			-- for each query?

	strict: BOOLEAN
			-- Use strict error checking?
			-- True if "-s" is found.

	intraday_caching: BOOLEAN
			-- Cache intraday data?

	special_date_settings: DATE_FORMAT_SPECIFICATION
			-- Special date-format settings

feature -- Status report

	symbol_list_initialized: BOOLEAN
			-- Has `symbol_list' been initialized?

feature {NONE} -- Implementation

	set_special_formatting is
			-- Set "special" formatting options.
		do
			-- Look for and process multi-character options
			from
				contents.start
			until
				contents.exhausted
			loop
				if
					current_contents_match (date_format_prefix)
				then
					special_date_settings.process_option (contents.item)
					contents.remove
				elseif
					current_contents_match (no_open_spec)
				then
					opening_price := False
					contents.remove
				elseif
					current_contents_match (no_volume_spec)
				then
					no_volume := True
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_field_separator is
			-- Set `field_separator' and remove its settings from `contents'.
			-- Void if no field separator is specified
		do
			if option_in_contents ('f') then
				if contents.item.count > 2 then
					create field_separator.make (contents.item.count - 2)
					field_separator.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create field_separator.make (contents.item.count)
						field_separator.append (contents.item)
						contents.remove
					end
				end
			end
		end

	set_background is
		do
			if option_in_contents ('b') then
				background := True
				contents.remove
			end
		end

	set_strict is
		do
			if option_in_contents ('s') then
				strict := True
				contents.remove
			end
		end

	set_intraday_caching is
		do
			if option_in_contents ('n') then
				intraday_caching := False
				contents.remove
			else
				intraday_caching := True
			end
		end

	set_use_db is
		do
			if option_in_contents ('p') then
				use_db := True
				contents.remove
			end
		end

	set_use_web is
		do
			if option_in_contents ('w') then
				use_web := True
				contents.remove
			end
		end

	set_use_external_data_source is
		do
			if option_in_contents ('x') then
				use_external_data_source := True
				contents.remove
			end
		end

	set_keep_db_connection is
		do
			keep_db_connection := True -- Default value
			if option_string_in_contents ("reconnect") then
				keep_db_connection := False
				contents.remove
			end
		end

	set_debugging is
		local
			gs: expanded GLOBAL_SERVICES
		do
			-- Continue to loop until all debug options are removed so
			-- that none is confused with the -d option.
			from until not option_string_in_contents (Debug_option) loop
				-- @@For now, set all debugging options on.  In the future,
				-- different options will be set according to the contents of
				-- the option.
				gs.debug_state.make_true
				contents.remove
			end
		ensure
			debugging_options_removed:
				not option_string_in_contents (Debug_option)
		end

	set_port_numbers is
			-- Set `port_numbers' and remove its settings from `contents'.
			-- Empty if no port numbers are specified
		do
			from
				contents.start
			until
				contents.exhausted
			loop
				if contents.item.is_integer then
					port_numbers.extend (contents.item.to_integer)
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_file_names is
			-- Set `file_names' and remove its settings from `contents'.
			-- Empty if no file names are specified
			-- Must be called last because it expects all other arguments
			-- to have been removed from `contents'.
			-- Will ignore arguments that start with `option_sign'
		require
			not use_db
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			expander: FILE_NAME_EXPANDER
		do
			-- If -i option is specified, create the intraday extension.
			if option_in_contents ('i') then
				if contents.item.count > 2 then
					create intraday_extension.make (contents.item.count - 2)
					intraday_extension.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create intraday_extension.make (contents.item.count)
						intraday_extension.append (contents.item)
						contents.remove
					end
				end
			end
			if option_in_contents ('d') then
				if contents.item.count > 2 then
					create daily_extension.make (contents.item.count - 2)
					daily_extension.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create daily_extension.make (contents.item.count)
						daily_extension.append (contents.item)
						contents.remove
					end
				end
			end
			expander := global_server.file_name_expander
			expander.execute (contents, option_sign)
			file_names := expander.results
		end

	set_symbol_list is
		require
			db_in_use: use_db
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			db_services: MAS_DB_SERVICES
			l: LIST [STRING]
			gs: expanded GLOBAL_SERVICES
		do
			db_services := global_server.database_services
			if not db_services.fatal_error and not db_services.connected then
				db_services.connect
			end
			if db_services.fatal_error then
				error_occurred := True
			else
				symbol_list_implementation := db_services.stock_symbols
				if not db_services.fatal_error then
					l := db_services.derivative_symbols
					if l /= Void then
						symbol_list_implementation.append (l)
					end
				end
				if db_services.fatal_error then
					error_occurred := True
				elseif not keep_db_connection then
					db_services.disconnect
					error_occurred := db_services.fatal_error
				end
			end
			if error_occurred then
				log_errors (<<db_services.last_error, "%N">>)
			end
			symbol_list_initialized := True
			if gs.debug_state.data_retrieval then
				if
					symbol_list_implementation /= Void and
					not symbol_list_implementation.is_empty
				then
					io.error.print ("Symbol list:%N")
					io.error.print (list_concatenation (
						symbol_list_implementation, "%N"))
				else
					io.error.print ("Symbol list is empty or void.%N")
				end
			end
		end

feature {NONE} -- Implementation queries

	date_format_prefix: STRING is "-date-spec:"
			-- Prefix of the "special format" option

	no_open_spec: STRING is "-no-open"
			-- No-open specifier

	no_volume_spec: STRING is "-no-volume"
			-- No-volume specifier

	Debug_option: STRING is "debug"

	symbol_list_implementation: LIST [STRING]

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_debugging)
			Result.extend (agent set_special_formatting)
			Result.extend (agent set_field_separator)
			Result.extend (agent set_background)
			Result.extend (agent set_use_db)
			Result.extend (agent set_port_numbers)
			Result.extend (agent set_strict)
			Result.extend (agent set_intraday_caching)
		end

	initialization_complete: BOOLEAN

	special_format_option_spec: STRING is
		local
			s: STRING
		once
			s := " "
			Result := date_format_prefix + "<spec>"
			s.multiply (usage_description_column - Result.count -
				usage_indent.count - 1)
			Result := Result + s + special_format_description
		end

	usage_indent: STRING is "  "

	usage_description_column: INTEGER is 24

	special_format_description: STRING is
		local
			s: STRING
		once
			s := " "
			s.multiply (usage_description_column - 1)
			Result := "Use special date specification <spec>%N" + s +
				"  (See documentation for date specificaton.)"
		end

	current_contents_match (s: STRING): BOOLEAN is
			-- Does `contents.item' match `s'?
		do
			Result := contents.item.substring (1, s.count).is_equal (s)
		end

feature {NONE} -- ERROR_SUBSCRIBER interface

	notify (s: STRING) is
		do
			error_occurred := True
			error_description := s
		end

invariant

	port_numbers_not_void: port_numbers /= Void
	use_db: initialization_complete implies (
		use_db and not error_occurred implies file_names = Void and
		(symbol_list_initialized implies symbol_list_implementation /= Void))
	use_files:  initialization_complete implies (
		not use_db and not use_external_data_source and not use_web and
		not error_occurred implies symbol_list_implementation = Void and
		file_names /= Void)
	special_date_settings_exists: special_date_settings /= Void

end
