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
			action, operator_used, start
		end

	MARKET_LINE
		rename
			make_from_2_points as ml_make_from_2_points
		export
			{NONE} make_from_slope, ml_make_from_2_points
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

feature -- Access

feature {NONE} -- Implemetation

	point_at_current_index: MARKET_POINT is
			-- A market point with appropriate values for the current `index'
		local
			date: DATE_TIME
			duration, tpt_duration: DATE_TIME_DURATION
			interval: INTEGER
		do
			!!Result.make
			interval := target.index - start_point.x.floor
			if trading_period_type.duration.day /= 0 then
				!!duration.make_definite (
					trading_period_type.duration.day * interval, 0, 0, 0)
			elseif trading_period_type.duration.hour /= 0 then
				!!duration.make_definite (0,
					trading_period_type.duration.hour * interval, 0, 0)
			else
				check
					minute: trading_period_type.duration.minute /= 0
				end
				!!duration.make_definite (0, 0,
					trading_period_type.duration.minute * interval, 0)
			end
			date := start_point.date_time + duration
--print ("index, sp.x, interval: "); print (index); print (", ")
--print (start_point.x); print (", "); print (interval); print ("%N")
			Result.set_x_y_date (target.index, y_at (target.index), date)
--print ("result (x, y, date): "); print (Result.x); print (", ")
--print (Result.y); print (", "); print (Result.date_time); print ("%N")
		end

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
			t := point_at_current_index
			output.extend (t)
		end

	operator_used: BOOLEAN is false

feature {NONE} -- Redefined

--	initialize is
--			-- Initialize all elements of the list.
--			-- NOTE: Currently, the size of the list will be equal to
--			-- end_point.x.rounded.  This may need to change to be made
--			-- configurable.
--		local
--			i, last_index: INTEGER
--			date: DATE_TIME
--			p: MARKET_POINT
--			neg_dur: DATE_TIME_DURATION
--		do
--			last_index := end_point.x.rounded -- This may change.
--			-- Important - the count attribute must be adjusted to the
--			-- "virtual" size of the array/list to fulfill the precondition
--			-- for force_i_th (valid_index):
--			count := last_index
--			force_i_th (end_point, end_point.x.rounded)
--			force_i_th (start_point, start_point.x.rounded)
--			-- Create/insert points with indexes start_point.x - 1 to 1.
--			from
--				i := start_point.x.rounded - 1
--				date := start_point.date_time
--				neg_dur := -trading_period_type.duration
--			until
--				i = 0
--			loop
--				date := date + neg_dur
--				!!p.make
--				p.set_x_y_date (i, y_at (i), date)
--				put_i_th (p, i)
--				i := i - 1
--			end
--			-- Create/insert points with indexes start_point.x + 1 to
--			-- last_index.
--			from
--				i := start_point.x.rounded + 1
--				date := start_point.date_time
--			until
--				i = last_index + 1
--			loop
--				date := date + trading_period_type.duration
--				-- Position at end_point.x.rounded has already been set, so
--				-- do not insert a new point at that position.
--				if i /= end_point.x.rounded then
--					!!p.make
--					p.set_x_y_date (i, y_at (i), date)
--					force_i_th (p, i)
--				end
--				i := i + 1
--			end
--			check
--				i_last_index_rel: i = last_index + 1 and i = count + 1
--			end
--		end

end -- class MARKET_FUNCTION_LINE
