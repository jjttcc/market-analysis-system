indexing
	description:
		"Abstraction for objects that create a market tuple based on %
		%the values in a list of market tuples";
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

creation

	make

feature

	make is
		do
			!!high_finder
			!!low_finder
		end

feature

	execute (tuplelist: LIST [BASIC_MARKET_TUPLE]) is
		local
			h, l, o, c: REAL
		do
			product := make_tuple
			check
				tuplelist.first.date_time /= Void and
				tuplelist.last.date_time /= Void
			end
			product.set_first (tuplelist.first)
			product.set_last (tuplelist.last)
			do_main_work (tuplelist)
			do_auxiliary_work (tuplelist)
		ensure then
			-- product.high = highest high in tuplelist
			-- product.low = lowest low in tuplelist
			-- product.open = open from first element of tuplelist
			-- product.close = close from last element of tuplelist
		end

feature {NONE}

	make_tuple: COMPOSITE_TUPLE is
			-- Descendants can redefine to make objects that conform
			-- to COMPOSITE_TUPLE.
		do
			!!Result.make
		end

	do_main_work (tuples: LIST [BASIC_MARKET_TUPLE]) is
		local
			h, l, o, c: REAL
		do
			o := tuples.first.open.value
			c := tuples.last.close.value
			high_finder.set_target (tuples)
			low_finder.set_target (tuples)
			-- Set to process all elements:
			high_finder.set_n (tuples.count)
			low_finder.set_n (tuples.count)
			-- Move cursor to last element (n elements will be processed,
			-- beginning with the last element, going backwards):
			tuples.start
			tuples.move (tuples.count - 1)
			check tuples.index = tuples.count end
			high_finder.execute (Void)
			low_finder.execute (Void)
			h := high_finder.value
			l := low_finder.value
			product.set (o, h, l, c)
			check
				product.open.value = tuples.first.open.value
				product.close.value = tuples.last.close.value
			end
		ensure then
			-- product.high = highest high in tuplelist
			-- product.low = lowest low in tuplelist
			-- product.open = open from first element of tuplelist
			-- product.close = close from last element of tuplelist
		end

	do_auxiliary_work (tuplelist: LIST [MARKET_TUPLE]) is
			-- Hook method to be redefined by descendants
		require
			product_not_void: product /= Void
		do
		ensure
			same_reference: product = old product
		end

feature

	product: COMPOSITE_TUPLE

feature {NONE}

	high_finder: HIGHEST_HIGH

	low_finder: LOWEST_LOW

end -- class COMPOSITE_TUPLE_FACTORY
