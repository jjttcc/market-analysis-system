indexing
	description:
		"A unary operator that uses its operand to process the current %
		%item of a linear structure of market tuples"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class UNARY_LINEAR_OPERATOR inherit

	LINEAR_COMMAND
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			operate as operate_unused, initialize as uo_initialize
		undefine
			execute
		redefine
			arg_mandatory
		end

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operand) is
		require
			not_void: tgt /= Void and op /= Void
		do
			target := tgt
			operand := op
		ensure
			set: target = tgt and operand = op
		end

	initialize (arg: LINEAR_ANALYZER) is
		do
			Precursor (arg)
			uo_initialize (arg)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is
		once
			Result := true
		end

end -- class UNARY_LINEAR_OPERATOR
