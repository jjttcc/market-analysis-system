indexing
	description: 
		"A MARKET_TUPLE that functions as a point in a line"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_POINT inherit

	MARKET_TUPLE
		rename
			value as y
		end

creation

	make

feature -- Initialization

	make is
		do
		end

	set_x_y_date (x_value, y_value: REAL; d: DATE_TIME) is
		do
			x := x_value
			y := y_value
			date_time := d
		ensure
			set: x = x_value and y = y_value and date_time = d
		end

feature -- Access

	x: REAL
			-- x coordinate

	y: REAL
			-- y coordinate

feature {FACTORY} -- Status setting

	set_x_y (x_value, y_value: REAL) is
			-- Set x and y coordinates.
		do
			x := x_value
			y := y_value
		ensure
			set: x = x_value and y = y_value
		end

end -- class MARKET_POINT
