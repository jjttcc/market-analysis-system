class SOMETHING_OR_OTHER inherit

	FACTORY
		rename
			execute as make_composite_data
		end

feature

-- !!!Need an object to manufacture tuple and an object to set values of
-- !!!product elements according to values of l's elements.

	make_composite_data (duration: DATE_TIME_DURATION) is
			-- Make a composite list of MARKET_TUPLE
			-- !!!Would duration be better as a settable attribute?
		local
			src_sublist: ARRAYED_LIST [MARKET_TUPLE]
		do
			from
				if product = Void then
					!!product.make (1) --!!!??
				else
					-- Remove any previously inserted items.
					product.wipe_out
				end
				!!src_sublist.make (100) -- !!!Size?
				source_list.start
				check product.count = 0 end
			invariant
				-- times_correct (
				-- 	product [1..product.count],
				-- 	source_list [1..source_list.index-1], duration)
			until
				source_list.after
			loop
				from
					-- Remove all previously inserted items.
					src_sublist.wipe_out
					check not source_list.after end
					src_sublist.extend (source_list.item)
					source_list.forth
				invariant
					((src_sublist.last.date_time <
						src_sublist.first.date_time + duration) and
					(src_sublist.last.date_time >=
						src_sublist.first.date_time))
				until
					source_list.after or
						source_list.item.date_time >=
							src_sublist.first.date_time + duration
				loop
					src_sublist.extend (source_list.item)
					source_list.forth
				end
				tuple_maker.execute (src_sublist)
				product.extend (tuple_maker.product)
				-- Set newly inserted tuple's date to the date of
				-- the first.
				product.last.set_date_time (src_sublist.first.date_time)
			end
		ensure then
			times_correct (product, source_list, duration)
		end

feature -- Utility

	times_correct (mainl, subl: LINEAR [MARKET_TUPLE];
					duration: DATE_TIME_DURATION): BOOLEAN is
			-- For each element of mainl, does its date equal the date
			-- of an element of subl and are there no elements of subl
			-- that are not included within the time span (specified by
			-- `duration') of an element of mainl?
		require
			-- mainl and subl are sorted by date/time
		do
			from
				Result := true
				mainl.start
				subl.start
			until
				mainl.after or not Result
			loop
				if
					not subl.after and then
						mainl.item.date_time.is_equal (subl.item.date_time)
				then
					from
						subl.forth
					until
						subl.after or else subl.item.date_time >=
											mainl.item.date_time + duration
					loop
						subl.forth
					end
					mainl.forth
				else
					check
						not mainl.after -- ensured by until predicate
						-- subl ended before mainl or mainl's and subl's
						-- current item dates are not equal:
						subl.after or not mainl.item.date_time.is_equal (
														subl.item.date_time)
					end
					Result := false
				end -- if
			end -- loop
			Result := Result and subl.after
		end

feature

	product: ARRAYED_LIST [BASIC_MARKET_TUPLE]

	source_list: LINEAR [MARKET_TUPLE]

	tuple_maker: COMPOSITE_TUPLE_FACTORY

feature

	set_source_list (l: LINEAR [MARKET_TUPLE]) is
			-- Set source_list to `l'.
		require
			not_void: l /= Void
		do
			source_list := l
		ensure
			set: source_list = l and l /= Void
		end

	set_tuple_maker (f: COMPOSITE_TUPLE_FACTORY) is
			-- Set tuple_maker to `f'.
		require
			not_void: f /= Void
		do
			tuple_maker := f
		ensure
			set: tuple_maker = f and f /= Void
		end

end -- SOMETHING_OR_OTHER
