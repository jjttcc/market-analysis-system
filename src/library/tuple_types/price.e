indexing
	description:
		"Abstraction for a monetary value or any other value that %
		%can be represented as a whole and a fraction."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class PRICE inherit

	COMPARABLE

feature

	whole_part: INTEGER is
			-- integer part of the price value - for example, 3 in 3.75
		do
		end

	numerator: INTEGER is
			-- numerator part of the fraction
		do
		end

	denominator: INTEGER is
			-- denominator part of the fraction
		do
		end

	fraction: DOUBLE is
			-- fractional part as a real value - for example,
			-- .75 for value of 3.75
		do
		end

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
