indexing
	description: "Functionality for setting up portfolio management - %
		%parsing command line, creating the trade list, etc."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SETUP inherit

	ARGUMENTS
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			if argument_count = 0 then
				usage
				die (-1)
			end
			create_lists
		end

feature -- Access

	tradelist: LIST [TRADE_MATCH]

	open_trades: LIST [OPEN_TRADE]

feature -- Basic operations

	usage is
		do
			print (concatenation (<<"usage: ", command_name,
				" portfolio_data_file%N">>))
		end

feature {NONE} -- Implementation

	create_lists is
		local
			trade_match_builder: TRADE_MATCH_BUILDER
			trade_builder: TRADE_BUILDER
			input_file: INPUT_FILE
			fs, rs: STRING
		do
			fs := "%T"; rs := "%N"
--print ("input file name is "); print (argument(1)); print ("%N")
			create input_file.make_open_read (argument(1))
			input_file.set_field_separator (fs)
			input_file.set_record_separator (rs)
			create trade_builder.make (fs, input_file)
			trade_builder.execute
			create trade_match_builder.make (trade_builder.product)
			trade_match_builder.execute
			tradelist := trade_match_builder.product
			open_trades := trade_match_builder.open_trades
		end

end -- SETUP
