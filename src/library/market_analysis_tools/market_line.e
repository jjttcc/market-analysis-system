indexing
	description:
		"A line whose two defining points are MARKET_POINTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	MARKET_LINE

creation

	make_from_slope, make_from_2_points

feature -- Initialization

	make_from_2_points (p1, p2: MARKET_POINT) is
		require
			not_void: p1 /= Void and p2 /= Void
			p1_left_of_p2: p1.x < p2.x
			p1x_gt_0: p1.x >= 0
		do
			start_point := p1
			calculate_slope (p2)
		ensure
			set: start_point = p1
		end

	make_from_slope (startp: MARKET_POINT; s: REAL) is
		require
			startp /= Void and startp.x > 0
		do
			start_point := startp
			slope := s
		ensure
			start_point_set: start_point = startp
			-- slope = s
		end

feature -- Access

	start_point: MARKET_POINT
			-- The two points that define the line

	start_y: REAL is
			-- y value of the start point
		do
			Result := start_point.y
		end

	slope: REAL
			-- Slope of the line

	y_at (x: INTEGER): REAL is
			-- y value at index (x-value) `x'
		do
			Result := (x - start_point.x) * slope + start_point.y
		end

feature -- Status setting

	set_slope (v: REAL) is
			-- Set slope to `v'.
		require
			v_not_void: v /= Void
		do
			slope := v
		ensure
			-- slope = v
		end

	set_start_y (v: REAL) is
			-- Set start_y to `v'.
		require
			v_not_void: v /= Void
		do
			start_point.set_y (v)
		ensure
			-- start_y = v
		end

feature {NONE} -- Implementation

	calculate_slope (other_point: MARKET_POINT) is
			-- Slope of the line
		do
			slope := (other_point.y - start_point.y) /
						(other_point.x - start_point.x)
		end

invariant

	start_point_x_ge_0: start_point.x >= 0

end -- class MARKET_LINE
