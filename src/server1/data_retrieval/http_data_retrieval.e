indexing
	description:
		"Abstraction of an algorithm for retrieving tradable data %
		%from a web site with the HTTP GET construct"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	HTTP_DATA_RETRIEVAL

inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	initialize is
		do
			if timing_needed then create timer.make end
			create data_retrieved_table.make (0)
			create parameters.make
			create url.http_make (parameters.host, "")
			create http_request.make (url)
			http_request.set_read_mode
			initialize_symbols
		end

--!!!!!Add exception handling
	execute is
			-- For each symbol, s, in `symbols', if data for s needs
			-- to be retrieved, retrieve them.
		do
			from
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
			if timing_needed then print (timing_information) end
		end

	initialize_symbols is
		do
			read_symbols_from_file
		end

feature {NONE} -- Implementation - attributes

	parameters: HTTP_CONFIGURATION

	timer: TIMER

	url: SETTABLE_HTTP_URL

	http_request: HTTP_PROTOCOL

	symbols: ARRAYED_LIST [STRING]
			-- The symbols for which data is to be retrieved

	data_retrieved_table: HASH_TABLE [BOOLEAN, STRING]
			-- Mapping of symbols to the boolean state of whether the
			-- data for that symbol have been retrieved

feature {NONE} -- Implementation

	retrieve_data is
			-- Retrieve data for `parameters.symbol'.
		local
			result_string: STRING
		do
			create result_string.make (0)
			url.set_path (parameters.path)
			if timing_needed then timer.start end
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
				if timing_needed then
					add_timing_data ("retrieving data for " +
						parameters.symbol)
				end
				convert_and_save_result (result_string)
			else
				print ("Error occurred initializing http request: " +
					http_request.error_text (http_request.error_code) +
					"%N")
			end
		end

	data_retrieval_needed: BOOLEAN is
		local
			outputfile: PLAIN_TEXT_FILE
		do
			create outputfile.make (current_output_file_name)
			Result := not outputfile.exists or (
				time_to_eod_udpate and
				not parameters.ignore_today and
				not current_data_have_been_retrieved)
		end

	current_output_file_name: STRING is
		do
			Result := output_file_path + parameters.symbol + ".txt"
		end

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
			if timing_needed then timer.start end
			if
				s /= Void and then
				parameters.post_processing_routine /= Void
			then
				create file.make_open_write (current_output_file_name)
				if timing_needed then
					add_timing_data ("opening file for " + parameters.symbol)
				end
				if timing_needed then timer.start end
				output := parameters.post_processing_routine.item ([s])
				if timing_needed then
					add_timing_data ("converting data for " +
						parameters.symbol)
				end
				if timing_needed then timer.start end
				file.put_string (output)
				if timing_needed then
					add_timing_data ("writing data to " + file.name)
				end
			end
		end

	current_data_have_been_retrieved: BOOLEAN is
			-- Have up-to-date data for the current symbol been retrived?
		do
			Result := data_retrieved_table.has (parameters.symbol) and then
				data_retrieved_table @ parameters.symbol
		end

	add_timing_data (msg: STRING) is
		do
			timing_information.append ("Time taken for " + msg + ":%N" +
				timer.elapsed_time.time.fine_seconds_count.out + "%N")
		end

	timing_information: STRING is
		once
			Result := ""
		end

	time_to_eod_udpate: BOOLEAN is
			-- Is it time to update end-of-day data according to the
			-- eod_turnover_time specification?
		do
			if parameters.eod_turnover_time = Void then
				-- No turnover time specified - always update.
				Result := True
			else
				Result := create {TIME}.make_now >
					parameters.eod_turnover_time
			end
		end

feature {NONE} -- Hook routines

	timing_needed: BOOLEAN is
			-- Does the data retrieval need to be timed?
		deferred
		end

	output_file_path: STRING is
			-- Directory path of output file - redefine if needed
		once
			Result := ""
		end

end
