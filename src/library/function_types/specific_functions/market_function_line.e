indexing
	description: 
		"A MARKET_LINE that can be analyzed as a MARKET_FUNCTION"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_FUNCTION_LINE inherit

	SIMPLE_FUNCTION [MARKET_POINT]
		rename
			make as sf_make
		end

	MARKET_LINE
		rename
			make as ml_make
		undefine
			is_equal, copy, setup
		end

creation

	make

feature -- Initialization

	make (p1, p2: MARKET_POINT; period_type: TIME_PERIOD_TYPE) is
		require
			not_void: p1 /= Void and p2 /= Void
			p1_left_of_p2: p1.x < p2.x
		do
			ml_make (p1, p2)
			sf_make (period_type)
		ensure
			set: start_point = p1 and end_point = p2
		end

feature {NONE} -- Implementation

	initialize is
			-- Initialize all elements of the list.
		local
			i: INTEGER
			date: DATE_TIME
			p: MARKET_POINT
		do
			from
				i := 1
				date := first_date
			until
				i > count
			loop
				!!p.make
				p.set_x_y_date (i, y_at (i), date)
				i := i + 1
				increment_date (date)
			end
		end

	first_date: DATE_TIME is
			-- Date of the tuple at index 1
		do
			-- !!!To be defined.
		end

	increment_date (d: DATE_TIME) is
			-- Increment `d' by one trading period.
		do
			-- !!!To be defined.
		end

end -- class MARKET_FUNCTION_LINE
