indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class STOCK inherit

	TRADABLE [VOLUME_TUPLE]

creation

	make

feature -- Access

	splits: LINKED_LIST [STOCK_SPLIT]

feature -- Basic operations

	adjust_for_splits is
			-- Adjust tuples for stock splits.
		do
			if not empty and not splits.empty then
				splits.finish
				from 
					finish
				until
					before or item.date_time.date.is_equal (splits.item.date)
				loop
					back
				end
				if not before then
					do_split_adjustment
				end
			end
		end

feature {NONE} -- Implementation

	do_split_adjustment is
		require
			lists_not_empty: not empty and not splits.empty
			not_before_islast: not before and splits.islast
		local
			split_ratio: REAL
		do
			split_ratio := splits.item.value
			from
				splits.back
			until
				isfirst
			loop
				back
				item.adjust_for_split (split_ratio)
				if
					not splits.before and
					splits.item.date.is_equal (item.date_time.date)
				then
					split_ratio := split_ratio * splits.item.value
					splits.back
				end
			end
		end

end -- class STOCK
