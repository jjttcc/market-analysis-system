class SOMETHING_OR_OTHER inherit

	FACTORY
		rename
			execute as make_composite_data
		end

feature

	make_composite_data (start_date: DATE_TIME) is
			-- Make a composite list of MARKET_TUPLE
		local
			src_sublist: ARRAYED_LIST [BASIC_MARKET_TUPLE]
			--was: src_sublist: LINKED_LIST [BASIC_MARKET_TUPLE]
			current_date: DATE_TIME
		do
			from
				if product = Void then
					!!product.make (1) --!!!??
				else
					-- Remove any previously inserted items.
					product.wipe_out
				end
				!!src_sublist.make (0)
				source_list.start
				current_date := start_date
				check product.count = 0 end
			invariant
				product.count > 1 implies ((product.last.date_time -
					product.i_th (
					product.count - 1).date_time).duration.is_equal (duration))
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
					(src_sublist.last.date_time <
						current_date + duration)
					-- src_sublist is sorted by date_time
				until
					source_list.after or
						source_list.item.date_time >=
							current_date + duration
				loop
					src_sublist.extend (source_list.item)
					source_list.forth
				end
				tuple_maker.execute (src_sublist)
				tuple_maker.product.set_date_time (current_date)
				--!!!When implemented, use the flyweight date_time table.
				current_date := current_date + duration
				product.extend (tuple_maker.product)
			end
		ensure then
			product.count > 0 implies times_correct and
				product.first.date_time.is_equal (start_date)
		end

feature -- Utility

	times_correct: BOOLEAN is
			-- for_all p member_of product [2 .. product.count]
			--   it_holds p.date_time - previous (p).date_time equals duration
			-- for_all p member_of product it_holds
			--   p.last.date_time < p.date_time + duration
		require
			not product.empty
			-- product is sorted by date/time
		local
			previous: MARKET_TUPLE
		do
			Result := true
			from
				product.start
				previous := product.item
				product.forth
			until
				product.after or not Result
			loop
				Result := (product.item.date_time -
							previous.date_time).duration.is_equal (duration)
				previous := product.item
				product.forth
			end
			if Result then
				from
					product.start
				until
					product.after or not Result
				loop
					Result := product.item.last.date_time <
								product.item.date_time + duration
					product.forth
				end
			end
		end

feature -- Access

	product: ARRAYED_LIST [COMPOSITE_TUPLE]
			-- Resulting list of tuples

	source_list: LINEAR [BASIC_MARKET_TUPLE]
			-- tuples used to manufacture product

	tuple_maker: COMPOSITE_TUPLE_FACTORY
			-- factory used to create tuples

	duration: DATE_TIME_DURATION
			-- duration of the composite tuples to be created

feature

	set_source_list (l: LINEAR [BASIC_MARKET_TUPLE]) is
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

	set_duration (d: DATE_TIME_DURATION) is
		require
			d /= Void
		do
			duration := d
		ensure
			duration_set: duration = d and duration /= Void
		end

end -- SOMETHING_OR_OTHER
