indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class OPEN_INTEREST_TUPLE_PRINTER inherit

	VOLUME_TUPLE_PRINTER
		redefine
			print_other_fields
		end

creation

	make

feature {NONE} -- Implementation

	print_other_fields (t: OPEN_INTEREST_TUPLE) is
		do
			precursor (t)
			output_medium.put_string (field_separator)
			output_medium.put_string (t.open_interest.out)
		end

end -- OPEN_INTEREST_TUPLE_PRINTER
