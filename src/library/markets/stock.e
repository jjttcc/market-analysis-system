indexing
	description: "An abstraction for a stock, such as IBM stock";
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK inherit

	TRADABLE [VOLUME_TUPLE]
		redefine
			symbol, make_ctf, short_description, finish_loading
		end

creation

	make

feature -- Initialization

	make (s: STRING; type: TIME_PERIOD_TYPE;
				stock_splits: DYNAMIC_CHAIN [STOCK_SPLIT]) is
		require
			not_void: s /= Void and type /= Void
			splits_sorted_by_date: stock_splits /= Void and
				not stock_splits.empty implies
					splits_sorted_by_date (stock_splits)
		do
			symbol := s
			tradable_initialize (type)
			splits := stock_splits
		ensure
			symbol_set: symbol = s
			period_type_set: trading_period_type = type
			target_period_type_set: target_period_type = trading_period_type
			splits_built: stock_splits /= Void implies splits /= Void
		end

feature -- Access

	splits: DYNAMIC_CHAIN [STOCK_SPLIT]
			-- List of all (recorded) stock splits for the stock

	symbol: STRING

	short_description: STRING is "Stock"

feature -- Basic operations

	finish_loading is
		do
			adjust_for_splits
		end

	splits_sorted_by_date (sp: like splits): BOOLEAN is
			-- Is `sp' sorted by date ascending?
		require
			not_void_or_empty: sp /= Void and not sp.empty
		local
			previous_date: DATE
		do
			Result := true
			from
				sp.start
				previous_date := sp.item.date
				sp.forth
			invariant
				previous_date = sp.i_th (sp.index - 1).date
			--     and
			-- (for_all i such_that 1 < i <= sp.index - 1 it_holds
			-- 	sp.i_th (i-1).date < sp.i_th (i).date)
			variant
				sp.count - sp.index + 1
			until
				not Result or sp.after
			loop
				if previous_date >= sp.item.date then
					Result := false
				else
					check
						prev_lt_current: previous_date < sp.item.date
					end
					previous_date := sp.item.date
					sp.forth
				end
			end
		ensure
			-- Result = (for_all i such_that 1 < i <= sp.count it_holds
			-- 	sp.i_th (i-1).date < sp.i_th (i).date)
		end

feature {NONE} -- Implementation

	adjust_for_splits is
			-- Adjust tuples for stock splits.
		local
			first_item_date: DATE
		do
			if not empty and splits /= Void and not splits.empty then
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

	do_split_adjustment is
		require
			lists_not_empty: not empty and splits /= Void and not splits.empty
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
				-- after implies that some data is missing - allowed for
				-- robustness:
				missing_data_condition:
					after implies last.date_time.date < splits.last.date
				for_current_item_to_end_there_are_no_more_splits:
					not after implies item.date_time.date >= splits.last.date
				split_ratio_equals_1: rabs (split_ratio - 1) < epsilon
			end
		end

	make_ctf: COMPOSITE_TUPLE_FACTORY is
		once
			!COMPOSITE_VOLUME_TUPLE_FACTORY!Result
		end

invariant

	splits_sorted_by_date:
		splits /= Void and not splits.empty implies
			splits_sorted_by_date (splits)

end -- class STOCK
