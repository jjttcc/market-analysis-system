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
		local
			i: INTEGER
		do
			create settings.make (0)
			settings.extend ("", EOD_start_date_specifier)
			settings.extend ("", EOD_end_date_specifier)
			settings.extend ("", Host_specifier)
			settings.extend ("", Path_specifier)
			settings.extend ("", Symbol_file_specifier)
			settings.extend ("", Post_process_command_specifier)
			settings.extend ("", Output_field_separator_specifier)
			settings.extend ("", Ignore_day_of_week_specifier)
			settings.extend ("", EOD_turnover_time_specifier)
			create ignored_days_of_week.make (7)
			from i := 1 until i > 7 loop
				ignored_days_of_week.put (False, i)
				i := i + 1
			end
		end

feature -- Access

	path: STRING is
			-- The processed path component of the URL for the http request,
			-- with all occurrences of "<symbol>" replaced with `symbol'
			-- and of the date tokens with their respective values.
			-- @@Note: This feature uses eod_start_date for end-of-day
			-- data; if intraday data also needs to be processed, some
			-- redesign will be needed.
--!!!!Note: This and replace_tokens can probably be also used for database
--configuration - that is, move them up to CONFIGURATION_UTILITIES.
		do
			if cached_path = Void then
				cached_path := clone (original_path)
				replace_tokens (cached_path, <<symbol_token, start_day_token,
					start_month_token, start_year_token, end_day_token,
					end_month_token, end_year_token>>, <<symbol,
					eod_start_date.day.out, eod_start_date.month.out,
					eod_start_date.year.out, eod_end_date.day.out,
					eod_end_date.month.out, eod_end_date.year.out>>)
			end
			Result := cached_path
		end

	path_with_alternate_start_date (alt_sd: DATE): STRING is
			-- Same as `path', but with `alt_sd' used as the start date
			-- instead of `start_date' (not cached)
		do
			Result := clone (original_path)
			replace_tokens (Result, <<symbol_token, start_day_token,
				start_month_token, start_year_token, end_day_token,
				end_month_token, end_year_token>>, <<symbol,
				alt_sd.day.out, alt_sd.month.out,
				alt_sd.year.out, eod_end_date.day.out,
				eod_end_date.month.out, eod_end_date.year.out>>)
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

	eod_start_date: DATE is
			-- The end-of-day start date for the requested data
		do
			if cached_eod_start_date = Void then
				cached_eod_start_date := date_from_string (
					eod_start_date_string)
			end
			Result := cached_eod_start_date
		end

	eod_end_date: DATE is
			-- The end-of-day end date for the requested data
		do
			if cached_eod_end_date = Void then
				cached_eod_end_date := date_from_string (eod_end_date_string)
			end
			Result := cached_eod_end_date
		end

	eod_turnover_time: TIME is
		-- The time at which to attempt to retrieve the latest end-of-day
		-- data from the http data-source site, in the user's local time -
		-- Void if the specified value is invalid
		local
			time_util: expanded DATE_TIME_SERVICES
		do
			if
				cached_eod_turnover_time = Void and
					not eod_turnover_time_value.is_empty
			then
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

	ignored_days_of_week: HASH_TABLE [BOOLEAN, INTEGER]
			-- Days of the week during which data retrieval should not be done,
			-- where the keys are: 1 for Sunday .. 7 for Saturday

	most_recent_tradable_day_of_the_week: INTEGER is
			-- Most recent day of the week (1 = Sunday .. 7 = Saturday)
			-- that is not marked to be ignored
		local
			i, today: INTEGER
		do
			today := (create {DATE}.make_now).day_of_the_week
		end

	distance_of_first_tradable_day_from_today: INTEGER is
			-- Number of days back from today of the latest date before
			-- today whose day of the week is not marked to be ignored:
			-- 1 if yesterday is not marked ignored; 2 if the day before
			-- yesterday is not marked ignored; etc.  Result is -1 if all
			-- days of the week are marked to be ignored.
		local
			i, today, day_of_week: INTEGER
		do
			today := (create {DATE}.make_now).day_of_the_week
			Result := -1
			from
				i := 1
			until
				i > 7 or Result >= 1
			loop
				day_of_week := (today + 7 - i) \\ 7
				if day_of_week = 0 then day_of_week := 7 end
				if not (ignored_days_of_week @ day_of_week) then
					Result := i
				end
				i := i + 1
			end
print ("distance_of_first...: " + Result.out + "%N")
		ensure
			one_to_seven_days: Result /= -1 implies Result >= 1 and
				Result <= 7
		end

	latest_tradable_date_before_today: DATE is
			-- The latest date before today whose day of the week is not
			-- marked to be ignored:  yesterday if yesterday is not marked
			-- ignored; otherwise, the day before yesterday if it is not
			-- marked ignored; etc.  Result is Void if all days of the week
			-- are marked ignored.
		local
			days_back: INTEGER
		do
			days_back := -distance_of_first_tradable_day_from_today
			if days_back /= 1 then
				create Result.make_now
				Result.day_add (days_back)
			end
print ("latest_tradable_date_before_today: " + Result.out + "%N")
		ensure
			void_if_all_days_ignored:
				distance_of_first_tradable_day_from_today = -1 implies
				Result = Void
		end

feature -- Access

	eod_start_date_string: STRING is
		do
			Result := settings @ EOD_start_date_specifier
		end

	eod_end_date_string: STRING is
		do
			Result := settings @ EOD_end_date_specifier
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
			-- specified as a non-trading day?
		do
			Result := ignored_days_of_week @ (
				(create {DATE}.make_now).day_of_the_week)
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
			cached_eod_start_date := Void
			cached_eod_end_date := Void
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
			Result := key_token.is_equal (Ignore_day_of_week_specifier)
		end

	do_customized_setting (key_token, value_token: STRING) is
		do
			-- Default to null procedure - redefine if needed.
			if
				key_token /= Void and then key_token.is_equal (
				Ignore_day_of_week_specifier)
			then
				add_ignored_day_of_week (value_token)
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

	add_ignored_day_of_week (wday: STRING) is
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
				if time_util.day_of_week_table.has (d) then
					ignored_days_of_week.replace (True,
						time_util.day_of_week_from_3_letter_abbreviation (d))
				end
			end
		end

feature {NONE} -- Implementation - attributes

	cached_eod_start_date: DATE

	cached_eod_end_date: DATE

	cached_path: STRING

	cached_eod_turnover_time: TIME

	Date_field_separator: STRING is "/"

	Time_field_separator: STRING is ":"

	Specification_field_separator: STRING is ":"

feature {NONE} -- Implementation - token-related constants

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
