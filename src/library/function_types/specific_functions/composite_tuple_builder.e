class
	SOMETHING_OR_OTHER

feature

-- !!!Need an object to manufacture tuple and an object to set values of
-- !!!product elements according to values of l's elements.

	make_composite_data (l: LINEAR [MARKET_TUPLE];
							time_period_count: INTEGER) is
			-- Make a composite list of MARKET_TUPLE
		require
			time_period_count > 1
		local
			current_tuple: MARKET_TUPLE
		do
			!!product.make (1) --!!!??
			from
				l.start
			invariant



			until
				l.after
			loop
				!!current_tuple.make
				product.extend (current_tuple)
				--set currtuple's date/time to l.item's date/time
				from
				invariant



				until
					current_tuple.date_time + duration >= l.item.date_time
				loop
					l.forth
				end
			end
		end

feature

	product: ARRAYED_LIST [MARKET_TUPLE]

end -- SOMETHING_OR_OTHER
