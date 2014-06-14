note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_MARKET_TUPLE_PRINTER inherit

	MARKET_TUPLE_PRINTER
		redefine
			print_fields, print_fields_with_time
		end

creation

	make

feature {NONE} -- Implementation

	print_fields (t: BASIC_MARKET_TUPLE)
		do
			print_date (t.end_date, 'y', 'm', 'd')
			put (field_separator)
			if t.open_available then
				put (t.open.value.out)
				put (field_separator)
			end
			put (t.high.value.out)
			put (field_separator)
			put (t.low.value.out)
			put (field_separator)
			put (t.close.value.out)
			print_other_fields (t)
		end

	print_fields_with_time (t: BASIC_MARKET_TUPLE)
		do
			print_date (t.end_date, 'y', 'm', 'd')
			put (field_separator)
			print_time (t.date_time.time, 'h', 'm', 's')
			put (field_separator)
			if t.open_available then
				put (t.open.value.out)
				put (field_separator)
			end
			put (t.high.value.out)
			put (field_separator)
			put (t.low.value.out)
			put (field_separator)
			put (t.close.value.out)
			print_other_fields (t)
		end

	print_other_fields (t: MARKET_TUPLE)
			-- Redefine for tuple printers that handle more than
			-- date, open, high, low, close.  Be sure to print the
			-- field_separator before the first 'other' field, and to
			-- not print the field_separator after the last field.
		do
			put (field_separator)
		end

end -- BASIC_MARKET_TUPLE_PRINTER
