indexing
	description:
		"Implementation of STOCK_SPLIT_SEQUENCE as an ECLI_INPUT_SEQUENCE"
	author: "Jim Cochrane"
	note:
		"It is assumed that the for each symbol that occurs in the input %
		%file, the splits in the file for that symbol are sorted by %
		%date ascending"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class ECLI_STOCK_SPLITS inherit

	STOCK_SPLIT_SEQUENCE
		rename
			make as sss_make
		select
			last_error_fatal
		end

	ECLI_INPUT_SEQUENCE
		rename
			make as eis_make,
			advance_to_next_field as eis_advance_to_next_field,
			advance_to_next_record as eis_advance_to_next_record,
			last_error_fatal as fatal_db_error
		export
			{NONE} all
			{ANY} fatal_db_error
		select
			eis_advance_to_next_field, eis_advance_to_next_record
		end

creation

	make

feature {NONE} -- Initialization

	make (statement: ECLI_STATEMENT) is
		require
			statement_not_void: statement /= Void
		do
			create product.make (100)
			tuple_sequence := statement
			sss_make
		ensure
			input_set: input = Current
			value_setters_made: value_setters /= Void
			prod_tpmkr_made: product /= Void and tuple_maker /= Void
		end

end -- ECLI_STOCK_SPLITS
