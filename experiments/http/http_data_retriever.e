class HTTP_TEST inherit

	ARGUMENTS
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make is
		local
			i: INTEGER
		do
			from
				create parameters.make
print ("Turnover time: " + eod_turnover_time_string + "%N")
die (0)
				initialize_symbols
				symbols.start
			until
				symbols.exhausted
			loop
				print ("%N" + symbols.item + ":%N%N")
				parameters.set_symbol (symbols.item)
				test_http
				print ("host: " + parameters.host + ", path: " +
					parameters.path + "%N")
				symbols.forth
			end
		end

	initialize_symbols is
		local
			i: INTEGER
		do
			create symbols.make (argument_count)
			if argument_count >= 1 then
				from i := 1 until i = argument_count + 1 loop
					symbols.extend (argument (i))
					i := i + 1
				end
			else
				read_symbols_from_file
			end
		end

feature {NONE} -- Implementation

	parameters: YAHOO_HTTP_PARAMETERS

	test_http is
		local
			url: SETTABLE_HTTP_URL
			http_request: HTTP_PROTOCOL
			result_string: STRING
		do
print ("parameters start date: " + parameters.start_date.out + "%N")
print ("parameters end date: " + parameters.end_date.out + "%N")
			create result_string.make (0)
			create url.http_make (parameters.host, parameters.path)
			create http_request.make (url)
			http_request.set_read_mode
			if not http_request.error then
				http_request.open
				if not http_request.error then
					from
						http_request.initiate_transfer
					until
						not http_request.is_packet_pending or
						http_request.error
					loop
						http_request.read
						result_string.append_string (http_request.last_packet)
					end
					if http_request.error then
						print ("Error occurred initiating transfer: " +
							http_request.error_text (http_request.error_code) +
							"%N")
					end
				else
					print ("Error occurred opening http request: " +
						http_request.error_text (http_request.error_code) +
						"%N")
				end
				http_request.close
				io.put_string (result_string)
			else
				print ("Error occurred initializing http request: " +
					http_request.error_text (http_request.error_code) +
					"%N")
			end
		end

	initialize_symbol (i: INTEGER) is
		require
			valid_arg_index: i >= 1 and i <= argument_count
		do
			symbol := argument (i)
		end

	host: STRING is "chart.yahoo.com"

	symbol: STRING

	date_from_numeric_string (s: STRING): DATE is
		require
			s_valid: s /= Void and s.is_integer
		do
			create Result.make (s.substring (1, 4).to_integer,
				s.substring (5, 6).to_integer,
				s.substring (7, 8).to_integer)
		end

	start_date: DATE

	use_command_line: BOOLEAN
			-- Are command-line arguments to be used to specify the
			-- symbols for which data is to be retrieved?

	symbols: ARRAYED_LIST [STRING]
			-- The symbols for which data is to be retrieved

	read_symbols_from_file is
			-- Read `symbols' from the specified input file.
		local
			file_reader: FILE_READER
			contents: STRING
			su: expanded STRING_UTILITIES
		do
			create file_reader.make (parameters.symbol_file)
			contents := file_reader.contents
			if not file_reader.error then
				su.set_target (contents)
				symbols := su.tokens ("%N")
				if not symbols.is_empty and then symbols.last.is_empty then
					-- If the last line of the symbols file ends with
					-- a newline, `symbols' will have an empty last
					-- element - remvoe it.
					symbols.finish
					symbols.remove
				end
			else
				log_errors (<<"Error reading symbol file: ",
					parameters.symbol_file, "%N(", 
					file_reader.error_string, ")%N">>)
			end
		end

	eod_turnover_time_string: STRING is
		require
			parameters_exist: parameters /= Void
		do
			if parameters.eod_turnover_time /= Void then
				Result := parameters.eod_turnover_time.out
			else
				Result := "Invalid time specified: " +
					parameters.eod_turnover_time_value
			end
		end

end
