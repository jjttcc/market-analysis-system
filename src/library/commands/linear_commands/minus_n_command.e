indexing
	description:
		"An n-record command that operates on a target list by setting %
		%the target's cursor n positions to the left, operating on the %
		%target based on this cursor position, and then restoring the %
		%target to the original cursor position.  The operation performed %
		%is determined by the run-time type of its operand."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MINUS_N_COMMAND inherit

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		export {NONE}
			nrc_make_unused
		redefine
			initialize
		select
			initialize
		end

	LINEAR_OFFSET_COMMAND
		undefine
			initialize
		end

	UNARY_OPERATOR [REAL]
		rename
			initialize as uo_initialize
		end

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operand; i: like n) is
		require
			args_not_void: tgt /= Void and op /= Void
			i_gt_0: i > 0
		do
			operand := op
			target := tgt
			n := i
		ensure then
			op_n_set: operand = op and n = i
			target_set: target = tgt
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			Precursor (arg)
			uo_initialize (arg)
		end

feature -- Access

	offset: INTEGER is
		do
			Result := -n
		ensure then
			Result = -n
		end

feature {NONE} -- Implementation

	operate (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

end -- class MINUS_N_COMMAND
