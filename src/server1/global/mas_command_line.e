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

	file_names: LIST [STRING]
			-- Market data input file names

	symbol_list: LIST [STRING]
			-- Market data input symbols

	background: BOOLEAN
			-- Is the server run in the background?
			-- True if "-b" or "-background" is found.

	use_db: BOOLEAN
			-- Has the user specified that a database is to be used
			-- for input data?

	help: BOOLEAN
			-- Has the user requested help on command-line options?
			-- True if "-h" or "-?" is found.

	version_request: BOOLEAN
			-- Has the user requested the version number?
			-- True if "-v" is found.

feature -- Basic operations

	usage is
			-- Message: how to invoke the program from the comman-line
		do
			print (concatenation (<<"Usage: ", command_name,
				" [port_number ...] [-background]%
				% [input_file ...] [-o] %H%N[-f field_separator]%
				% [-h] [-v]%N%
				%    Where:%N        -o = data has an open field%N",
				            "        -v = print version number%N",
				            "        -h = print this help message%N",
				            "        -background = run in background%N">>))
		end

feature {NONE} -- Implementation

	contents: LINKED_LIST [STRING]

	set_field_separator is
			-- Set `field_separator' and remove its settings from `contents'
			-- Void if no field separator is specified
		do
			from
				contents.start
			until
				contents.exhausted or field_separator /= Void
			loop
				if
					contents.item.item (1) = option_sign and
					contents.item.item (2) = 'f'
				then
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
				else
					contents.forth
				end
			end
		end

	set_opening_price is
			-- Set `opening_price' and remove its setting from `contents'
			-- false if opening price option is not found
		do
			from
				contents.start
			until
				contents.exhausted or opening_price
			loop
				if
					contents.item.item (1) = option_sign and
					contents.item.item (2) = 'o'
				then
					opening_price := True
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_background is
		do
			from
				contents.start
			until
				contents.exhausted or background
			loop
				if
					contents.item.item (1) = option_sign and
					contents.item.item (2) = 'b'
				then
					background := True
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_use_db is
		do
			from
				contents.start
			until
				contents.exhausted or help
			loop
				if
					contents.item.item (1) = option_sign and
--!!!Change 'd' to whatever letter we decide to use for the use-database
--!!!option:
					contents.item.item (2) = 'd'
				then
					use_db := True
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_help is
		do
			from
				contents.start
			until
				contents.exhausted or help
			loop
				if
					contents.item.item (1) = option_sign and
					(contents.item.item (2) = 'h' or
					contents.item.item (2) = '?')
				then
					help := True
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_version_request is
		do
			from
				contents.start
			until
				contents.exhausted or version_request
			loop
				if
					contents.item.item (1) = option_sign and
					contents.item.item (2) = 'v'
				then
					version_request := True
					contents.remove
				else
					contents.forth
				end
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
			-- Set `symbol_list' and remove its settings from `contents'
			-- Empty if no symbols are specified
			-- Must be called last because it expects all other arguments
			-- to have been removed from `contents'.
			-- Will ignore arguments that start with `option_sign'
		require
			use_db
		do
			create {LINKED_LIST [STRING]} symbol_list.make
-- !!!extract symbols from `contents' and put them in `symbol_list'.
		end


invariant

	port_numbers_and_file_names_not_void:
		port_numbers /= Void and file_names /= Void
	use_db implies file_names = Void and symbol_list /= Void
	not use_db implies symbol_list = Void and file_names /= Void

end -- class MAS_COMMAND_LINE
