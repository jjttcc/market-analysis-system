indexing
	description: "Configurations for obtaining tradable data from an http %
		%connection, read from a configuration file"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HTTP_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		export
			{NONE} all
		redefine
			use_customized_setting, do_customized_setting
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	APPLICATION_CONSTANTS
		export
			{NONE} all
		end

	HTTP_CONSTANTS
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	DATE_PARSING_UTILITIES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	initialize_settings_table is
		do
			create settings.make (0)
			settings.extend ("", Start_date_specifier)
			settings.extend ("", End_date_specifier)
			settings.extend ("", Host_specifier)
			settings.extend ("", Path_specifier)
			settings.extend ("", Symbol_file_specifier)
			settings.extend ("", Post_process_command_specifier)
			settings.extend ("", Output_field_separator_specifier)
			settings.extend ("", Ignore_weekday_specifier)
			settings.extend ("", EOD_turnover_time_specifier)
			create ignored_weekdays.make (0)
		end

feature -- Access

	path: STRING is
			-- The processed path component of the URL for the http request,
			-- with all occurrences of "<symbol>" replaced with `symbol'
--!!!!Note: This and replace_tokens can probably be also used for database
--configuration - that is, move them up to CONFIGURATION_UTILITIES.
		do
			if cached_path = Void then
				cached_path := clone (original_path)
				replace_tokens (cached_path, <<symbol_token, start_day_token,
					start_month_token, start_year_token, end_day_token,
					end_month_token, end_year_token>>, <<symbol,
					start_date.day.out, start_date.month.out,
					start_date.year.out, end_date.day.out,
					end_date.month.out, end_date.year.out>>)
			end
			Result := cached_path
		end

	replace_tokens (target: STRING; tokens: ARRAY [STRING];
		values: ARRAY [STRING]) is
			-- Replace all occurrences of `tokens' in `target' with
			-- the respective specified `values'.
		require
			args_exists: target /= Void and tokens /= Void and values /= Void
			same_number_of_tokens_and_values: tokens.count = values.count
			same_index_settings: tokens.lower = values.lower and
				tokens.upper = values.upper
		local
			i: INTEGER
		do
			from
				i := tokens.lower
			until
				i = tokens.upper + 1
			loop
				replace_token_all (target, tokens @ i, values @ i,
					token_start_delimiter, token_end_delimiter)
				i := i + 1
			end
		end

	start_date: DATE is
			-- The start date for the requested data
		do
			if cached_start_date = Void then
				cached_start_date := date_from_string (start_date_string)
			end
			Result := cached_start_date
		end

	end_date: DATE is
			-- The end date for the requested data
		do
			if cached_end_date = Void then
				cached_end_date := date_from_string (end_date_string)
			end
			Result := cached_end_date
		end

	eod_turnover_time: TIME is
		-- The time at which to attempt to retrieve the latest end-of-day
		-- data from the http data-source site, in the user's local time -
		-- Void if the specified value is invalid
		local
			time_util: expanded DATE_TIME_SERVICES
		do
			if cached_eod_turnover_time = Void then
				cached_eod_turnover_time := time_util.time_from_string (
					eod_turnover_time_value, ":")
			end
			Result := cached_eod_turnover_time
		end

	symbol: STRING
			-- The current symbol for which data is being retrieved

	post_processing_routine: FUNCTION [ANY, TUPLE [STRING], STRING] is
			-- Routine to be used to post process the retrieved data -
			-- Void if the post-processing specification is invalid
		local
			conversion_functions: expanded TRADABLE_DATA_CONVERSION
		do
			if
				post_process_command /= Void and then 
				not post_process_command.is_empty and
				conversion_functions.routine_table.has (post_process_command)
			then
				if output_field_separator /= '%U' then
					conversion_functions.set_output_field_separator (
						output_field_separator)
				end
				Result := conversion_functions.routine_for (
					post_process_command)
			elseif
				post_process_command /= Void and then
				not post_process_command.is_empty
			then
				log_error ("Invalid post-process command " +
					"specification: " + post_process_command + "%N")
			else
				Result := conversion_functions.null_conversion_routine
			end
		end

	ignored_weekdays: ARRAYED_LIST [INTEGER]
			-- Days of the week during which data retrieval should not be done

feature -- Access

	start_date_string: STRING is
		do
			Result := settings @ Start_date_specifier
		end

	end_date_string: STRING is
		do
			Result := settings @ End_date_specifier
		end

	host: STRING is
		do
			Result := settings @ Host_specifier
		end

	original_path: STRING is
		do
			Result := settings @ Path_specifier
		end

	symbol_file: STRING is
		do
			Result := settings @ Symbol_file_specifier
		end

	post_process_command: STRING is
		do
			Result := settings @ Post_process_command_specifier
		end

	output_field_separator: CHARACTER is
		local
			fs: STRING
		do
			Result := '%U'
			fs := settings @ Output_field_separator_specifier
			if not fs.is_empty then
				Result := fs @ 1
			end
		end

	eod_turnover_time_value: STRING is
		do
			Result := settings @ EOD_turnover_time_specifier
		end

feature -- Status report

	ignore_today: BOOLEAN is
			-- Should data retrieval not be done today becuase it is
			-- specified as a day of the week to ignore?
		local
			today: DATE
		do
			create today.make_now
			Result := ignored_weekdays.has (today.day_of_the_week)
		end

feature -- Element change

	set_symbol (arg: STRING) is
			-- Set `symbol' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
			cached_path := Void
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

feature -- Basic operations

	reset_dates is
			-- For dates that use the "now" construct, reset them so that
			-- the next time any "now" date is used, it is recalculated
			-- from the current date, which may have changed since the
			-- last calculation.
		do
			cached_start_date := Void
			cached_end_date := Void
			cached_path := Void -- Force `path' to use new dates.
		end

feature {NONE} -- Implementation - Hook routine implementations

	configuration_type: STRING is "http"

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_file_name: STRING is
		do
			Result := file_name_with_app_directory (
				Default_http_config_file_name)
		end

	check_results is
		do
		end

	use_customized_setting (key_token, value_token: STRING): BOOLEAN is
		do
			-- Default to always true - redefine if needed.
			Result := key_token.is_equal (Ignore_weekday_specifier)
		end

	do_customized_setting (key_token, value_token: STRING) is
		do
			-- Default to null procedure - redefine if needed.
			if
				key_token /= Void and then key_token.is_equal (
				Ignore_weekday_specifier)
			then
				add_ignored_weekday (value_token)
			end
		end

feature {NONE} -- Implementation

	check_for_missing_specs (ftbl: ARRAY[ANY]) is
--!!!Can this be moved to CONFIGURATION_UTILITIES?
--!!!!Note: This is currently not called - probably it should be - or delete it.
			-- Check for missing http field specs in `ftbl'.   Expected
			-- types of ftbl's contents are: <<BOOLEAN, STRING,
			-- BOOLEAN, STRING, ...>>.
		require
			count_even: ftbl.count \\ 2 = 0
		local
			s: STRING
			i: INTEGER
			emtpy: BOOLEAN_REF
			all_empty, problem: BOOLEAN
			es: expanded EXCEPTION_SERVICES
			ex: expanded EXCEPTIONS
		do
			from i := 1; all_empty := true until i > ftbl.count loop
				emtpy ?= ftbl @ i
				check
					correct_type: emtpy /= Void
				end
				if emtpy.item then
					s := concatenation (<<s, "Missing specification in ",
						"http configuration file:%N",
						ftbl @ (i+1), ".%N">>)
					problem := true
				else
					all_empty := false
				end
				i := i + 2
			end
			if problem and not all_empty then
				log_error (s)
				es.last_exception_status.set_fatal (true)
				ex.raise ("Fatal error reading http configuration file")
			end
		end

	add_ignored_weekday (wday: STRING) is
		local
			d: STRING
			time_util: expanded DATE_TIME_SERVICES
		do
			if
				wday /= Void and then not wday.is_empty and wday.count >= 3
			then
				d := wday.substring (1, 3)
				d.to_lower
				d.put ((d @ 1).upper, 1)
				if time_util.weekday_table.has (d) then
					ignored_weekdays.extend (
						time_util.weekday_from_3_letter_abbreviation (d))
				end
			end
		end

feature {NONE} -- Implementation - attributes

	cached_start_date: DATE

	cached_end_date: DATE

	cached_path: STRING

	cached_eod_turnover_time: TIME

	Date_field_separator: STRING is "/"

	Time_field_separator: STRING is ":"

	Specification_field_separator: STRING is ":"

feature {NONE} -- Implementation - token-related constants

	token_start_delimiter: CHARACTER is '<'
			-- Delimiter indicating the start of a replacable token

	token_end_delimiter: CHARACTER is '>'
			-- Delimiter indicating the end of a replacable token

	symbol_token: STRING is "symbol"
			-- The token which is to be replaced at data-retrieval time
			-- with the current tradable symbol

	start_day_token: STRING is "startday"

	start_month_token: STRING is "startmonth"

	start_year_token: STRING is "startyear"

	end_day_token: STRING is "endday"

	end_month_token: STRING is "endmonth"

	end_year_token: STRING is "endyear"

invariant

end
