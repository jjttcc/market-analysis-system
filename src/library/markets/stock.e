indexing
	description: "An abstraction for a stock, such as IBM stock";
	date: "$Date$";
	revision: "$Revision$"

class STOCK inherit

	TRADABLE [VOLUME_TUPLE]
		rename
			make as arrayed_list_make
		redefine
			symbol
		end

creation

	make

feature -- Initialization

	make (s: STRING) is
		do
			symbol := s
			arrayed_list_make (300)
		ensure
			symbol_set: symbol = s
		end

feature -- Access

	splits: LINKED_LIST [STOCK_SPLIT]
			-- List of all (recorded) stock splits for the stock

	symbol: STRING

feature -- Element change

	add_split (s: STOCK_SPLIT) is
			-- Add `s' to `splits' such that splits remains sorted by date.
		require
			not_void: s /= Void
			not_in_splits: not splits.has (s)
		do
			if splits = Void then
				!!splits.make
				splits.compare_objects
			end
			from
				splits.start
			until
				splits.after or s.date < splits.item.date
			loop
				splits.forth
			end
			splits.put_left (s)
		ensure
			added: splits.has (s) and splits.count = old splits.count + 1
		end

feature -- Basic operations

	adjust_for_splits is
			-- Adjust tuples for stock splits.
		local
			first_item_date: DATE
		do
			if not empty and not splits.empty then
				-- Since the date of some or all of the elements of splits may
				-- precede the date of the first element, move splits' cursor
				-- to the first element whose date > first.date_time.date.
				-- (Not >= because a split that becomes effective on a date,
				-- d, means that the price has already been adjusted for d.)
				from
					splits.start
					first_item_date := first.date_time.date
				until
					splits.after or splits.item.date > first_item_date
				loop
					splits.forth
				end
				check
					 date_gt: splits.after or splits.item.date >
								first.date_time.date
				end
				if not splits.after then
					do_split_adjustment
				end
			end
		end

feature {NONE} -- Implementation

	do_split_adjustment is
		require
			lists_not_empty: not empty and not splits.empty
			not_splits_off: not splits.off
			splt_date_gt_first: splits.item.date > first.date_time.date
			prev_splt_date_le_first: not splits.isfirst implies
				splits.i_th (splits.index - 1).date <= first.date_time.date
		local
			split_ratio: REAL
			saved_cursor: CURSOR
		do
			saved_cursor := splits.cursor
			from
				split_ratio := 1
			until
				splits.after
			loop
				split_ratio := split_ratio * splits.item.value
				splits.forth
			end
			splits.go_to (saved_cursor)
			from
				start
			invariant
				-- for_all i such_that 1 <= i < index it_holds
				--   adjusted_for_split (i_th (i), splits)
				--     Where adjusted_for_split (item, splist) means
				--       item has been adjusted for all splits in splist
				--       whose dates apply to (are greater than)
				--       item.date_time.date
			variant
				splits.count + 1 - splits.index
			until
				splits.after or after
			loop
				item.adjust_for_split (split_ratio)
				forth
				if
					not after and splits.item.date <= item.date_time.date
				then
					split_ratio := split_ratio / splits.item.value
					splits.forth
				end
			end
			check
				missing_data_condition:
					after implies last.date_time.date < splits.last.date
				-- after implies that some data is missing - allowed for
				-- robustness.
				for_current_item_to_end_there_are_no_more_splits:
					not after implies item.date_time.date >= splits.last.date
				split_ratio_equals_1: rabs (split_ratio - 1) < epsilon
			end
		end

	splits_sorted_by_date: BOOLEAN is
			-- Is attribute `splits' sorted by date ascending?
		local
			previous_date: DATE
		do
			Result := true
			from
				splits.start
				previous_date := splits.item.date
				splits.forth
			invariant
				previous_date = splits.i_th (splits.index - 1).date
			--     and
			-- (for_all i such_that 1 < i <= splits.index - 1 it_holds
			-- 	splits.i_th (i-1).date < splits.i_th (i).date)
			variant
				splits.count - splits.index + 1
			until
				not Result or splits.after
			loop
				if previous_date >= splits.item.date then
					Result := false
				else
					check
						prev_lt_current: previous_date < splits.item.date
					end
					previous_date := splits.item.date
					splits.forth
				end
			end
		ensure
			-- Result = (for_all i such_that 1 < i <= splits.count it_holds
			-- 	splits.i_th (i-1).date < splits.i_th (i).date)
		end

invariant

	splits_sorted_by_date: splits /= Void implies splits_sorted_by_date

end -- class STOCK
