indexing
	description:
		"N-based calculation that takes an operand"
	detailed_description: "The operand is only executed on initialization %
		%and it's execute routine must not expect a valid argument."
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class N_BASED_UNARY_OPERATOR inherit

	N_BASED_CALCULATION
		rename
			make as n_make
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			initialize as uo_initialize
		undefine
			arg_mandatory, execute
		end

creation

	make

feature -- Initialization

	make (op: like operand; i: like n) is
		require
			op_not_void: op /= Void
			i_gt_0: i > 0
		do
			operand := op
			-- operand must be set before calling n_make, which calls set_n.
			n_make (i)
		ensure
			set: operand = op and n = i
		end

feature {FACTORY} -- Initialization

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			uo_initialize (arg)
			-- uo_initialize must be called before set_n, since set_n calls
			-- calculate, which requires the operand to be initialized to
			-- the new value.
			set_n (arg.n)
		ensure then
			new_n: n = arg.n
		end

feature {NONE} -- Implmentation

	calculate: REAL is
			-- Perform the calculation based on n.
		do
			operand.execute (Void)
			Result := operand.value
		end

end -- class N_BASED_UNARY_OPERATOR
