indexing
	description: "Sum of n sequential elements";
	restrictions: "execute expects target.count >= n."
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LINEAR_SUM inherit

	N_RECORD_LINEAR_COMMAND
		rename
			index_offset as internal_index, make as nrlc_make_unused
		redefine
			execute, target_cursor_not_affected, exhausted, action,
			forth, invariant_value, start, initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			initialize as uo_initialize
		export {FACTORY}
			set_operand
		undefine
			arg_mandatory, execute
		end

creation

	make

feature {FACTORY} -- Initialization

	make (t: like target; op: like operand; i: like n) is
		require
			args_not_void: t /= Void and op /= Void
			i_gt_0: i > 0
		do
			set_target (t)
			set_operand (op)
			set_n (i)
		ensure
			op_n_set: operand = op and n = i
			target_set: target = t
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			Precursor (arg)
			uo_initialize (arg)
		end

feature -- Basic operations

	execute (arg: ANY) is
			-- Operate on the next n elements of the input, beginning
			-- at the current cursor position.
		do
			check target.count >= n end
			internal_index := 0
			value := 0
			until_continue
		ensure then
			new_index: target.index = old target.index + n
			-- value = sum (target[old target.index .. old target.index+n-1])
			int_index_eq_n: internal_index = n
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is false

feature {NONE}

	invariant_value: BOOLEAN is
		do
			Result := 0 <= internal_index and internal_index <= n
		end

feature {NONE}

	forth is
		do
			internal_index := internal_index + 1
			target.forth
		end

	action is
		do
			operand.execute (target.item)
			value := value + operand.value
		ensure then
			-- value = sum (
			-- target [original_index .. original_index + internal_index - 1])
			--   where original_index is the value of target.index when
			--   execute is called.
		end

	exhausted: BOOLEAN is
		do
			Result := internal_index = n
		end

	start is
			-- Should never be called.
		do
			check false end
		end

invariant

	operator_not_void: operand /= Void

end -- class LINEAR_SUM
