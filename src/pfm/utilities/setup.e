indexing
	description: "Functionality for setting up portfolio management - %
		%parsing command line, creating the trade list, etc."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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
		end

feature -- Access

	tradelist: LIST [TRADE_MATCH] is
		local
			trade_match_builder: TRADE_MATCH_BUILDER
			trade_builder: TRADE_BUILDER
			input_file: INPUT_FILE
			fs, rs: STRING
		do
			fs := "%T"; rs := "%N"
			print ("input file name is "); print (argument(1)); print ("%N")
			create input_file.make_open_read (argument(1))
			input_file.set_field_separator (fs)
			input_file.set_record_separator (rs)
			create trade_builder.make (fs, rs, input_file)
			trade_builder.execute
			create trade_match_builder.make (trade_builder.product)
			trade_match_builder.execute
			Result := trade_match_builder.product
		end

feature -- Basic operations

	usage is
		do
			print (concatenation (<<"usage: ", command_name,
				" portfolio_data_file%N">>))
		end

end -- SETUP
