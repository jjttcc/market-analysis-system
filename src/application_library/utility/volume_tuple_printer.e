indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE_PRINTER inherit

	BASIC_MARKET_TUPLE_PRINTER
		redefine
			print_other_fields
		end

creation

	make

feature {NONE} -- Implementation

	print_other_fields (t: VOLUME_TUPLE) is
		do
			output_medium.put_string (field_separator)
			output_medium.put_string (t.volume.out)
		end

end -- VOLUME_TUPLE_PRINTER
