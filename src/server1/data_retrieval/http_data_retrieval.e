indexing
	description:
		"Abstraction of an algorithm for retrieving tradable data %
		%from a web site with the HTTP GET construct"
	author: "Jim Cochrane"
	note: "@@Note: It may be appropriate at some point to change the name %
		%of this class to something like EXTERNAL_DATA_RETRIEVAL - %
		%tools and algorithms for retrieval of data from an external %
		%source - http, socket, etc - Much of the existing logic in this %
		%class (and in HTTP_CONFIGURATION - see equivalent note in that %
		%class) can probably be applied (as is or with little change) to %
		%retrieval from other external sources besides an http server."
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
			create retrieved_symbols.make (0)
			http_request.set_read_mode
			file_extension := Default_file_extension
		ensure
			components_initialized: parameters /= Void and url /= Void and
				http_request /= Void and file_extension /= Void
		end

feature {NONE} -- Attributes

	parameters: HTTP_CONFIGURATION

	url: SETTABLE_HTTP_URL

	http_request: HTTP_PROTOCOL

	file_extension: STRING
			-- Extension to file name of output cache file

	Default_file_extension: STRING is "txt"
			-- Default value for `file_extension'

	retrieved_symbols: HASH_TABLE [BOOLEAN, STRING]
			-- Symbols for which data has been retrieved

feature {NONE} -- Basic operations

	retrieve_data is
			-- Retrieve data for `parameters.symbol'.
		do
			retrieval_failed := False
			append_to_output_file := False
			http_request.reset_error
			if
				use_day_after_latest_date_as_start_date and
				alternate_start_date /= Void
			then
				url.set_path (parameters.path_with_alternate_start_date (
					alternate_start_date))
				append_to_output_file := True
print ("Using alternate start date.%N")
			else
				url.set_path (parameters.path)
print ("Using configured start date.%N")
			end
			-- Prevent a side effect re. alternate_start_date for the next
			-- call to retrieve_data.
			alternate_start_date := Void
			start_timer
			perform_http_retrieval
			if not retrieval_failed then
				mark_as_retrieved (parameters.symbol)
			end
		ensure
			output_file_exists_if_successful: not retrieval_failed and
				converted_result /= Void and then
				not converted_result.is_empty implies output_file_exists
			alternate_start_date_reset_to_void: alternate_start_date = Void
		end

	check_if_data_is_out_of_date is
			-- Check if the current data for `parameters'.symbol are out
			-- of date with respect to the current date and the http
			-- configuration.  If true, `data_out_of_date' is set to True
			-- and `alternate_start_date' is set to the day after the date
			-- of the latest current data.
		local
			eod_update_time: BOOLEAN
			latest_date: DATE
		do
			--@@NOTE: This algorithm is for EOD data.  If the ability to
			--handle intraday data is added, a separate algorithm will
			--be needed for that.
			data_out_of_date := False
			alternate_start_date := Void
			eod_update_time := time_to_eod_update
			latest_date := latest_date_for (parameters.symbol)
			if latest_date /= Void then
				if
					not (retrieved_symbols @ parameters.symbol) and
					(not eod_update_time or parameters.ignore_today)
				then
					-- This path catches the case where it's not time
					-- to EOD-update (or it's a weekend), but the cached
					-- data is not up to date with the latest trading day
					-- before today.
					data_out_of_date := latest_date <
						parameters.latest_tradable_date_before_today
print ("latestdt, latest_tradable...: " + latest_date.out + ", " +
parameters.latest_tradable_date_before_today.out + "%N")
				else
					data_out_of_date := eod_update_time and
						not parameters.ignore_today and
						create {DATE}.make_now > latest_date
				end
				if data_out_of_date then
					-- Set the alternate start date to the day after the
					-- latest date in the current data set so that there
					-- is no overlap between the current data set and
					-- freshly retrieved data.  Clone to prevent side effects.
					alternate_start_date := clone (latest_date)
					alternate_start_date.day_add (1)
				end
			end
		ensure
			data_out_of_date = (alternate_start_date /= Void)
		end

feature {NONE} -- Status report

	retrieval_failed: BOOLEAN
			-- Did the last call to `retrieve_data' fail?

	output_file_exists: BOOLEAN is
			-- Does the output file with name
			-- `output_file_name (parameters.symbol)' exist?
		local
			outputfile: PLAIN_TEXT_FILE
		do
			create outputfile.make (output_file_name (parameters.symbol))
			Result := outputfile.exists
		end

	data_out_of_date: BOOLEAN
			-- Are data for the current symbol (`parameters.symbol')
			-- out of date with respect to today's date?

	converted_result: STRING
			-- Retrieval result converted into the expecte format
			-- by `convert_and_save_result'

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
		do
			start_timer
			if
				s /= Void and then
				parameters.post_processing_routine /= Void
			then
				add_timing_data ("Opening file for " + parameters.symbol)
				start_timer
				converted_result :=
					parameters.post_processing_routine.item ([s])
				add_timing_data ("Converting data for " + parameters.symbol)
				if
					converted_result = Void or else converted_result.is_empty
				then
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
					file.put_string (converted_result)
					add_timing_data ("Writing data to " + file.name)
					file.close
				end
			end
		end

	time_to_eod_update: BOOLEAN is
			-- Is it time to update end-of-day data according to the
			-- `parameters.eod_turnover_time' specification?
		do
			if parameters.eod_turnover_time = Void then
				-- No turnover time specified - always update.
				Result := True
			else
				Result := create {TIME}.make_now > parameters.eod_turnover_time
			end
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
			-- check_if_data_is_out_of_date set data_out_of_date to True,
			-- should the day after the latest date of the current data set be
			-- used as the start date for retrieval so that there is no overlap
			-- between the current data set and freshly retrieved data?
		once
			Result := True -- Redefine if needed.
		end

	latest_date_requirement: BOOLEAN is
			-- Precondition for `latest_date_for'
		once
			Result := True -- Redefine if a specific condition is needed.
		end

feature {NONE} -- Implementation

	perform_http_retrieval is
		local
			result_string: STRING
		do
			if not http_request.error then
				http_request.open
				if not http_request.error then
					create result_string.make (0)
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
						retrieval_failed := True
					end
				else
					print ("Error occurred opening http request: " +
						http_request.error_text (http_request.error_code) +
						"%N")
					retrieval_failed := True
				end
				http_request.close
				add_timing_data ("Retrieving data for " + parameters.symbol)
				convert_and_save_result (result_string)
			else
				print ("Error occurred initializing http request: " +
					http_request.error_text (http_request.error_code) +
					"%N")
				retrieval_failed := True
			end
		ensure
			output_file_exists_if_successful: not retrieval_failed and
				converted_result /= Void and then
				not converted_result.is_empty implies output_file_exists
		end

	mark_as_retrieved (symbol: STRING) is
			-- Ensure `retrieved_symbols @ symbol'
		do
			if not retrieved_symbols.has (symbol) then
				retrieved_symbols.put (True, symbol)
			end
		ensure
			symbol_marked: retrieved_symbols @ symbol
		end

end
