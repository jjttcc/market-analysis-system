note
	description:
		"A MARKET_TUPLE that functions as a point in a line"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_POINT inherit

	MARKET_TUPLE
		rename
			value as y
		redefine
			has_additional_queries
		end

creation

	make, default_create

feature -- Initialization

	make
		do
		end

	set_x_y_date (x_value, y_value: REAL; d: DATE_TIME)
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

feature -- Status report

	has_additional_queries: BOOLEAN = True

feature -- Status setting

	set_x_y (x_value, y_value: REAL)
			-- Set x and y coordinates.
		do
			x := x_value
			y := y_value
		ensure
			set: x = x_value and y = y_value
		end

	set_date (d: DATE_TIME)
			-- Set the date.
		require
			not_void: d /= Void
		do
			date_time := d
		ensure
			set: date_time = d
		end

	set_x (arg: REAL)
			-- Set x to `arg'.
		do
			x := arg
		ensure
			-- x = arg
		end

	set_y (arg: REAL)
			-- Set y to `arg'.
		do
			y := arg
		ensure
			-- y = arg
		end

end -- class MARKET_POINT
