indexing
	description:
		"A list of objects that conform to MARKET_TUPLE"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_LIST [G->MARKET_TUPLE] inherit

	ARRAYED_LIST [G]

creation

	make

feature -- Access

	index_at_date_time (d: DATE_TIME): INTEGER is
			-- Index of the element whose date/time matches `d' or of the
			-- first element whose date/time is later than `d' - 0 if no
			-- element's time is later than `d'.
			-- Time efficiency is O(log2 n)
		require
			not_void: d /= Void
			not_empty: not empty
		local
			top, bottom, i, comparison: INTEGER
		do
			-- Perform a binary search.
			from
				bottom := lower
				top := count
			invariant
				must_be_in: in_range_or_not_in_array (d, bottom, top)
			variant
				top_bottom_difference: top - bottom + 1
			until
				Result /= 0 or top < bottom
			loop
				i := (bottom + top) // 2
				check
					i_valid: i > 0 and bottom <= i and i <= top
				end
				comparison := d.three_way_comparison (i_th (i).date_time)
				inspect
					comparison
				when 0 then
					Result := i
				when 1 then
					bottom := i + 1
				when -1 then
					top := i - 1
				end
			end
			check
				top >= bottom =
					(Result > 0 and then d.is_equal (i_th (Result).date_time))
				Result = 0 implies top = bottom - 1 and
					((valid_index (top) implies i_th (top).date_time < d) and
					(valid_index (bottom) implies i_th (bottom).date_time > d))
			end
			if Result = 0 and valid_index (bottom) then
				-- bottom is now the index of the first element whose
				-- date/time is later than `d', unless there is no element
				-- whose date/time is later than `d'
				Result := bottom
			end
		ensure
			non_zero_implies_valid: Result > 0 implies valid_index (Result)
			non_zero_implies_result_ge_d:
				Result > 0 implies i_th (Result).date_time >= (d)
			previous_item_lt_d_if_valid:
				valid_index (Result - 1) implies
					i_th (Result - 1).date_time < d
			dates_match_if_has_d:
				has_date_time (d) implies i_th (Result).date_time.is_equal (d)
		end

	index_at_date (d: DATE): INTEGER is
			-- Index of the first element whose date matches or is
			-- later than `d' - 0 if no element's date is later than `d'
		require
			not_void: d /= Void
			not_empty: not empty
		local
			dt: DATE_TIME
		do
			!!dt.make_by_date (d)
			check
				dt.hour = 0 and dt.minute = 0 and dt.second = 0
			end
			Result := index_at_date_time (dt)
		end

feature -- Status report

	has_date_time (d: DATE_TIME): BOOLEAN is
			-- Does date/time `d' occur in the data set?
		require
			not_void: d /= Void
		local
			i: INTEGER
		do
			i := index_at_date_time (d)
			Result := i /= 0 and then i_th (i).date_time.is_equal (d)
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

feature {NONE}

	in_range_or_not_in_array (d: DATE_TIME; bottom, top: INTEGER): BOOLEAN is
			-- Does `d' match the date_time of a tuple within the (index)
			-- range bottom .. top or does `d' not occur in the array?
		local
			i: INTEGER
			in_array: BOOLEAN
		do
			from
				i := bottom
			until
				Result or i = top + 1
			loop
				if i_th(i).date_time.is_equal (d) then
					Result := true
				end
				i := i + 1
			end
			if not Result then
				-- Determine whether `d' occurs in the array.
				from
					i := lower
				until
					i = count + 1
				loop
					if i_th(i).date_time.is_equal (d) then
						in_array := true
					end
					i := i + 1
				end
				Result := not in_array
			end
		ensure
			-- Result = (has_date (d) implies
			-- 	(exists i such_that i >= bottom and i <= top it_holds
			-- 		i_th (i).date_time.is_equal (d)))
		end

invariant

	lower_is_one: lower = 1
	sorted_by_date_time: -- sorted_by_date_time
	--   (The above call is too inefficient to execute.)

end -- class MARKET_TUPLE_LIST
