note
	description: "N-based calculations that take an operand"
	detailed_description: "The operand is only executed on initialization %
		%and it's execute routine must not expect a valid argument."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class N_BASED_UNARY_OPERATOR inherit

	N_BASED_CALCULATION
		rename
			make as n_make
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [DOUBLE, DOUBLE]
		rename
			initialize as uo_initialize
		undefine
			arg_mandatory, execute
		end

creation

	make

feature -- Initialization

	make (op: like operand; i: like n)
		require
			op_not_void: op /= Void
			i_gt_0: i > 0
		do
			operand := op
			operand.initialize_from_parent(Current)
			-- operand must be set before calling n_make, which calls set_n.
			n_make (i)
		ensure
			set: operand = op and n = i
		end

feature {FACTORY} -- Initialization

	initialize (arg: ANY)
		local
			ns: N_RECORD_STRUCTURE
		do
			uo_initialize (arg)
			-- uo_initialize must be called before set_n, since set_n calls
			-- calculate, which requires the operand to be initialized to
			-- the new value.
			ns ?= arg
			if ns /= Void then
				set_n (ns.n)
			end
		end

feature {NONE} -- Implmentation

	calculate: DOUBLE
			-- Perform the calculation based on n.
		do
			operand.execute (Void)
			Result := operand.value
		end

end -- class N_BASED_UNARY_OPERATOR
