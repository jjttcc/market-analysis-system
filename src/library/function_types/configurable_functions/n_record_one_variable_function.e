indexing
	description:
		"A market function that provides a concept of an n-length %
		%sub-list of the main input list."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_ONE_VARIABLE_FUNCTION inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		redefine
			do_process, target
		end

	N_RECORD_STRUCTURE
		redefine
			set_n
		end

creation {FACTORY}

	make

feature {NONE}

	make (in: like input; op: like operator; i: INTEGER) is
		require
			in_not_void: in /= Void
			op_not_void_if_used: operator_used implies op /= Void
			i_gt_0: i > 0
		do
			ovf_make (in, op)
			set_n (i)
		ensure
			set: input = in and operator = op and n = i
			target_set: target = in.output
		end

feature {NONE} -- Basic operations

	do_process is
			-- Execute the function.
		do
			target.go_i_th (n)
			continue_until
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY}

	set_n (value: INTEGER) is
		do
			Precursor (value)
			if operator /= Void then
				operator.initialize (Current)
			end
		end

end -- class N_RECORD_ONE_VARIABLE_FUNCTION
