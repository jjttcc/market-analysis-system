indexing
	description: "Composite volume tuple factory that includes the sum of %
		%the open interest of all elements in the market tuple list";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMPOSITE_OI_TUPLE_FACTORY inherit

	COMPOSITE_VOLUME_TUPLE_FACTORY
		redefine
			product, do_auxiliary_work
		end

feature {NONE}

	do_auxiliary_work (tuples: LIST [MARKET_TUPLE]) is
			-- Set product's volume to sum of all volumes in `tuples'.
		local
			operator: OPEN_INTEREST
		do
			Precursor (tuples)
			if open_interest_adder = Void then
				create operator
				create open_interest_adder.make (tuples, operator, tuples.count)
			else
				open_interest_adder.set (tuples)
				open_interest_adder.set_n (tuples.count)
			end
			check
				open_interest_adder.n = tuples.count
			end
			tuples.start
			open_interest_adder.execute (Void)
			product.set_open_interest (open_interest_adder.value)
		ensure then
			-- product.open_interest = sum_of_open_interest_fields_in (tuples)
		end

feature

	product: COMPOSITE_OI_TUPLE

feature {NONE}

	open_interest_adder: LINEAR_SUM

end -- class COMPOSITE_OI_TUPLE_FACTORY
