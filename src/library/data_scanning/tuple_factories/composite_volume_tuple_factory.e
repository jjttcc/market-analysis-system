indexing
	description: "Composite tuple factory that includes the average of the %
	%volume of all elements in the market tuple list";
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_VOLUME_TUPLE_FACTORY inherit

	COMPOSITE_TUPLE_FACTORY
		redefine
			product, do_auxiliary_work, make, make_tuple
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
			volume_adder.set_operator (operator)
		end

feature {NONE}

	make_tuple: VOLUME_TUPLE is
		do
			!!Result.make
		end

	do_auxiliary_work (tuplelist: ARRAYED_LIST [MARKET_TUPLE]) is
		local
			tuples: ARRAYED_LIST [BASIC_MARKET_TUPLE]
		do
			tuples ?= tuplelist
			check tuples /= Void end
			volume_adder.set_input (tuples)
			volume_adder.set_n (tuples.count)
			tuples.start
			check
				volume_adder.operator_set
				volume_adder.input_set
				volume_adder.n_set
			end
			volume_adder.execute (Void)
			product.set_volume ((volume_adder.value / tuples.count).rounded)
		end

feature

	product: VOLUME_TUPLE

feature {NONE}

	volume_adder: LINEAR_SUM

end -- class COMPOSITE_VOLUME_TUPLE_FACTORY
