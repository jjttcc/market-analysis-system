indexing
	description: "An input record sequence for a database implementation"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ODBC_INPUT_SEQUENCE inherit

	DB_INPUT_SEQUENCE

creation

	make

feature -- Initialization

	make (ts: LINKED_LIST[DB_RESULT]) is
		require
			ts_not_void: ts /= Void
		do
			set_tuple_sequence (ts)
		ensure
			tuple_sequence = ts
		end

feature -- Access

	record_index: INTEGER is
		do
			Result := tuple_sequence.index
		end

	tuple_sequence: LINKED_LIST[DB_RESULT]

feature -- Status report

	after_last_record: BOOLEAN is
		do
			Result := tuple_sequence.after
		end

	readable: BOOLEAN is
		do
			Result := not tuple_sequence.off
		end

feature -- Cursor movement

	advance_to_next_record is
		do
			tuple_sequence.forth
			if not after_last_record then
				tuple ?= tuple_sequence.item.data			
			end
			field_index := 1
		end

	start is
		do
			tuple_sequence.start
			field_index := 1
			error_occurred := false
		end

feature -- Element change

	set_tuple_sequence (ts: LINKED_LIST[DB_RESULT]) is
		require
			valid_sequence: ts /= Void
		do
			tuple_sequence := ts
			if ts.count > 0 then
				tuple_sequence.start
				check field_index = 1 end
				tuple ?= tuple_sequence.item.data
			end
		ensure
			tuple_sequence = ts
		end

feature {NONE} -- Implementation

	tuple: DATABASE_DATA[DATABASE]

	current_field: ANY is
		do
			Result := tuple.item (field_index)
		end

invariant

	tuple_sequence /= Void

end -- class ODBC_INPUT_SEQUENCE
