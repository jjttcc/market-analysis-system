indexing
	description: "Composite tuple factory that includes the sum of the %
	%volume of all elements in the market tuple list";
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_VOLUME_TUPLE_FACTORY inherit

	COMPOSITE_TUPLE_FACTORY
		redefine
			product, do_auxiliary_work, make
		end

creation

	make

feature

	make is
		local
			operator: VOLUME_COMMAND
		do
			Precursor
			!!operator
			!!volume_adder
			check operator.execute_precondition end
			volume_adder.set_operator (operator)
		end

feature {NONE}

	do_auxiliary_work (tuples: LIST [MARKET_TUPLE]) is
			-- Set product's volume to sum of all volumes in tuplelist.
		local
		do
			volume_adder.set_target (tuples)
			volume_adder.set_n (tuples.count)
			tuples.start
			check
				volume_adder.operator_set
				volume_adder.target_set
				volume_adder.n_set
			end
			volume_adder.execute (Void)
			product.set_volume (volume_adder.value.rounded)
		ensure then
			-- product.volume = sum_of_volume_fields_in (tuples)
		end

feature

	product: COMPOSITE_VOLUME_TUPLE

feature {NONE}

	volume_adder: LINEAR_SUM

end -- class COMPOSITE_VOLUME_TUPLE_FACTORY
