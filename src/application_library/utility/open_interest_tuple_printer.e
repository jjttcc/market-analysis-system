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

	print_other_fields (t: MARKET_TUPLE)
		local
			oit: OPEN_INTEREST_TUPLE
		do
			oit ?= t
			if oit /= Void then
				Precursor (oit)
				put (field_separator)
				put (oit.open_interest.out)
			end
		end

end -- OPEN_INTEREST_TUPLE_PRINTER
