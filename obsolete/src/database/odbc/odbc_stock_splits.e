indexing
	description:
		"Implementation of STOCK_SPLIT_SEQUENCE as an ODBC_INPUT_SEQUENCE"
	author: "Jim Cochrane"
	note:
		"It is assumed that the for each symbol that occurs in the input %
		%file, the splits in the file for that symbol are sorted by %
		%date ascending"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ODBC_STOCK_SPLITS inherit

	STOCK_SPLIT_SEQUENCE
		rename
			make as sss_make
		select
			last_error_fatal
		end

	ODBC_INPUT_SEQUENCE
		rename
			make as ois_make,
			advance_to_next_field as ois_advance_to_next_field,
			advance_to_next_record as ois_advance_to_next_record,
			last_error_fatal as fatal_db_error
		export
			{NONE} all
			{ANY} fatal_db_error
		select
			ois_advance_to_next_field, ois_advance_to_next_record
		end

creation

	make

feature {NONE} -- Initialization

	make (ts: LINKED_LIST [DB_RESULT]) is
		require
			ts_not_void: ts /= Void
		do
			create product.make (100)
			tuple_sequence := ts
			sss_make
		ensure
			input_set: input = Current
			value_setters_made: value_setters /= Void
			prod_tpmkr_made: product /= Void and tuple_maker /= Void
			tuple_sequence_set: tuple_sequence = ts
		end

end -- ODBC_STOCK_SPLITS
