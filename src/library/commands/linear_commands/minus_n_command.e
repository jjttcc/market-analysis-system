indexing
	description: "N-record commands that operate on a target list by setting %
		%the target's cursor n positions to the left, operating on the %
		%target based on this cursor position, and then restoring the %
		%target to the original cursor position.  The operation performed %
		%is determined by the run-time type of its operand."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
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
			set (tgt)
			n := i
		ensure then
			op_n_set: operand = op and n = i
			target_set: target = tgt
			adjustment_0: n_adjustment = 0
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

	external_offset: INTEGER is 0

	n_adjustment: INTEGER
			-- Value that will be added to `n' when
			-- calculating `offset'

feature -- Status report

	arg_mandatory: BOOLEAN is False

feature -- Status report

	set_n_adjustment (arg: INTEGER) is
			-- Set n_adjustment to `arg'.
		do
			n_adjustment := arg
		ensure
			n_adjustment_set: n_adjustment = arg
		end

feature {NONE} -- Implementation

	offset: INTEGER is
		do
			Result := - (n + n_adjustment)
		end

	operate (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

invariant

	offset_definition: offset = - (n + n_adjustment)

end -- class MINUS_N_COMMAND
