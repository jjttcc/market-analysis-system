indexing
	description:
		"An n-record command that operates on a target list by setting %
		%the target's cursor n positions to the left, operating on the %
		%target based on this cursor position, and then restoring the %
		%target to the original cursor position.  The operation performed %
		%is determined by the run-time type of its operand."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MINUS_N_COMMAND inherit

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		export {NONE}
			nrc_make_unused
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	LINEAR_OFFSET_COMMAND
		rename
			initialize as loc_initialize
		export {NONE}
			loc_initialize
		undefine
			children
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			initialize as uo_initialize, operate as operate_unused
		export {NONE}
			uo_initialize, operate_unused
		undefine
			execute
		redefine
			arg_mandatory
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
		local
			l: LINEAR_ANALYZER
		do
			{N_RECORD_COMMAND} Precursor (arg)
			uo_initialize (arg)
			l ?= arg
			check
				arg_conforms_to_linear_analyzer: l /= Void
			end
			loc_initialize (l)
		end

feature -- Access

	offset: INTEGER is
		do
			Result := -n
		ensure then
			Result = -n
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

feature {NONE} -- Implementation

	operate (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

end -- class MINUS_N_COMMAND
