indexing
	description: "Sum of n sequential elements";
	restrictions: "execute expects target.count >= n."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LINEAR_SUM inherit

	N_RECORD_LINEAR_COMMAND
		rename
			offset as internal_index, make as nrlc_make_unused
		redefine
			execute, target_cursor_not_affected,
			exhausted, action, forth, invariant_value, start
		end

creation

	make

feature {FACTORY} -- Initialization

	make (t: like target; op: BASIC_NUMERIC_COMMAND; i: like n) is
		require
			args_not_void: t /= Void and op /= Void
			i_gt_0: i > 0
		do
			set_target (t)
			set_operator (op)
			set_n (i)
		ensure
			set: target = t operator = op and n = i
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

feature {FACTORY} -- Status setting

	set_operator (op: BASIC_NUMERIC_COMMAND) is
			-- Set operator that provides the value to be summed (from
			-- the current item).
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			set: operator = op
		end

feature {FACTORY} -- Access

	operator: BASIC_NUMERIC_COMMAND

feature {NONE}

	forth is
		do
			internal_index := internal_index + 1
			target.forth
		end

	action is
		do
			operator.execute (target.item)
			value := value + operator.value
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

	operator_not_void: operator /= Void

end -- class LINEAR_SUM
