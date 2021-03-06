note
	description: "Composite tuple factory that includes the sum of the %
		%volume of all elements in the tradable tuple list";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMPOSITE_VOLUME_TUPLE_FACTORY inherit

	COMPOSITE_TUPLE_FACTORY
		redefine
			product, do_auxiliary_work
		end

feature {NONE}

	do_auxiliary_work (tuples: LIST [TRADABLE_TUPLE])
			-- Set product's volume to sum of all volumes in `tuples'.
		local
			operator: VOLUME
		do
			if volume_adder = Void then
				create operator
				create volume_adder.make (tuples, operator, tuples.count)
			else
				volume_adder.set (tuples)
				volume_adder.set_n (tuples.count)
			end
			check
				volume_adder.n = tuples.count
			end
			tuples.start
			volume_adder.execute (Void)
			product.set_volume (volume_adder.value)
		ensure then
			-- product.volume = sum_of_volume_fields_in (tuples)
		end

feature

	product: COMPOSITE_VOLUME_TUPLE

feature {NONE}

	volume_adder: LINEAR_SUM

end -- class COMPOSITE_VOLUME_TUPLE_FACTORY
