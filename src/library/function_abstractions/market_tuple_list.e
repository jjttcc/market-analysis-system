note
	description:
		"A list of objects that conform to MARKET_TUPLE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MARKET_TUPLE_LIST [G->MARKET_TUPLE] inherit

	ARRAYED_LIST [G]
		redefine
			is_equal, out
		end

creation

	make

feature -- Access

	index_at_date_time (d: DATE_TIME; search_spec: INTEGER): INTEGER
			-- Index of the element whose date_time matches `d'
			-- If no element's date_time matches `d':
			--   search_spec < 0: Index of latest element whose date_time < `d'
			--   search_spec > 0: Index of earliest element whose
			--                    date_time > `d'
			--   search_spec = 0: 0
			-- If there is no element whose date_time is earlier than `d' for
			-- search_spec < 0 or no element whose date_time is later than `d'
			-- for search_spec > 0, result is 0.
			-- Time efficiency is O(log2 n)
		require
			not_void: d /= Void
			not_empty: not is_empty
		local
			top, bottom, i: INTEGER
		do
			-- Perform a binary search.
			from
				bottom := lower
				top := count
			invariant
				must_be_in: in_range_or_not_in_array (d, bottom, top)
			variant
				top_bottom_interval_or_result_not_0:
					top - bottom + 1 + is_idx_dt_result_0 (Result)
			until
				Result /= 0 or top < bottom
			loop
				i := (bottom + top) // 2
				check
					i_valid: i > 0 and bottom <= i and i <= top
				end
				inspect
					d.three_way_comparison (i_th (i).date_time)
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
			if Result = 0 and search_spec /= 0 then
				if search_spec < 0 and valid_index (top) then
					-- top is now the index of the first element whose
					-- date/time is earlier than `d', unless there is no
					-- element whose date/time is earlier than `d'
					Result := top
				elseif search_spec > 0 and valid_index (bottom) then
					-- bottom is now the index of the first element whose
					-- date/time is later than `d', unless there is no element
					-- whose date/time is later than `d'
					Result := bottom
				end
			end
			debug ("data_update_bug")
				print ("index_at_date_time - count, top, Result: " +
					count.out + ", " + top.out + ", " + Result.out + "%N")
			end
		ensure
			non_zero_implies_valid: Result > 0 implies valid_index (Result)
			non_zero_spec_negative_implies_result_le_d:
				Result > 0 and search_spec < 0 implies
					i_th (Result).date_time <= (d)
			non_zero_spec_positive_implies_result_ge_d:
				Result > 0 and search_spec > 0 implies
					i_th (Result).date_time >= (d)
			spec_negative_next_item_gt_d_if_valid:
				search_spec < 0 and valid_index (Result + 1) implies
					i_th (Result + 1).date_time > d
			spec_positive_previous_item_lt_d_if_valid:
				search_spec > 0 and valid_index (Result - 1) implies
					i_th (Result - 1).date_time < d
			dates_match_if_has_d:
				has_date_time (d) implies i_th (Result).date_time.is_equal (d)
		end

	index_at_date (d: DATE; search_spec: INTEGER): INTEGER
			-- Index of the element whose date matches `d'
			-- If no element's date matches `d':
			--   search_spec < 0: Index of latest element whose date < `d'
			--   search_spec > 0: Index of earliest element whose date > `d'
			--   search_spec = 0: 0
			-- If there is no element whose date is earlier than `d' for
			-- search_spec < 0 or no element whose date is later than `d'
			-- for search_spec > 0, result is 0.
			-- Time efficiency is O(log2 n)
		require
			not_void: d /= Void
			not_empty: not is_empty
		local
			dt: DATE_TIME
		do
			create dt.make_by_date (d)
			check
				dt.hour = 0 and dt.minute = 0 and dt.second = 0
			end
			Result := index_at_date_time (dt, search_spec)
		ensure
			non_zero_implies_valid: Result > 0 implies valid_index (Result)
			non_zero_spec_negative_implies_result_le_d:
				Result > 0 and search_spec < 0 implies
					i_th (Result).date_time.date <= (d)
			non_zero_spec_positive_implies_result_ge_d:
				Result > 0 and search_spec > 0 implies
					i_th (Result).date_time.date >= (d)
		end

	out: STRING
		local
			l: LINEAR [MARKET_TUPLE]
verbose_version: BOOLEAN
		do
			if verbose_version then
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			l := linear_representation
			create Result.make (0)
			from
				l.start
			until
				l.exhausted
			loop
				Result.append ("date/time: " + l.item.date_time.out +
					", value: " + l.item.value.out + "%N")
				l.forth
			end
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			else
				Result := Precursor
			end
		end

feature -- Status report

	has_date_time (d: DATE_TIME): BOOLEAN
			-- Does date/time `d' occur in the data set?
		require
			not_void: d /= Void
		local
			i: INTEGER
		do
			i := index_at_date_time (d, 0)
			Result := i /= 0
		end

	has_date (d: DATE): BOOLEAN
			-- Does date `d' occur in the data set?
		require
			not_void: d /= Void
		local
			i: INTEGER
		do
			i := index_at_date (d, 0)
			Result := i /= 0
		end

	sorted_by_date_time: BOOLEAN
			-- Is Current sorted by date and time?
		do
			from
				Result := True
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
					Result := False
				end
			end
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
		local
			this_type: like Current
		do
			this_type ?= other
			if this_type /= Void then
				Result := Precursor (other)
			end
		end

feature {NONE}

	in_range_or_not_in_array (d: DATE_TIME; bottom, top: INTEGER): BOOLEAN
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
					Result := True
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
						in_array := True
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

	is_idx_dt_result_0 (r: INTEGER): INTEGER
			-- Is Result from index_at_date_time 0 (for loop variant)?
			-- 1 if r is 0, otherwise 0
		do
			-- Indulgent? Sure, but it's sometimes fun to try for perfection,
			-- even though you will never completely succeed. :-)
			if r = 0 then
				Result := 1
			end
		end

invariant

	lower_is_one: lower = 1
	sorted_by_date_time: -- sorted_by_date_time
	--   (The above call is too inefficient to execute.)

end -- class MARKET_TUPLE_LIST
