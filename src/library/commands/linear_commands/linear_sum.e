indexing
	description: "Sum of n sequential elements";
	date: "$Date$";
	revision: "$Revision$"

class LINEAR_SUM inherit

	NUMERIC_COMMAND
		redefine
			initialize
		end

	LINEAR_ANALYZER
		export {NONE}
			all
				{FACTORY}
			set_target
		redefine
			test, action, forth, invariant_value
		end

	N_RECORD_STRUCTURE

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

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
		ensure then
			n = arg.n
		end

feature -- Basic operations

	execute (arg: ANY) is
			-- Operate on the next n elements of the input, beginning
			-- at the current cursor position.
		do
			internal_index := 0
			value := 0
			until_continue
		ensure then
			target.index = old target.index + n
			-- value = sum (target[old target.index .. old target.index+n-1])
			int_index_eq_n: internal_index = n
		end

feature -- Status report

	arg_used: BOOLEAN is
		do
			Result := false
		ensure then
			not_used: Result = false
		end

feature {NONE}

	invariant_value: BOOLEAN is
		do
			Result := 0 <= internal_index and internal_index <= n
		end

feature {FACTORY} -- Element change

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
			check operator /= Void end
			operator.execute (target.item)
			value := value + operator.value
		ensure then
			-- value = sum (
			-- target [original_index .. original_index + internal_index - 1])
			--   where original_index is the value of target.index when
			--   execute is called.
		end

	test: BOOLEAN is
		do
			Result := internal_index = n
		end

feature {NONE}

	internal_index: INTEGER

invariant

	operator_not_void: operator /= Void

end -- class LINEAR_SUM
