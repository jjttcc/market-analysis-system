indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
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
			-- Redefine for tuple printers that handle more than
			-- date, open, high, low, close.  Be sure to print the
			-- field_separator before the first 'other' field.
		do
			output_medium.put_string (field_separator)
			output_medium.put_string (t.volume.out)
		end

end -- VOLUME_TUPLE_PRINTER
