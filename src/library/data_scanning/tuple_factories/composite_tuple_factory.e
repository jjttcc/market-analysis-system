indexing
	description:
		"Abstraction for objects that create a market tuple based on %
		%the values in a list of market tuples";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_TUPLE_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

	COMMAND_EDITOR -- To allow setting parameters of high_finder, ...
		export
			{NONE} all
		end

feature -- Access

	product: COMPOSITE_TUPLE

	tuplelist: LIST [BASIC_MARKET_TUPLE]
			-- List of tuples from which to create a composite tuple

feature -- Status setting

	set_tuplelist (arg: LIST [BASIC_MARKET_TUPLE]) is
			-- Set tuplelist to `arg'.
		require
			arg /= Void
		do
			tuplelist := arg
		ensure
			tuplelist_set: tuplelist = arg and tuplelist /= Void
		end

feature -- Basic operations

	execute is
		local
			h, l, o, c: REAL
		do
			check
				tuplelist_not_void: tuplelist /= Void
				tuplelist_not_empty: not tuplelist.empty
				tuplelist_dates_not_void:
					tuplelist.first.date_time /= Void and
					tuplelist.last.date_time /= Void
			end
			!!product.make
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

	do_main_work (tuples: LIST [BASIC_MARKET_TUPLE]) is
		local
			h, l, o, c: REAL
			high: expanded HIGH_PRICE
			low: expanded LOW_PRICE
		do
			o := tuples.first.open.value
			c := tuples.last.close.value
			if high_finder = Void then
				check low_finder = Void end
				!!high_finder.make (tuples, high, tuples.count)
				!!low_finder.make (tuples, low, tuples.count)
			else
				check low_finder /= Void end
				high_finder.set_target (tuples)
				low_finder.set_target (tuples)
				-- Set to process all elements:
				high_finder.set_n (tuples.count)
				low_finder.set_n (tuples.count)
			end
			check
				high_finder.n = tuples.count
				low_finder.n = tuples.count
			end
			tuples.start
			-- Move cursor to last element (n elements will be processed,
			-- beginning with the last element, going backwards):
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
			-- product.high = highest high in tuples
			-- product.low = lowest low in tuples
			-- product.open = open from first element of tuples
			-- product.close = close from last element of tuples
		end

	do_auxiliary_work (tuples: LIST [MARKET_TUPLE]) is
			-- Hook method to be redefined by descendants
		require
			product_not_void: product /= Void
		do
		ensure
			same_reference: product = old product
		end

feature {NONE}

	high_finder: HIGHEST_VALUE

	low_finder: LOWEST_VALUE

end -- class COMPOSITE_TUPLE_FACTORY
