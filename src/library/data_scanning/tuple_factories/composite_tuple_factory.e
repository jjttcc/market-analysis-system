note
	description:
		"Abstraction for objects that create a market tuple based on %
		%the values in a list of market tuples";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	set_tuplelist (arg: LIST [BASIC_MARKET_TUPLE])
			-- Set tuplelist to `arg'.
		require
			arg /= Void
		do
			tuplelist := arg
		ensure
			tuplelist_set: tuplelist = arg and tuplelist /= Void
		end

feature -- Basic operations

	execute
		do
			check
				tuplelist_not_void: tuplelist /= Void
				tuplelist_not_empty: not tuplelist.is_empty
				tuplelist_dates_not_void:
					tuplelist.first.date_time /= Void and
					tuplelist.last.date_time /= Void
			end
			create product.make
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

	do_main_work (tuples: LIST [BASIC_MARKET_TUPLE])
			-- Set `product's open, high, low, and close values from the
			-- open, highest high, lowest low, and close values, respectively,
			-- from tuples.
		local
			h, l, o, c: DOUBLE
			high: HIGH_PRICE
			low: LOW_PRICE
		do
			o := tuples.first.open.value
			c := tuples.last.close.value
			if high_finder = Void then
				create high; create low
				check low_finder = Void end
				create high_finder.make (tuples, high, tuples.count)
				create low_finder.make (tuples, low, tuples.count)
			else
				check low_finder /= Void end
				high_finder.set (tuples)
				low_finder.set (tuples)
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

	do_auxiliary_work (tuples: LIST [MARKET_TUPLE])
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
