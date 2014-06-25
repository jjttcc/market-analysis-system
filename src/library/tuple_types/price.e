note
	description:
		"Abstraction for a monetary value that can be compared with other %
		%monetary values."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class PRICE inherit

	COMPARABLE

feature

	value: DOUBLE
			-- price value as a real number - for example,
			-- 3.75 when whole_part = 3 and fraction = .75
			-- (For now, this is an attribute that holds the price's
			-- value.  Need to design this.)

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN
		do
			Result := value < other.value
		end

feature -- Status setting

	set_value (v: DOUBLE)
		do
			value := v
		end

end -- class PRICE
