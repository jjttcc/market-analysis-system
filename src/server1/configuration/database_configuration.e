indexing
	description: "Database-related parameters"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_DB_INFO

creation
	make

feature --initialisation

	make (param_file: STRING) is
		require
			param_file /= void
	do
		db_parameters_file := clone(param_file)
		create host_variables.make(0); host_variables.start
		create trades_tables.make(0); trades_tables.start
		read_param_file
	end

feature --access

	db_parameters_file: STRING

	db_name: STRING

	set_db_name(name: STRING) is
	do
		db_name:= clone(name)
	end

	user_name: STRING

	set_user_name(name: STRING) is
	do
		user_name:= clone(name)
	end

	password: STRING

	set_password(pwd: STRING) is
	do
		password:= clone(pwd)
	end

	symbol_select: STRING

	set_symbol_select(sql: STRING) is
	do
		symbol_select := clone(sql)
	end

	market_select: STRING

	set_market_select(sql: STRING) is
	do
		market_select:= clone(sql)
	end
	
	host_variables: HASH_TABLE[STRING, STRING]

	set_host_variable(host_var, host_var_name: STRING) is
		require
			valid_host_var: host_var /= void
			host_var_not_present: not host_variables.has(host_var_name)
	do
		host_variables.extend(host_var, host_var_name)
	end

	trades_tables: ARRAYED_LIST[STRING]

	set_trades_table(name: STRING) is
	do
		trades_tables.extend(clone(name))
	end

feature {NONE} -- implementation

	read_param_file is
		local
			tokens		: LIST[STRING]
			su			: STRING_UTILITIES
			file_reader	: MAS_FILE_READER
	do
		!!file_reader.make(db_parameters_file)
		file_reader.tokenize("%N")
		from
		until
			file_reader.exhausted
		loop
			!!su.make(file_reader.item)
			tokens:= su.tokens("%T")
			tokens.start;
			if tokens.item.is_equal("data_source_name") then
				tokens.forth
				set_db_name(tokens.item)
			end
			if tokens.item.is_equal("user_id") then
				tokens.forth
				set_user_name(tokens.item)
			end
			if tokens.item.is_equal("password") then
				tokens.forth
				set_password(tokens.item)
			end
			if tokens.item.is_equal("symbol_select") then
				tokens.forth
				set_symbol_select(tokens.item)
			end
			if tokens.item.is_equal("market_select") then
				tokens.forth
				set_market_select(tokens.item)
			end
			if tokens.item.is_equal("symbol_name") then
				tokens.forth
				set_host_variable(tokens.item, "symbol_name")
			end
			if tokens.item.is_equal("date_name") then
				tokens.forth
				set_host_variable(tokens.item, "date_name")
			end
			if tokens.item.is_equal("relation") then
				from
				tokens.forth
				until
					tokens.after
				loop
					set_trades_table(tokens.item)
					tokens.forth
				end
				tokens.start
			end
			file_reader.forth
		end
	end

end --class MAS_DB_INFO
