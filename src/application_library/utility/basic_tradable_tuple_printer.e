note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class BASIC_TRADABLE_TUPLE_PRINTER inherit

	TRADABLE_TUPLE_PRINTER
		redefine
			print_fields, print_fields_with_time, tuple_type_anchor
		end

creation

	make

feature {NONE} -- Implementation

	tuple_type_anchor: BASIC_TRADABLE_TUPLE
		do
			do_nothing
		end

	print_fields (t: like tuple_type_anchor)
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

	print_fields_with_time (t: like tuple_type_anchor)
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

	print_other_fields (t: like tuple_type_anchor)
			-- Redefine for tuple printers that handle more than
			-- date, open, high, low, close.  Be sure to print the
			-- field_separator before the first 'other' field, and to
			-- not print the field_separator after the last field.
		do
			put (field_separator)
		end

end -- BASIC_TRADABLE_TUPLE_PRINTER
