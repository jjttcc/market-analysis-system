indexing
	description: "TA Printing services"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_MARKET_TUPLE_PRINTER inherit

	MARKET_TUPLE_PRINTER
		redefine
			print_fields
		end

creation

	make

feature {NONE} -- Implementation

	print_fields (t: BASIC_MARKET_TUPLE) is
		do
			print_date (t.end_date, 'y', 'm', 'd')
			output_medium.put_string (field_separator)
			if t.open_available then
				output_medium.put_string (t.open.value.out)
				output_medium.put_string (field_separator)
			end
			output_medium.put_string (t.high.value.out)
			output_medium.put_string (field_separator)
			output_medium.put_string (t.low.value.out)
			output_medium.put_string (field_separator)
			output_medium.put_string (t.close.value.out)
			print_other_fields (t)
		end

	print_other_fields (t: BASIC_MARKET_TUPLE) is
			-- Redefine for tuple printers that handle more than
			-- date, open, high, low, close.  Be sure to print the
			-- field_separator before the first 'other' field, and to
			-- not print the field_separator after the last field.
		do
			output_medium.put_string (field_separator)
		end

end -- BASIC_MARKET_TUPLE_PRINTER
