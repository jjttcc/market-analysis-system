indexing
	description: 
		"A line whose two defining points are MARKET_POINTs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_LINE inherit

	SIMPLE_FUNCTION [MARKET_POINT]
		rename
			make as sf_make_unused
		export {NONE}
			sf_make_unused
		end

creation

	make

feature -- Initialization

	make (p1, p2: MARKET_POINT; period_type: TIME_PERIOD_TYPE) is
		require
			not_void: p1 /= Void and p2 /= Void and period_type /= Void
			p1_left_of_p2: p1.x < p2.x
			p1_earlier_than_p2: p1.date_time < p2.date_time
		do
			start_point := p1
			end_point := p2
			trading_period_type := period_type
			calculate_slope
		ensure
			set: start_point = p1 and end_point = p2 and
					trading_period_type = period_type
		end

feature -- Access

	start_point, end_point: MARKET_POINT
			-- The two points that define the line

	slope: REAL

feature {FACTORY} -- Status setting

	set_points (p1, p2: MARKET_POINT) is
			-- Set start_point to `p1' and end_point to `p2'.
		require
			not_void: p1 /= Void and p2 /= Void
			p1_left_of_p2: p1.x < p2.x
		do
			start_point := p1
			end_point := p2
			calculate_slope
		ensure
			start_point: start_point = p1 and start_point /= Void
			end_point_set: end_point = p2 and end_point /= Void
		end

feature {NONE} -- Implementation

	calculate_slope is
			-- Slope of the line
		do
			slope := (end_point.y - start_point.y) /
						(end_point.x - start_point.x)
		end

invariant

	start_left_of_end: start_point.x < end_point.x
	start_earlier_than_end: start_point.date_time < end_point.date_time

end -- class MARKET_POINT
