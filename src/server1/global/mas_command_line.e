indexing
	description: "Parser of command-line arguments for Market Analysis %
		%System server application"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_COMMAND_LINE inherit

	ARGUMENTS

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation {GLOBAL_SERVER}

	make

feature {NONE} -- Initialization

	make is
		local
			i: INTEGER
		do
			!!contents.make
			!LINKED_LIST [INTEGER]!port_numbers.make
			from
				i := 1
			until
				i = argument_count + 1
			loop
				contents.extend (argument (i))
				i := i + 1
			end
			set_field_separator
			set_opening_price
			set_background
			set_use_db
			set_help
			set_version_request
			set_port_numbers
			set_strict
			if not use_db then
				set_file_names
			else
				set_symbol_list
			end
		end

feature -- Access

	port_numbers: LIST [INTEGER]
			-- Port numbers for server sockets

	opening_price: BOOLEAN
			-- Does the data include opening price?
			-- True if "-o" is found.

	field_separator: STRING
			-- Field separator for (input) market data - Void if not set

	record_separator: STRING
			-- Record separator for (input) market data - Void if not set

	file_names: LIST [STRING]
			-- Market data input file names

	symbol_list: LIST [STRING]
			-- Market data input symbols

	background: BOOLEAN
			-- Is the server run in the background?
			-- True if "-b" is found.

	use_db: BOOLEAN
			-- Is a database to be used for market data?
			-- True if "-p" is found (p = persistent store)

	help: BOOLEAN
			-- Has the user requested help on command-line options?
			-- True if "-h" or "-?" is found.

	version_request: BOOLEAN
			-- Has the user requested the version number?
			-- True if "-v" is found.

	strict: BOOLEAN
			-- Use strict error checking?
			-- True if "-s" is found.

feature -- Basic operations

	usage is
			-- Message: how to invoke the program from the comman-line
		do
			print (concatenation (<<"Usage: ", command_name,
				" [port_number ...] [-b] [-p]%
				% [input_file ...] [-o] %H%N[-f field_separator]%
				% [-h] [-v]%N%
				%    Where:%N        -o = data has an open field%N",
				            "        -v = print version number%N",
				            "        -h = print this help message%N",
				            "        -s = strict error checking%N",
				            "        -p = use database (persistent store)%N",
				            "        -b = run in background%N">>))
		end

feature {NONE} -- Implementation

	contents: LINKED_LIST [STRING]

	set_field_separator is
			-- Set `field_separator' and remove its settings from `contents'
			-- Void if no field separator is specified
		do
			if option_in_contents ('f') then
				if contents.item.count > 2 then
					!!field_separator.make (contents.item.count - 2)
					field_separator.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						!!field_separator.make (contents.item.count)
						field_separator.append (contents.item)
						contents.remove
					end
				end
			end
		end

	set_opening_price is
			-- Set `opening_price' and remove its setting from `contents'
			-- false if opening price option is not found
		do
			if option_in_contents ('o') then
				opening_price := True
				contents.remove
			end
		end

	set_background is
		do
			if option_in_contents ('b') then
				background := True
				contents.remove
			end
		end

	set_strict is
		do
			if option_in_contents ('s') then
				strict := True
				contents.remove
			end
		end

	set_use_db is
		do
			if option_in_contents ('p') then
				use_db := True
				contents.remove
			end
		end

	set_help is
		do
			if option_in_contents ('h') then
				help := True
				contents.remove
			elseif option_in_contents ('?') then
					help := True
					contents.remove
			end
		end

	set_version_request is
		do
			if option_in_contents ('v') then
				version_request := True
				contents.remove
			end
		end

	set_port_numbers is
			-- Set `port_numbers' and remove its settings from `contents'
			-- Empty if no port numbers are specified
		do
			from
				contents.start
			until
				contents.exhausted
			loop
				if contents.item.is_integer then
					port_numbers.extend (contents.item.to_integer)
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_file_names is
			-- Set `file_names' and remove its settings from `contents'
			-- Empty if no file names are specified
			-- Must be called last because it expects all other arguments
			-- to have been removed from `contents'.
			-- Will ignore arguments that start with `option_sign'
		require
			not use_db
		local
			expander: FILE_NAME_EXPANDER
		do
			create expander.make (contents, option_sign)
			file_names := expander.results
		end

	set_symbol_list is
		require
			use_db
		local
			db_services: MAS_DB_SERVICES
		do
			symbol_list := db_services.symbols
		end

	option_in_contents (c: CHARACTER): BOOLEAN is
			-- Is option `c' in `contents'?
		do
			from
				contents.start
			until
				contents.exhausted or Result
			loop
				if
					contents.item.item (1) = option_sign and
					contents.item.item (2) = c
				then
					Result := True
				else
					contents.forth
				end
			end
		ensure
			Result implies contents.item.item (1) = option_sign and
				contents.item.item (2) = c
		end

invariant

	port_numbers_not_void: port_numbers /= Void
	use_db: use_db implies file_names = Void and symbol_list /= Void
	use_files: not use_db implies symbol_list = Void and file_names /= Void

end -- class MAS_COMMAND_LINE
