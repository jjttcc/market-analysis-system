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

feature {NONE} -- Initialization

	make (p1, p2: MARKET_POINT; period_type: TIME_PERIOD_TYPE) is
		require
			not_void: p1 /= Void and p2 /= Void
			p1_left_of_p2: p1.x < p2.x
		do
			ml_make (p1, p2)
			sf_make (period_type)
			initialize
		ensure
			set: start_point = p1 and end_point = p2
		end

	initialize is
			-- Initialize all elements of the list.
			-- NOTE: Currently, the size of the list will be equal to
			-- end_point.x.rounded.  This may need to change to be made
			-- configurable.
		local
			i, last_index: INTEGER
			date: DATE_TIME
			p: MARKET_POINT
			neg_dur: DATE_TIME_DURATION
		do
			last_index := end_point.x.rounded -- This may change.
			force_i_th (end_point, end_point.x.rounded)
			put_i_th (start_point, start_point.x.rounded)
			-- Create/insert points with indexes start_point.x - 1 to 1.
			from
				i := start_point.x.rounded - 1
				date := start_point.date_time
				neg_dur := -trading_period_type.duration
			until
				i = 0
			loop
				date := date + neg_dur
				!!p.make
				p.set_x_y_date (i, y_at (i), date)
				put_i_th (p, i)
				i := i - 1
			end
			-- Create/insert points with indexes start_point.x + 1 to
			-- last_index.
			from
				i := start_point.x.rounded + 1
				date := start_point.date_time
			until
				i = last_index + 1
			loop
				date := date + trading_period_type.duration
				-- Position at end_point.x.rounded has already been set, so
				-- do not insert a new point at that position.
				if i /= end_point.x.rounded then
					!!p.make
					p.set_x_y_date (i, y_at (i), date)
					force_i_th (p, i)
				end
				i := i + 1
			end
			check
				i_last_index_rel: i = last_index + 1 and i = count + 1
			end
		end

end -- class MARKET_FUNCTION_LINE
