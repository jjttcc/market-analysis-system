indexing
	description: 
		"Abstraction for a monetary value or any other value that %
		%can be represented as a whole and a fraction."
	date: "$Date$";
	revision: "$Revision$"

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

feature {MARKET_TUPLE} -- Element change

	set_value (v: REAL) is
			-- Is this the best way to set the price value?
		do
			value := v
		end

end -- class PRICE
