indexing
	description: 
		"A line whose two defining points are MARKET_POINTs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	MARKET_LINE

creation

	make

feature -- Initialization

	make (p1, p2: MARKET_POINT) is
		require
			not_void: p1 /= Void and p2 /= Void
			p1_left_of_p2: p1.x < p2.x
			p1x_gt_0: p1.x > 0
		do
			start_point := p1
			end_point := p2
			calculate_slope
		ensure
			set: start_point = p1 and end_point = p2
		end

feature -- Access

	start_point, end_point: MARKET_POINT
			-- The two points that define the line

	slope: REAL
			-- Slope of the line

	y_at (x: INTEGER): REAL is
			-- y value at index (x-value) `x'
		do
			Result := (x - start_point.x) * slope + start_point.y
		end

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
	start_point_x_gt_0: start_point.x > 0

end -- class MARKET_LINE
