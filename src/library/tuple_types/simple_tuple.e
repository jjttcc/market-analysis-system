indexing
	description: "A single-value tuple."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_TUPLE inherit

	MARKET_TUPLE

creation

	make

feature -- Initialization

	make (d: DATE_TIME; v: REAL) is
		do
			date_time := d
			value := v
		ensure
			set: date_time = d and value = v
		end

feature -- Access

	value: REAL

feature {MARKET_FUNCTION} -- Status setting

	set_value (v: REAL) is
			-- Set value to `v'.
		do
			value := v
		ensure
			value = v
		end

end -- class SIMPLE_TUPLE
