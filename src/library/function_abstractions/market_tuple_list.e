indexing
	description:
		"A list of objects that conform to MARKET_TUPLE that supports the %
		%concept of a type of trading period, such as daily, weekly, etc.";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_LIST [G->MARKET_TUPLE] inherit

	ARRAYED_LIST [G]

creation

	make

feature -- Access

	index_at_date (d: DATE_TIME): INTEGER is
			-- Index of the element whose date/time matches `d'
		do
			-- Perform a binary search.
		ensure
			zero_if_not_in_list: not has_date (d) implies (Result = 0)
			valid_if_in_list: has_date (d) implies valid_index (Result) and
								i_th (Result).date_time.is_equal (d)
		end

	slope_at (i: INTEGER): REAL is
			-- Approximation of lope or rate of change at the point
			-- (list element) specified by `i'
		require
			valid_index (i)
		local
			line1, line2: MARKET_LINE
			p1, p2, p3: expanded MARKET_POINT
			mt: MARKET_TUPLE
		do
			--!!Need to deal with boundaries.
			mt := i_th (i - 1)
			p1.set_x_y_date (i - 1, mt.value, mt.date_time)
			mt := i_th (i)
			p2.set_x_y_date (i, mt.value, mt.date_time)
			mt := i_th (i + 1)
			p3.set_x_y_date (i + 1, mt.value, mt.date_time)
			!!line1.make (p1, p2)
			!!line2.make (p2, p3)
			Result := (line1.slope + line2.slope) / 2
		end

feature -- Status report

	has_date (d: DATE_TIME): BOOLEAN is
			-- Does date/time `d' occur in the data set?
		do
			Result := index_at_date (d) /= 0
		end

	sorted_by_date_time: BOOLEAN is
			-- Is Current sorted by date and time?
		do
			from
				Result := true
				start
				if not after then
					forth
				end
				check index = 2 or after end
			until
				after or not Result
			loop
				if
					not (i_th (index).date_time > i_th (index - 1).date_time)
				then
					Result := false
				end
			end
		end

invariant

	sorted_by_date_time: -- sorted_by_date_time
	--   (The above call is too inefficient to execute.)

end -- class MARKET_TUPLE_LIST
