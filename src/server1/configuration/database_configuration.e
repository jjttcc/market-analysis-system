indexing
	description: "Configurations for obtaining tradable data from a database %
		%with an ODBC connection, read from a configuration file"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class DATABASE_CONFIGURATION inherit

	APP_CONFIGURATION
		rename
			make as ac_make
		redefine
			check_results
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	APPLICATION_CONSTANTS
		export
			{NONE} all
		end

	DATABASE_CONSTANTS
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			symbol := "[NONE]"
			ac_make
		end

	initialize_settings_table is
		do
			create settings.make (0)
			initialize_common_settings
			settings.extend ("", Data_source_specifier)
			settings.extend ("", User_id_specifier)
			settings.extend ("", Password_specifier)
			settings.extend ("", Stock_symbol_query_specifier)
			settings.extend ("", Stock_split_query_specifier)
			settings.extend ("", Stock_name_query_specifier)
			settings.extend ("", Daily_stock_symbol_field_specifier)
			settings.extend ("", Daily_stock_date_field_specifier)
			settings.extend ("", Daily_stock_open_field_specifier)
			settings.extend ("", Daily_stock_high_field_specifier)
			settings.extend ("", Daily_stock_low_field_specifier)
			settings.extend ("", Daily_stock_close_field_specifier)
			settings.extend ("", Daily_stock_volume_field_specifier)
			settings.extend ("", Intraday_stock_symbol_field_specifier)
			settings.extend ("", Intraday_stock_date_field_specifier)
			settings.extend ("", Intraday_stock_time_field_specifier)
			settings.extend ("", Intraday_stock_open_field_specifier)
			settings.extend ("", Intraday_stock_high_field_specifier)
			settings.extend ("", Intraday_stock_low_field_specifier)
			settings.extend ("", Intraday_stock_close_field_specifier)
			settings.extend ("", Intraday_stock_volume_field_specifier)
			settings.extend ("", Daily_stock_table_specifier)
			settings.extend ("", Intraday_stock_table_specifier)
			settings.extend ("", Daily_stock_query_tail_specifier)
			settings.extend ("", Intraday_stock_query_tail_specifier)

			settings.extend ("", Derivative_symbol_query_specifier)
			settings.extend ("", Derivative_split_query_specifier)
			settings.extend ("", Derivative_name_query_specifier)
			settings.extend ("", Daily_derivative_symbol_field_specifier)
			settings.extend ("", Daily_derivative_date_field_specifier)
			settings.extend ("", Daily_derivative_open_field_specifier)
			settings.extend ("", Daily_derivative_high_field_specifier)
			settings.extend ("", Daily_derivative_low_field_specifier)
			settings.extend ("", Daily_derivative_close_field_specifier)
			settings.extend ("", Daily_derivative_volume_field_specifier)
			settings.extend ("",
				Daily_derivative_open_interest_field_specifier)
			settings.extend ("", Intraday_derivative_symbol_field_specifier)
			settings.extend ("", Intraday_derivative_date_field_specifier)
			settings.extend ("", Intraday_derivative_time_field_specifier)
			settings.extend ("", Intraday_derivative_open_field_specifier)
			settings.extend ("", Intraday_derivative_high_field_specifier)
			settings.extend ("", Intraday_derivative_low_field_specifier)
			settings.extend ("", Intraday_derivative_close_field_specifier)
			settings.extend ("", Intraday_derivative_volume_field_specifier)
			settings.extend ("",
				Intraday_derivative_open_interest_field_specifier)
			settings.extend ("", Daily_derivative_table_specifier)
			settings.extend ("", Intraday_derivative_table_specifier)
			settings.extend ("", Daily_derivative_query_tail_specifier)
			settings.extend ("", Intraday_derivative_query_tail_specifier)

			settings.extend ("", Daily_stock_data_command_specifier)
			settings.extend ("", Intraday_stock_data_command_specifier)
			settings.extend ("", Daily_derivative_data_command_specifier)
			settings.extend ("", Intraday_derivative_data_command_specifier)
		end

feature -- Access

	db_name: STRING is
		do
			Result := settings @ Data_source_specifier
		ensure
			not_void: Result /= Void
		end

	user_name: STRING is
		do
			Result := settings @ User_id_specifier
		ensure
			not_void: Result /= Void
		end

	password: STRING is
		do
			Result := settings @ Password_specifier
		ensure
			not_void: Result /= Void
		end

	stock_symbol_query: STRING is
		do
			Result := settings @ Stock_symbol_query_specifier
		ensure
			not_void: Result /= Void
		end

	stock_split_query: STRING is
		do
			Result := settings @ Stock_split_query_specifier
		ensure
			not_void: Result /= Void
		end

	stock_name_query: STRING is
		do
			Result := clone (settings @ Stock_name_query_specifier)
			-- Replace the <symbol> and <uppersymbol> tokens with
			-- `symbol' and uppercase (`symbol').
			replace_tokens (Result, <<symbol_token, upper_symbol_token>>,
				<<symbol, uppercase_symbol>>)
print ("stock_name_query returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	daily_stock_data_command: STRING is
		require
			ok_to_use_this_spec: using_daily_stock_data_command
		do
			Result := clone (settings @ Daily_stock_data_command_specifier)
			if eod_start_date /= Void and eod_end_date /= Void then
				-- Replace the <symbol> token and date tokens with the
				-- `symbol' and the corresponding components of eod_start_date
				-- and eod_end_date.
				replace_tokens_using_dates (Result, eod_start_date,
					eod_end_date, False)
			end
print ("daily_stock_... returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	daily_stock_symbol_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_date_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_open_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_high_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_low_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_close_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_volume_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_data_command: STRING is
		require
			ok_to_use_this_spec: using_intraday_stock_data_command
		do
			Result := clone (settings @ Intraday_stock_data_command_specifier)
			if intraday_start_date /= Void and intraday_end_date /= Void then
				-- Replace the <symbol> token and date tokens with the
				-- `symbol' and the corresponding components of
				-- intraday_start_date and intraday_end_date.
				replace_tokens_using_dates (Result, intraday_start_date,
					intraday_end_date, True)
			end
print ("intraday_stock... returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	intraday_stock_symbol_field_name: STRING is
		do
			Result := settings @ Intraday_stock_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_date_field_name: STRING is
		do
			Result := settings @ Intraday_stock_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_time_field_name: STRING is
		do
			Result := settings @ Intraday_stock_time_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_open_field_name: STRING is
		do
			Result := settings @ Intraday_stock_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_high_field_name: STRING is
		do
			Result := settings @ Intraday_stock_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_low_field_name: STRING is
		do
			Result := settings @ Intraday_stock_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_close_field_name: STRING is
		do
			Result := settings @ Intraday_stock_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_volume_field_name: STRING is
		do
			Result := settings @ Intraday_stock_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_table_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_table_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_table_name: STRING is
		do
			Result := settings @ Intraday_stock_table_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_query_tail: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := settings @ Daily_stock_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_query_tail: STRING is
		do
			Result := settings @ Intraday_stock_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_symbol_query: STRING is
		do
			Result := settings @ Derivative_symbol_query_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_split_query: STRING is
		do
			Result := settings @ Derivative_split_query_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_name_query: STRING is
		do
			Result := clone (settings @ Derivative_name_query_specifier)
			-- Replace the <symbol> and <uppersymbol> tokens with
			-- `symbol' and uppercase (`symbol').
			replace_tokens (Result, <<symbol_token, upper_symbol_token>>,
				<<symbol, uppercase_symbol>>)
print ("derivative_name_query returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	daily_derivative_data_command: STRING is
		require
			ok_to_use_this_spec: using_daily_derivative_data_command
		do
			Result := clone (
				settings @ Daily_derivative_data_command_specifier)
			if eod_start_date /= Void and eod_end_date /= Void then
				-- Replace the <symbol> token and date tokens with the
				-- `symbol' and the corresponding components of eod_start_date
				-- and eod_end_date.
				replace_tokens_using_dates (Result, eod_start_date,
					eod_end_date, False)
			end
print ("daily_derivative... returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	daily_derivative_symbol_field_name: STRING is
		do
			Result := settings @ Daily_derivative_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_date_field_name: STRING is
		do
			Result := settings @ Daily_derivative_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_open_field_name: STRING is
		do
			Result := settings @ Daily_derivative_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_high_field_name: STRING is
		do
			Result := settings @ Daily_derivative_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_low_field_name: STRING is
		do
			Result := settings @ Daily_derivative_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_close_field_name: STRING is
		do
			Result := settings @ Daily_derivative_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_volume_field_name: STRING is
		do
			Result := settings @ Daily_derivative_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_open_interest_field_name: STRING is
		do
			Result :=
				settings @ Daily_derivative_open_interest_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_data_command: STRING is
		require
			ok_to_use_this_spec: using_intraday_derivative_data_command
		do
			Result := clone (
				settings @ Intraday_derivative_data_command_specifier)
			if intraday_start_date /= Void and intraday_end_date /= Void then
				-- Replace the <symbol> token and date tokens with the
				-- `symbol' and the corresponding components of
				-- intraday_start_date and intraday_end_date.
				replace_tokens_using_dates (Result, intraday_start_date,
					intraday_end_date, True)
			end
print ("intraday_derivative... returning " + Result + ".%N")
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_symbol_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_date_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_time_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_time_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_open_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_high_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_low_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_close_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_volume_field_name: STRING is
		do
			Result := settings @ Intraday_derivative_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_open_interest_field_name: STRING is
		do
			Result :=
				settings @ Intraday_derivative_open_interest_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_table_name: STRING is
		do
			Result := settings @ Daily_derivative_table_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_table_name: STRING is
		do
			Result := settings @ Intraday_derivative_table_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_query_tail: STRING is
		do
			Result := settings @ Daily_derivative_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_query_tail: STRING is
		do
			Result := settings @ Intraday_derivative_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

feature -- Status report

	daily_stock_data_available: BOOLEAN
			-- Does a specification exist for obtaining daily stock data?

	intraday_stock_data_available: BOOLEAN
			-- Does a specification exist for obtaining intraday stock data?

	daily_derivative_data_available: BOOLEAN
			-- Does a specification exist for obtaining daily derivative data?

	intraday_derivative_data_available: BOOLEAN
			-- Does a specification exist for obtaining intraday
			-- derivative data?

	using_daily_stock_data_command: BOOLEAN is
			-- Is the `daily_stock_data_command' being used to retrieve
			-- daily stock data rather than contructing the command with
			-- `daily_stock_symbol_field_name', etc.?
		do
			Result := daily_stock_data_available and
				not (settings @ Daily_stock_data_command_specifier).is_empty
		ensure
			data_available_if_true:
				Result implies daily_stock_data_available
		end

	using_intraday_stock_data_command: BOOLEAN is
			-- Is the `intraday_stock_data_command' being used to retrieve
			-- intraday stock data rather than contructing the command with
			-- `intraday_stock_symbol_field_name', etc.?
		do
			Result := intraday_stock_data_available and not (
				settings @ Intraday_stock_data_command_specifier).is_empty
		ensure
			data_available_if_true:
				Result implies intraday_stock_data_available
		end

	using_daily_derivative_data_command: BOOLEAN is
			-- Is the `daily_derivative_data_command' being used to retrieve
			-- daily derivative data rather than contructing the command with
			-- `daily_derivative_symbol_field_name', etc.?
		do
			Result := daily_derivative_data_available and not (
				settings @ Daily_derivative_data_command_specifier).is_empty
		ensure
			data_available_if_true:
				Result implies daily_derivative_data_available
		end

	using_intraday_derivative_data_command: BOOLEAN is
			-- Is the `intraday_derivative_data_command' being used to
			-- retrieve intraday derivative data rather than contructing
			-- the command with `intraday_derivative_symbol_field_name', etc.?
		do
			Result := intraday_derivative_data_available and not (settings @
				Intraday_derivative_data_command_specifier).is_empty
		ensure
			data_available_if_true:
				Result implies intraday_derivative_data_available
		end

	daily_stock_data_rule: BOOLEAN is
		do
			Result := using_daily_stock_data_command implies
				not daily_stock_data_command.is_empty
		ensure
			Result = using_daily_stock_data_command implies
				not daily_stock_data_command.is_empty
		end

feature {NONE} -- Implementation - Hook routine implementations

	configuration_type: STRING is "database"

	configuration_file_name: STRING is
		do
			if db_config_file_name = Void then
				Result := file_name_with_app_directory (
					Default_database_config_file_name)
			else
				Result := file_name_with_app_directory (db_config_file_name)
			end
		end

	check_results is
		local
			gs: expanded GLOBAL_SERVER
		do
			if not stock_symbol_query.is_empty then
				if daily_stock_data_command.is_empty then
					if not daily_stock_table_name.is_empty then
						check_for_missing_specs (<<
							daily_stock_symbol_field_name.is_empty,
								Daily_stock_symbol_field_specifier,
							daily_stock_date_field_name.is_empty,
								Daily_stock_date_field_specifier,
							(gs.command_line_options.opening_price and
							daily_stock_open_field_name.is_empty),
								Daily_stock_open_field_specifier,
							daily_stock_high_field_name.is_empty,
								Daily_stock_high_field_specifier,
							daily_stock_low_field_name.is_empty,
								Daily_stock_low_field_specifier,
							daily_stock_close_field_name.is_empty,
								Daily_stock_close_field_specifier,
							daily_stock_volume_field_name.is_empty,
							Daily_stock_volume_field_specifier>>, True)
						daily_stock_data_available := true
					end
				else
					daily_stock_data_available := true
				end
				if intraday_stock_data_command.is_empty then
					if not intraday_stock_table_name.is_empty then
						check_for_missing_specs (<<
							intraday_stock_symbol_field_name.is_empty,
								Intraday_stock_symbol_field_specifier,
							intraday_stock_date_field_name.is_empty,
								Intraday_stock_date_field_specifier,
							(gs.command_line_options.opening_price and
							intraday_stock_open_field_name.is_empty),
								Intraday_stock_open_field_specifier,
							intraday_stock_high_field_name.is_empty,
								Intraday_stock_high_field_specifier,
							intraday_stock_low_field_name.is_empty,
								Intraday_stock_low_field_specifier,
							intraday_stock_close_field_name.is_empty,
								Intraday_stock_close_field_specifier,
							intraday_stock_volume_field_name.is_empty,
							Intraday_stock_volume_field_specifier>>, True)
						intraday_stock_data_available := true
					end
				else
					intraday_stock_data_available := true
				end
			end
			if not derivative_symbol_query.is_empty then
				if daily_derivative_data_command.is_empty then
					if not daily_derivative_table_name.is_empty then
						check_for_missing_specs (<<
							daily_derivative_symbol_field_name.is_empty,
								Daily_derivative_symbol_field_specifier,
							daily_derivative_date_field_name.is_empty,
								Daily_derivative_date_field_specifier,
							(gs.command_line_options.opening_price and
							daily_derivative_open_field_name.is_empty),
								Daily_derivative_open_field_specifier,
							daily_derivative_high_field_name.is_empty,
								Daily_derivative_high_field_specifier,
							daily_derivative_low_field_name.is_empty,
								Daily_derivative_low_field_specifier,
							daily_derivative_close_field_name.is_empty,
								Daily_derivative_close_field_specifier,
							daily_derivative_volume_field_name.is_empty,
								Daily_derivative_volume_field_specifier,
							daily_derivative_open_interest_field_name.is_empty,
								Daily_derivative_open_interest_field_specifier
							>>, True)
						daily_derivative_data_available := true
					end
				else
					daily_derivative_data_available := true
				end
				if intraday_derivative_data_command.is_empty then
					if not intraday_derivative_table_name.is_empty then
						check_for_missing_specs (<<
							intraday_derivative_symbol_field_name.is_empty,
								Intraday_derivative_symbol_field_specifier,
							intraday_derivative_date_field_name.is_empty,
								Intraday_derivative_date_field_specifier,
							(gs.command_line_options.opening_price and
							intraday_derivative_open_field_name.is_empty),
								Intraday_derivative_open_field_specifier,
							intraday_derivative_high_field_name.is_empty,
								Intraday_derivative_high_field_specifier,
							intraday_derivative_low_field_name.is_empty,
								Intraday_derivative_low_field_specifier,
							intraday_derivative_close_field_name.is_empty,
								Intraday_derivative_close_field_specifier,
							intraday_derivative_volume_field_name.is_empty,
								Intraday_derivative_volume_field_specifier,
							intraday_derivative_open_interest_field_name.
								is_empty,
							Intraday_derivative_open_interest_field_specifier
							>>, True)
						intraday_derivative_data_available := true
					end
				else
					intraday_derivative_data_available := true
				end
			end
		end

invariant

	setting_relationship_rules: daily_stock_data_rule

end
