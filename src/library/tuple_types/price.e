indexing
	description:
		"Abstraction for a monetary value that can be compared with other %
		%monetary values."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class PRICE inherit

	COMPARABLE

feature

	value: REAL
			-- price value as a real number - for example,
			-- 3.75 when whole_part = 3 and fraction = .75
			-- (For now, this is an attribute that holds the price's
			-- value.  Need to design this.)

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN is
		do
			Result := value < other.value
		end

feature -- Status setting

	set_value (v: REAL) is
		do
			value := v
		end

end -- class PRICE
