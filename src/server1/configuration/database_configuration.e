indexing
	description: "Database-related parameters"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_DB_INFO inherit

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

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make is
			-- Initialize database settings from configuration file.
			-- If an error occurs reading the file, all query values
			-- will be empty strings.
		do
			create db_values.make (24)
			db_values.extend ("", Data_source_specifier)
			db_values.extend ("", User_id_specifier)
			db_values.extend ("", Password_specifier)
			db_values.extend ("", Stock_symbol_query_specifier)
			db_values.extend ("", Stock_split_query_specifier)
			db_values.extend ("", Stock_name_query_specifier)
			db_values.extend ("", Daily_stock_symbol_field_specifier)
			db_values.extend ("", Daily_stock_date_field_specifier)
			db_values.extend ("", Daily_stock_open_field_specifier)
			db_values.extend ("", Daily_stock_high_field_specifier)
			db_values.extend ("", Daily_stock_low_field_specifier)
			db_values.extend ("", Daily_stock_close_field_specifier)
			db_values.extend ("", Daily_stock_volume_field_specifier)
			db_values.extend ("", Intraday_stock_symbol_field_specifier)
			db_values.extend ("", Intraday_stock_date_field_specifier)
			db_values.extend ("", Intraday_stock_time_field_specifier)
			db_values.extend ("", Intraday_stock_open_field_specifier)
			db_values.extend ("", Intraday_stock_high_field_specifier)
			db_values.extend ("", Intraday_stock_low_field_specifier)
			db_values.extend ("", Intraday_stock_close_field_specifier)
			db_values.extend ("", Intraday_stock_volume_field_specifier)
			db_values.extend ("", Daily_stock_table_specifier)
			db_values.extend ("", Intraday_stock_table_specifier)
			db_values.extend ("", Daily_stock_query_tail_specifier)
			db_values.extend ("", Intraday_stock_query_tail_specifier)

			db_values.extend ("", Derivative_symbol_query_specifier)
			db_values.extend ("", Derivative_split_query_specifier)
			db_values.extend ("", Derivative_name_query_specifier)
			db_values.extend ("", Daily_derivative_symbol_field_specifier)
			db_values.extend ("", Daily_derivative_date_field_specifier)
			db_values.extend ("", Daily_derivative_open_field_specifier)
			db_values.extend ("", Daily_derivative_high_field_specifier)
			db_values.extend ("", Daily_derivative_low_field_specifier)
			db_values.extend ("", Daily_derivative_close_field_specifier)
			db_values.extend ("", Daily_derivative_volume_field_specifier)
			db_values.extend ("",
				Daily_derivative_open_interest_field_specifier)
			db_values.extend ("", Intraday_derivative_symbol_field_specifier)
			db_values.extend ("", Intraday_derivative_date_field_specifier)
			db_values.extend ("", Intraday_derivative_time_field_specifier)
			db_values.extend ("", Intraday_derivative_open_field_specifier)
			db_values.extend ("", Intraday_derivative_high_field_specifier)
			db_values.extend ("", Intraday_derivative_low_field_specifier)
			db_values.extend ("", Intraday_derivative_close_field_specifier)
			db_values.extend ("", Intraday_derivative_volume_field_specifier)
			db_values.extend ("",
				Intraday_derivative_open_interest_field_specifier)
			db_values.extend ("", Daily_derivative_table_specifier)
			db_values.extend ("", Intraday_derivative_table_specifier)
			db_values.extend ("", Daily_derivative_query_tail_specifier)
			db_values.extend ("", Intraday_derivative_query_tail_specifier)

			db_values.extend ("", Daily_stock_data_command_specifier)
			db_values.extend ("", Intraday_stock_data_command_specifier)
			db_values.extend ("", Daily_derivative_data_command_specifier)
			db_values.extend ("", Intraday_derivative_data_command_specifier)
			read_param_file
		end

feature -- Access

	db_name: STRING is
		do
			Result := db_values @ Data_source_specifier
		ensure
			not_void: Result /= Void
		end

	user_name: STRING is
		do
			Result := db_values @ User_id_specifier
		ensure
			not_void: Result /= Void
		end

	password: STRING is
		do
			Result := db_values @ Password_specifier
		ensure
			not_void: Result /= Void
		end

	stock_symbol_query: STRING is
		do
			Result := db_values @ Stock_symbol_query_specifier
		ensure
			not_void: Result /= Void
		end

	stock_split_query: STRING is
		do
			Result := db_values @ Stock_split_query_specifier
		ensure
			not_void: Result /= Void
		end

	stock_name_query: STRING is
		do
			Result := db_values @ Stock_name_query_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_data_command: STRING is
		require
			ok_to_use_this_spec: using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_data_command_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_symbol_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_date_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_open_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_high_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_low_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_close_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_volume_field_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_data_command: STRING is
		require
			ok_to_use_this_spec: using_intraday_stock_data_command
		do
			Result := db_values @ Intraday_stock_data_command_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_symbol_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_date_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_time_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_time_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_open_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_high_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_low_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_close_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_volume_field_name: STRING is
		do
			Result := db_values @ Intraday_stock_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_table_name: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_table_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_table_name: STRING is
		do
			Result := db_values @ Intraday_stock_table_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_query_tail: STRING is
		require
			ok_to_use_this_spec: not using_daily_stock_data_command
		do
			Result := db_values @ Daily_stock_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_stock_query_tail: STRING is
		do
			Result := db_values @ Intraday_stock_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_symbol_query: STRING is
		do
			Result := db_values @ Derivative_symbol_query_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_split_query: STRING is
		do
			Result := db_values @ Derivative_split_query_specifier
		ensure
			not_void: Result /= Void
		end

	derivative_name_query: STRING is
		do
			Result := db_values @ Derivative_name_query_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_data_command: STRING is
		require
			ok_to_use_this_spec: using_daily_derivative_data_command
		do
			Result := db_values @ Daily_derivative_data_command_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_symbol_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_date_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_open_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_high_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_low_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_close_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_volume_field_name: STRING is
		do
			Result := db_values @ Daily_derivative_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_open_interest_field_name: STRING is
		do
			Result :=
				db_values @ Daily_derivative_open_interest_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_data_command: STRING is
		require
			ok_to_use_this_spec: using_intraday_derivative_data_command
		do
			Result := db_values @ Intraday_derivative_data_command_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_symbol_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_date_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_time_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_time_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_open_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_high_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_low_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_close_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_volume_field_name: STRING is
		do
			Result := db_values @ Intraday_derivative_volume_field_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_open_interest_field_name: STRING is
		do
			Result :=
				db_values @ Intraday_derivative_open_interest_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_table_name: STRING is
		do
			Result := db_values @ Daily_derivative_table_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_table_name: STRING is
		do
			Result := db_values @ Intraday_derivative_table_specifier
		ensure
			not_void: Result /= Void
		end

	daily_derivative_query_tail: STRING is
		do
			Result := db_values @ Daily_derivative_query_tail_specifier
		ensure
			not_void: Result /= Void
		end

	intraday_derivative_query_tail: STRING is
		do
			Result := db_values @ Intraday_derivative_query_tail_specifier
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
				not (db_values @ Daily_stock_data_command_specifier).empty
		ensure
			data_available_if_true:
				Result implies daily_stock_data_available
		end

	using_intraday_stock_data_command: BOOLEAN is
			-- Is the `intraday_stock_data_command' being used to retrieve
			-- intraday stock data rather than contructing the command with
			-- `intraday_stock_symbol_field_name', etc.?
		do
			Result := intraday_stock_data_available and
				not (db_values @ Intraday_stock_data_command_specifier).empty
		ensure
			data_available_if_true:
				Result implies intraday_stock_data_available
		end

	using_daily_derivative_data_command: BOOLEAN is
			-- Is the `daily_derivative_data_command' being used to retrieve
			-- daily derivative data rather than contructing the command with
			-- `daily_derivative_symbol_field_name', etc.?
		do
			Result := daily_derivative_data_available and
				not (db_values @ Daily_derivative_data_command_specifier).empty
		ensure
			data_available_if_true:
				Result implies daily_derivative_data_available
		end

	using_intraday_derivative_data_command: BOOLEAN is
			-- Is the `intraday_derivative_data_command' being used to
			-- retrieve intraday derivative data rather than contructing
			-- the command with `intraday_derivative_symbol_field_name', etc.?
		do
			Result := intraday_derivative_data_available and not (
				db_values @ Intraday_derivative_data_command_specifier).empty
		ensure
			data_available_if_true:
				Result implies intraday_derivative_data_available
		end

	daily_stock_data_rule: BOOLEAN is
		do
			Result := using_daily_stock_data_command implies
				not daily_stock_data_command.empty
		ensure
			Result = using_daily_stock_data_command implies
				not daily_stock_data_command.empty
		end

feature {NONE} -- Implementation

	Field_separator: STRING is "%T"

	Record_separator: STRING is "%N"

	Continuation_character: CHARACTER is '\'

	key_ix: INTEGER is 1

	value_ix: INTEGER is 2

	db_parameters_file: STRING is
		do
			if db_config_file_name = Void then
				Result := file_name_with_app_directory (
					Default_database_config_file_name)
			else
				Result := file_name_with_app_directory (db_config_file_name)
			end
		end

	db_values: HASH_TABLE [STRING, STRING]

	current_line: INTEGER

	su: expanded STRING_UTILITIES

	current_tokens (file_reader: MAS_FILE_READER): LIST [STRING] is
			-- Tokens for the current "line" of `file_reader'
		local
			s, tgt: STRING
		do
			from
				s := file_reader.item
			until
				s.item (s.count) /= Continuation_character or
				file_reader.exhausted
			loop
				file_reader.forth
				current_line := current_line + 1
				if not file_reader.exhausted then
					s.append (file_reader.item)
				end
			end
			s.prune_all (Continuation_character)
			su.set_target (s)
			Result := su.tokens (Field_separator)
		end

	read_param_file is
		local
			tokens: LIST [STRING]
			file_reader: MAS_FILE_READER
		do
			create file_reader.make (db_parameters_file)
			file_reader.tokenize (Record_separator)
			if not file_reader.error then
				from
					current_line := 1
				until
					file_reader.exhausted
				loop
					if
						not (file_reader.item.count = 0 or else
							file_reader.item @ 1 = Comment_character)
					then
						tokens := current_tokens (file_reader)
						if tokens.count >= 2 then
							db_values.replace (tokens @ value_ix,
								tokens @ key_ix)
							if db_values.not_found then
								log_errors (<<"Invalid identifier in",
									" database configuration file at line ",
									current_line, ": ",
									tokens @ key_ix, ".%N">>)
							end
						else
							log_errors (<<"Wrong number of fields in",
									" database configuration file at line ",
									current_line, ": ",
									file_reader.item, ".%N">>)
						end
					end
					file_reader.forth
					current_line := current_line + 1
				end
			else
				log_errors (<<"Error reading database configuration file: ",
					file_reader.error_string, "%N">>)
				raise_fatal_exception
			end
			check_results
		end

	raise_fatal_exception is
		local
			gs: expanded EXCEPTION_SERVICES
			ex: expanded EXCEPTIONS
		do
			gs.last_exception_status.set_fatal (true)
			ex.raise ("Fatal error reading database configuration file")
		end

	check_for_missing_specs (ftbl: ARRAY[ANY]) is
			-- Check for missing database field specs in `ftbl'.   Expected
			-- types of ftbl's contents are: <<BOOLEAN, STRING,
			-- BOOLEAN, STRING, ...>>.
		require
			count_even: ftbl.count \\ 2 = 0
		local
			s: STRING
			i: INTEGER
			emtpy: BOOLEAN_REF
			all_empty, problem: BOOLEAN
			gs: expanded EXCEPTION_SERVICES
			ex: expanded EXCEPTIONS
		do
			from i := 1; all_empty := true until i > ftbl.count loop
				emtpy ?= ftbl @ i
				check
					correct_type: emtpy /= Void
				end
				if emtpy.item then
					s := concatenation (<<s, "Missing specification in ",
						"database configuration file:%N",
						ftbl @ (i+1), ".%N">>)
					problem := true
				else
					all_empty := false
				end
				i := i + 2
			end
			if problem and not all_empty then
				log_error (s)
				gs.last_exception_status.set_fatal (true)
				ex.raise ("Fatal error reading database configuration file")
			end
		end

	check_results is
			-- Check if all needed fields were set and make any needed
			-- settings adjustments.
		local
			gs: expanded GLOBAL_SERVER
		do
			if not stock_symbol_query.empty then
				if daily_stock_data_command.empty then
					if not daily_stock_table_name.empty then
						check_for_missing_specs (<<
							daily_stock_symbol_field_name.empty,
								Daily_stock_symbol_field_specifier,
							daily_stock_date_field_name.empty,
								Daily_stock_date_field_specifier,
							(gs.command_line_options.opening_price and
							daily_stock_open_field_name.empty),
								Daily_stock_open_field_specifier,
							daily_stock_high_field_name.empty,
								Daily_stock_high_field_specifier,
							daily_stock_low_field_name.empty,
								Daily_stock_low_field_specifier,
							daily_stock_close_field_name.empty,
								Daily_stock_close_field_specifier,
							daily_stock_volume_field_name.empty,
							Daily_stock_volume_field_specifier>>)
						daily_stock_data_available := true
					end
				else
					daily_stock_data_available := true
				end
				if intraday_stock_data_command.empty then
					if not intraday_stock_table_name.empty then
						check_for_missing_specs (<<
							intraday_stock_symbol_field_name.empty,
								Intraday_stock_symbol_field_specifier,
							intraday_stock_date_field_name.empty,
								Intraday_stock_date_field_specifier,
							(gs.command_line_options.opening_price and
							intraday_stock_open_field_name.empty),
								Intraday_stock_open_field_specifier,
							intraday_stock_high_field_name.empty,
								Intraday_stock_high_field_specifier,
							intraday_stock_low_field_name.empty,
								Intraday_stock_low_field_specifier,
							intraday_stock_close_field_name.empty,
								Intraday_stock_close_field_specifier,
							intraday_stock_volume_field_name.empty,
							Intraday_stock_volume_field_specifier>>)
						intraday_stock_data_available := true
					end
				else
					intraday_stock_data_available := true
				end
			end
			if not derivative_symbol_query.empty then
				if daily_derivative_data_command.empty then
					if not daily_derivative_table_name.empty then
						check_for_missing_specs (<<
							daily_derivative_symbol_field_name.empty,
								Daily_derivative_symbol_field_specifier,
							daily_derivative_date_field_name.empty,
								Daily_derivative_date_field_specifier,
							(gs.command_line_options.opening_price and
							daily_derivative_open_field_name.empty),
								Daily_derivative_open_field_specifier,
							daily_derivative_high_field_name.empty,
								Daily_derivative_high_field_specifier,
							daily_derivative_low_field_name.empty,
								Daily_derivative_low_field_specifier,
							daily_derivative_close_field_name.empty,
								Daily_derivative_close_field_specifier,
							daily_derivative_volume_field_name.empty,
								Daily_derivative_volume_field_specifier,
							daily_derivative_open_interest_field_name.empty,
								Daily_derivative_open_interest_field_specifier
							>>)
						daily_derivative_data_available := true
					end
				else
					daily_derivative_data_available := true
				end
				if intraday_derivative_data_command.empty then
					if not intraday_derivative_table_name.empty then
						check_for_missing_specs (<<
							intraday_derivative_symbol_field_name.empty,
								Intraday_derivative_symbol_field_specifier,
							intraday_derivative_date_field_name.empty,
								Intraday_derivative_date_field_specifier,
							(gs.command_line_options.opening_price and
							intraday_derivative_open_field_name.empty),
								Intraday_derivative_open_field_specifier,
							intraday_derivative_high_field_name.empty,
								Intraday_derivative_high_field_specifier,
							intraday_derivative_low_field_name.empty,
								Intraday_derivative_low_field_specifier,
							intraday_derivative_close_field_name.empty,
								Intraday_derivative_close_field_specifier,
							intraday_derivative_volume_field_name.empty,
								Intraday_derivative_volume_field_specifier,
							intraday_derivative_open_interest_field_name.empty,
							Intraday_derivative_open_interest_field_specifier
							>>)
						intraday_derivative_data_available := true
					end
				else
					intraday_derivative_data_available := true
				end
			end
		end

invariant

	setting_relationship_rules: daily_stock_data_rule

end -- class MAS_DB_INFO
