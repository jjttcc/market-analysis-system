indexing
	description: "Common configuration tools for the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class APP_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		export
			{NONE} all
		end

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

	DATE_PARSING_UTILITIES
		export
			{NONE} all
		end

	GLOBAL_CONSTANTS
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	initialize_common_settings is
			-- Put common initial settings into the `settings' table.
		require
			settings_created: settings /= Void
		do
			settings.extend ("", EOD_start_date_specifier)
			settings.extend ("", EOD_end_date_specifier)
			settings.extend ("", Intraday_start_date_specifier)
			settings.extend ("", Intraday_end_date_specifier)
			settings.extend ("", January_is_zero_specifier)
		end

feature -- Access

	eod_start_date: DATE is
			-- The end-of-day start date for the requested data
		do
			if
				cached_eod_start_date = Void and eod_start_date_string /= Void
			then
				cached_eod_start_date := date_from_string (
					eod_start_date_string)
			end
			Result := cached_eod_start_date
		end

	eod_end_date: DATE is
			-- The end-of-day end date for the requested data
		do
			if
				cached_eod_end_date = Void and eod_end_date_string /= Void
			then
				cached_eod_end_date := date_from_string (eod_end_date_string)
			end
			Result := cached_eod_end_date
		end

	intraday_start_date: DATE is
			-- The end-of-day start date for the requested data
		do
			if
				cached_intraday_start_date = Void and
				intraday_start_date_string /= Void
			then
				cached_intraday_start_date := date_from_string (
					intraday_start_date_string)
			end
			Result := cached_intraday_start_date
		end

	intraday_end_date: DATE is
			-- The end-of-day end date for the requested data
		do
			if
				cached_intraday_end_date = Void and
				intraday_end_date_string /= Void
			then
				cached_intraday_end_date := date_from_string (
					intraday_end_date_string)
			end
			Result := cached_intraday_end_date
		end

	symbol: STRING
			-- The current symbol for which data is being retrieved

	uppercase_symbol: STRING is
			-- `symbol' in all upper-case
		do
			Result := clone (symbol)
			Result.to_upper
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

	intraday_start_date_string: STRING is
		do
			Result := settings @ Intraday_start_date_specifier
		end

	intraday_end_date_string: STRING is
		do
			Result := settings @ Intraday_end_date_specifier
		end

	january_is_zero_string: STRING is
		do
			Result := settings @ january_is_zero_specifier
		end

feature -- Status report

	january_is_zero: BOOLEAN is
			-- Does the protocol for months start at zero - that is, does
			-- 0 represent January and 11 represent December?
		do
			-- 't' or 'T' for "True"
			Result := not january_is_zero_string.is_empty and then
				january_is_zero_string @ 1 = 't' or
				january_is_zero_string @ 1 = 'T'
		end

feature -- Element change

	set_symbol (arg: STRING) is
			-- Set `symbol' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
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
		end

	replace_tokens_using_dates (target: STRING; start_date, end_date: DATE;
		intraday: BOOLEAN) is
			-- Replace the following tokens in `target' with `symbol' and the
			-- corresponding components of `start_date' and `end_date':
			-- symbol_token, start_day_token, start_month_token,
			-- start_year_token, end_day_token, end_month_token,
			-- end_year_token, and if:
			--   intraday: EOD_start_date_specifier, EOD_end_date_specifier
			--   not intraday: Intraday_start_date_specifier,
			--      Intraday_end_date_specifier
		local
			dts: expanded DATE_TIME_SERVICES
			start_date_specifier, end_date_specifier: STRING
			month_adjustment: INTEGER
		do
			if intraday then
				start_date_specifier := Intraday_start_date_specifier
				end_date_specifier := Intraday_end_date_specifier
			else
				start_date_specifier := EOD_start_date_specifier
				end_date_specifier := EOD_end_date_specifier
			end
			if january_is_zero then
				month_adjustment := -1
			end
			replace_tokens (target, <<symbol_token, upper_symbol_token,
				start_day_token, start_month_token, start_year_token,
				end_day_token, end_month_token, end_year_token,
				start_date_specifier, end_date_specifier>>,
				<<symbol, uppercase_symbol, start_date.day.out,
				(start_date.month + month_adjustment).out, start_date.year.out,
				end_date.day.out, (end_date.month + month_adjustment).out,
				end_date.year.out, dts.date_as_yyyymmdd (start_date),
				dts.date_as_yyyymmdd (end_date)>>, token_start_delimiter,
				token_end_delimiter)
		end

	check_results is
		do
			check_for_missing_specs (<<eod_start_date_string.is_empty,
					EOD_start_date_specifier, eod_end_date_string.is_empty,
					EOD_end_date_specifier>>, False)
		end

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	new_file_reader: FILE_READER is
		do
			create Result.make (configuration_file_name)
		end

feature {NONE} -- Implementation - Hook routines

	configuration_file_name: STRING is
			-- The path and name of the configuration file
		deferred
		end

feature {NONE} -- Implementation - attributes

	cached_eod_start_date: DATE

	cached_eod_end_date: DATE

	cached_intraday_start_date: DATE

	cached_intraday_end_date: DATE

feature {NONE} -- Implementation - token-related constants

	symbol_token: STRING is "symbol"
			-- The token which is to be replaced at data-retrieval time
			-- with the current tradable symbol

	upper_symbol_token: STRING is "uppersymbol"
			-- The token which is to be replaced at data-retrieval time
			-- with the current tradable symbol, converted to upper case

	start_day_token: STRING is "startday"

	start_month_token: STRING is "startmonth"

	start_year_token: STRING is "startyear"

	end_day_token: STRING is "endday"

	end_month_token: STRING is "endmonth"

	end_year_token: STRING is "endyear"

invariant

end
