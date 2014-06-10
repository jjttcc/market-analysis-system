note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OPEN_INTEREST_TUPLE_PRINTER inherit

	VOLUME_TUPLE_PRINTER
		redefine
			print_other_fields
		end

creation

	make

feature {NONE} -- Implementation

	print_other_fields (t: OPEN_INTEREST_TUPLE)
		do
			Precursor (t)
			put (field_separator)
			put (t.open_interest.out)
		end

end -- OPEN_INTEREST_TUPLE_PRINTER
