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
		redefine
			test, action, forth, invariant_value
		end

	N_RECORD_STRUCTURE

feature -- Initialization

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
		end

feature -- Status report

	operator_set: BOOLEAN is
			-- Has the operator used for the operation been set?
		do
			Result := operator /= Void
		ensure
			true_if_op_not_void: Result = (operator /= Void)
		end

	arg_used: BOOLEAN is
		do
			Result := false
		ensure then
			not_used: Result = false
		end

	execute_precondition: BOOLEAN is
		do
			Result := operator_set and input_set and n_set
		ensure then
			op_input_n_set: Result = (operator_set and input_set and n_set)
		end

	execute_postcondition: BOOLEAN is
		do
			Result := internal_index = n
		ensure then
			-- target.index = old target.index + n and
			-- value =
			--  sum (target[old target.index .. old target.index+n-1])
			--    [where operation is the operation to be performed]
			int_index_eq_n: Result = (internal_index = n)
		end

feature {NONE}

	invariant_value: BOOLEAN is
		do
			Result := 0 <= internal_index and internal_index <= n
		end

feature {MARKET_FUNCTION, FACTORY} -- Element change

	set_operator (op: BASIC_NUMERIC_COMMAND) is
			-- Set operator that provides the value to be summed (from
			-- the current item).
		require
			not_void: op /= Void
		do
			operator := op
		ensure
			set: operator = op
			op_set: operator_set
		end

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

end -- class LINEAR_SUM
