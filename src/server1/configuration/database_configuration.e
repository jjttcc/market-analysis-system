indexing
	description: "Database-related parameters"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	daily_stock_symbol_field_name: STRING is
		do
			Result := db_values @ Daily_stock_symbol_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_date_field_name: STRING is
		do
			Result := db_values @ Daily_stock_date_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_open_field_name: STRING is
		do
			Result := db_values @ Daily_stock_open_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_high_field_name: STRING is
		do
			Result := db_values @ Daily_stock_high_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_low_field_name: STRING is
		do
			Result := db_values @ Daily_stock_low_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_close_field_name: STRING is
		do
			Result := db_values @ Daily_stock_close_field_specifier
		ensure
			not_void: Result /= Void
		end

	daily_stock_volume_field_name: STRING is
		do
			Result := db_values @ Daily_stock_volume_field_specifier
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

feature {NONE} -- Implementation

	Field_separator: STRING is "%T"

	Record_separator: STRING is "%N"

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

	read_param_file is
		local
			tokens: LIST [STRING]
			su: STRING_UTILITIES
			file_reader: MAS_FILE_READER
			line: INTEGER
		do
			create file_reader.make (db_parameters_file)
			file_reader.tokenize (Record_separator)
			if not file_reader.error then
				create su.make ("")
				from
					line := 1
				until
					file_reader.exhausted
				loop
					if
						not (file_reader.item.count = 0 or else
							file_reader.item @ 1 = Comment_character)
					then
						su.make (file_reader.item)
						tokens := su.tokens (Field_separator)
						if tokens.count >= 2 then
							db_values.replace (tokens @ value_ix,
								tokens @ key_ix)
							if db_values.not_found then
								log_errors (<<"Invalid identifier in",
									" database configuration file at line ",
									line, ": ", tokens @ key_ix, ".%N">>)
							end
						else
							log_errors (<<"Wrong number of fields in",
									" database configuration file at line ",
									line, ": ", file_reader.item, ".%N">>)
						end
					end
					file_reader.forth
					line := line + 1
				end
			else
				log_errors (<<"Error reading database configuration file: ",
					file_reader.error_string, "%N">>)
			end
		end

end --class MAS_DB_INFO
