note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class OPEN_INTEREST_TUPLE_PRINTER inherit

	VOLUME_TUPLE_PRINTER
		redefine
			print_other_fields, tuple_type_anchor
		end

creation

	make

feature {NONE} -- Implementation

	tuple_type_anchor: OPEN_INTEREST_TUPLE
		do
			do_nothing
		end

	print_other_fields (t: like tuple_type_anchor)
		do
			Precursor (t)
			put (field_separator)
			put (t.open_interest.out)
		end

end -- OPEN_INTEREST_TUPLE_PRINTER
