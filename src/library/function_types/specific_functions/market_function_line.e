indexing
	description: 
		"A MARKET_LINE that can be analyzed as a MARKET_FUNCTION"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_FUNCTION_LINE inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		export
			{NONE} ovf_make
		redefine
			action, operator_used, start, immediate_parameters
		end

	MARKET_LINE
		rename
			make_from_2_points as ml_make_from_2_points
		export
			{NONE} make_from_slope, ml_make_from_2_points
			{SLOPE_FUNCTION_PARAMETER, MARKET_FUNCTION_EDITOR} set_slope
			{START_Y_FUNCTION_PARAMETER, MARKET_FUNCTION_EDITOR} set_start_y
		undefine
			is_equal, copy, setup
		end

creation

	make, make_from_2_points

feature -- Initialization

	make (p1: MARKET_POINT; sl: REAL; in: like input) is
			-- Make the line with p1 as the start point, sl as the slope.
		require
			not_void: p1 /= Void and in /= Void
			p1_x_is_1: p1.x.floor = 1
		do
			make_from_slope (p1, sl)
			ovf_make (in, Void)
		ensure
			set: start_point = p1
			-- slope = sl
		end

	make_from_2_points (p1, p2: MARKET_POINT; in: like input) is
			-- Make the line with p1 as the start point; obtain the slope
			-- from p1 and p2.
		require
			not_void: p1 /= Void and p2 /= Void and in /= Void
			p1_x_is_1: p1.x.floor = 1
		do
			ml_make_from_2_points (p1, p2)
			ovf_make (in, Void)
		ensure
			set: start_point = p1
		end

feature {NONE} -- Implemetation

	start is
		do
			if not target.empty then
				start_point.set_date (target.first.date_time)
			end
			Precursor
			check target.index = 1 end
		end

	action is
		local
			t: MARKET_POINT
		do
			!!t.make
			t.set_x_y_date (target.index, y_at (target.index),
							target.item.date_time)
			output.extend (t)
		end

	operator_used: BOOLEAN is false

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
		local
			sfp: SLOPE_FUNCTION_PARAMETER
			syfp: START_Y_FUNCTION_PARAMETER
		do
			!LINKED_LIST [FUNCTION_PARAMETER]!Result.make
			!!sfp.make (Current)
			Result.extend (sfp)
			!!syfp.make (Current)
			Result.extend (syfp)
		end


end -- class MARKET_FUNCTION_LINE
