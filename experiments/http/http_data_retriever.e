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
		do
			create timer.make
			create data_retrieved_table.make (0)
			create parameters.make
			create url.http_make (parameters.host, "")
			create http_request.make (url)
			http_request.set_read_mode
			from
				initialize_symbols
				symbols.start
			until
				symbols.exhausted
			loop
				parameters.set_symbol (symbols.item)
				if data_retrieval_needed then
					retrieve_data
				end
				symbols.forth
			end
			print (timing_information)
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

	parameters: HTTP_CONFIGURATION

	timer: TIMER

	timing_information: STRING is
		once
			Result := ""
		end

	url: SETTABLE_HTTP_URL

	http_request: HTTP_PROTOCOL

	retrieve_data is
			-- Retrieve data for `parameters.symbol'.
		local
			result_string: STRING
		do
			create result_string.make (0)
			url.set_path (parameters.path)
			timer.start
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
					else
						data_retrieved_table.force (True, parameters.symbol)
					end
				else
					print ("Error occurred opening http request: " +
						http_request.error_text (http_request.error_code) +
						"%N")
				end
				http_request.close
				add_timing_data ("retrieving data for " + parameters.symbol)
				convert_and_save_result (result_string)
			else
				print ("Error occurred initializing http request: " +
					http_request.error_text (http_request.error_code) +
					"%N")
			end
		end

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

	current_output_file_name: STRING is
		do
			Result := parameters.symbol + ".txt"
		end

	convert_and_save_result (s: STRING) is
			-- Convert the retrieved data in `s' to MAS format and save the
			-- result to a file named parameters.symbol".txt".
		require
			symbol_valid: parameters /= Void and then parameters.symbol /=
				Void and then not parameters.symbol.is_empty
		local
			file: PLAIN_TEXT_FILE
			output: STRING
		do
			timer.start
			if
				s /= Void and then
				parameters.post_processing_routine /= Void
			then
				create file.make_open_write (current_output_file_name)
				add_timing_data ("opening file for " + parameters.symbol)
				timer.start
				output := parameters.post_processing_routine.item ([s])
				add_timing_data ("converting data for " + parameters.symbol)
				timer.start
				file.put_string (output)
				add_timing_data ("writing data to " + file.name)
			end
		end

	data_retrieval_needed: BOOLEAN is
		local
			outputfile: PLAIN_TEXT_FILE
		do
			create outputfile.make (current_output_file_name)
			Result := not outputfile.exists or (
				create {TIME}.make_now > parameters.eod_turnover_time and
				not parameters.ignore_today and
				not current_data_have_been_retrieved)
		end

	current_data_have_been_retrieved: BOOLEAN is
			-- Have up-to-date data for the current symbol been retrived?
		do
			Result := data_retrieved_table.has (parameters.symbol) and then
				data_retrieved_table @ parameters.symbol
		end

	data_retrieved_table: HASH_TABLE [BOOLEAN, STRING]
			-- Mapping of symbols to the boolean state of whether the
			-- data for that symbol have been retrieved

	add_timing_data (msg: STRING) is
		do
			timing_information.append ("Time taken for " + msg + ":%N" +
				timer.elapsed_time.time.fine_seconds_count.out + "%N")
		end

end
