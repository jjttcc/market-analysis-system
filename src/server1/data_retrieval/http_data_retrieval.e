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

	TIMING_SERVICES
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	initialize is
		do
			create parameters.make
			create url.http_make (parameters.host, "")
			create http_request.make (url)
			http_request.set_read_mode
			file_extension := Default_file_extension
		ensure
			components_initialized: parameters /= Void and url /= Void and
				http_request /= Void and file_extension /= Void
		end

feature {NONE} -- Implementation - attributes

	parameters: HTTP_CONFIGURATION

	url: SETTABLE_HTTP_URL

	http_request: HTTP_PROTOCOL

	file_extension: STRING
			-- Extension to file name of output cache file

	Default_file_extension: STRING is "txt"
			-- Default value for `file_extension'

feature {NONE} -- Implementation

	retrieve_data is
			-- Retrieve data for `parameters.symbol'.
		require
			data_retrieval_needed: data_retrieval_needed
		local
			result_string: STRING
		do
			create result_string.make (0)
			append_to_output_file := False
			if alternate_start_date /= Void then
				url.set_path (parameters.path_with_alternate_start_date (
					alternate_start_date))
				append_to_output_file := True
			else
				url.set_path (parameters.path)
			end
			start_timer
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
				add_timing_data ("Retrieving data for " + parameters.symbol)
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
			--@@NOTE: This algorithm is for EOD data.  If the ability to
			--handle intraday data is added, a separate algorithm will
			--be needed for that.
			alternate_start_date := Void
			create outputfile.make (output_file_name (parameters.symbol))
			Result := not outputfile.exists or (
				time_to_eod_update and
				not parameters.ignore_today and
				current_daily_data_out_of_date)
		end

	output_file_name (symbol: STRING): STRING is
			-- Output file name constructed from `symbol'
		do
			--@NOTE: If retrieval of intraday data via http is introduced,
			--a bit of redesign will be needed - Perhaps use an 'intraday'
			--flag and use a different extension for intraday than for
			--daily data.  Need to coordinate with other dependent
			--MAS components.
			Result := output_file_path + symbol + "." + file_extension
		end

	symbols_from_file: LIST [STRING] is
			-- List of symbols read from the specified input file.
		require
			parameters_exist: parameters /= Void
		local
			file_reader: FILE_READER
			contents: STRING
			su: expanded STRING_UTILITIES
			l: ARRAYED_LIST [STRING]
		do
			create file_reader.make (parameters.symbol_file)
			contents := file_reader.contents
			if not file_reader.error then
				su.set_target (contents)
				l := su.tokens ("%N")
				if not l.is_empty and then l.last.is_empty then
					-- If the last line of the l file ends with
					-- a newline, `l' will have an empty last
					-- element - remvoe it.
					l.finish
					l.remove
				end
			else
				log_errors (<<"Error reading symbol file: ",
					parameters.symbol_file, "%N(", 
					file_reader.error_string, ")%N">>)
			end
			Result := l
		end

	convert_and_save_result (s: STRING) is
			-- Convert the retrieved data in `s' to MAS format and save the
			-- result to a file named parameters.symbol"."file_extension.
		require
			symbol_valid: parameters /= Void and then parameters.symbol /=
				Void and then not parameters.symbol.is_empty
		local
			file: PLAIN_TEXT_FILE
			output: STRING
		do
			start_timer
			if
				s /= Void and then
				parameters.post_processing_routine /= Void
			then
				add_timing_data ("Opening file for " + parameters.symbol)
				start_timer
				output := parameters.post_processing_routine.item ([s])
				add_timing_data ("Converting data for " + parameters.symbol)
				if output = Void or else output.is_empty then
					log_error ("Result for " + parameters.symbol +
						" is empty - symbol may be invalid.%N")
				else
					start_timer
					if append_to_output_file then
						create file.make_open_append (output_file_name (
							parameters.symbol))
					else
						create file.make_open_write (output_file_name (
							parameters.symbol))
					end
					file.put_string (output)
					add_timing_data ("Writing data to " + file.name)
					file.close
				end
			end
		end

	time_to_eod_update: BOOLEAN is
			-- Is it time to update end-of-day data according to the
			-- eod_turnover_time specification?
		do
			if parameters.eod_turnover_time = Void then
				-- No turnover time specified - always update.
				Result := True
			else
				Result := create {TIME}.make_now > parameters.eod_turnover_time
			end
		end

	current_daily_data_out_of_date: BOOLEAN is
			-- Are the daily data cached for `parameters.symbol' out
			-- of date with respect to the current date?
		require
			alternate_start_date_void: alternate_start_date = Void
		local
			d: DATE
		do
			d := clone (latest_date_for (parameters.symbol))
			Result := d /= Void and then d < create {DATE}.make_now
			if Result and use_day_after_latest_date_as_start_date then
				-- Set the alternate start date to the day after the
				-- latest date in the current data set so that there
				-- is no overlap between the current data set and
				-- freshly retrieved data.
				alternate_start_date := d
				alternate_start_date.day_add (1)
			end
		ensure
			no_alternate_start_date_if_not_out_of_date: not Result implies
				alternate_start_date = Void
		end

	alternate_start_date: DATE
			-- Alternate start date to use instead of parameters.start_date -
			-- allows overriding the configured start date when, for
			-- example, data beginning at the configured start date has
			-- already been retrieved (i.e., retrieval is an update).
			-- Void indicates no alternate start date is being used.

	append_to_output_file: BOOLEAN
			-- Should retrieved data be appended to the output file
			-- rather than overwriting it?

feature {NONE} -- Hook routines

	output_file_path: STRING is
			-- Directory path of output file - redefine if needed
		once
			Result := ""
		end

	latest_date_for (symbol: STRING): DATE is
			-- The latest date-stamp of the data cached for `symbol',
			-- for determining if this data is "out of date" -
			-- Void indicates that it should NOT be considered out of date.
			-- NOTE: If the result needs to be modified by the caller,
			-- make sure a clone of the result is modified rather than
			-- the actual result to prevent unwanted side effects.
		require
			symbol_exists: symbol /= Void
			latest_date_requirement: latest_date_requirement
		once
			-- Default to Void - redefine if needed.
		end

	use_day_after_latest_date_as_start_date: BOOLEAN is
			-- When a retrieval is needed because
			-- `current_daily_data_out_of_date', should the day after
			-- the latest date of the current data set be used as the
			-- start date for retrieval so that there is no overlap
			-- between the current data set and freshly retrieved data?
		once
			Result := True -- Redefine if needed.
		end

	latest_date_requirement: BOOLEAN is
			-- Precondition for `latest_date_for'
		once
			Result := True -- Redefine if a specific condition is needed.
		end

end
