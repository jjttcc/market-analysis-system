note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class VOLUME_TUPLE_PRINTER inherit

	BASIC_MARKET_TUPLE_PRINTER
		redefine
			print_other_fields
		end

creation

	make

feature {NONE} -- Implementation

	print_other_fields (t: MARKET_TUPLE)
		local
			vt: VOLUME_TUPLE
		do
			vt ?= t
			if vt /= Void then
				put (field_separator)
				put (vt.volume.out)
			end
		end

end -- VOLUME_TUPLE_PRINTER
