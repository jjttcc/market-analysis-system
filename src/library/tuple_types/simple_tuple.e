indexing
	description: "A single-value tuple."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_TUPLE inherit

	MARKET_TUPLE

	MATH_CONSTANTS

creation

	make

feature -- Initialization

	make (d: DATE_TIME; v: REAL) is
		do
			date_time := d
			value := v
		ensure
			date_set: date_time = d
			value_set: rabs (value - v) < epsilon
		end

feature -- Access

	value: REAL

feature {MARKET_FUNCTION} -- Status setting

	set_value (v: REAL) is
			-- Set value to `v'.
		do
			value := v
		ensure
			value_set: rabs (value - v) < epsilon
		end

end -- class SIMPLE_TUPLE
