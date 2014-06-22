note
	description:
		"A function that outputs an array of market tuples.  Specifications %
		%for function input are provided by descendant classes."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MARKET_FUNCTION inherit

	GENERIC_FACTORY [MARKET_TUPLE_LIST [MARKET_TUPLE]]
		rename
			product as output, execute as process
		redefine
			output
		end

	MARKET_PROCESSOR

	TREE_NODE
		redefine
			name, copy_of_children, descendant_comparison_is_by_objects
		end

	FUNCTION_PARAMETER
		rename
			description as short_description
		undefine
			is_equal
		end

feature -- Access

	name: STRING
			-- Function name
		do
			if name_implementation /= Void then
				Result := name_implementation
			else
				Result := ""
			end
		end

	short_description: STRING
			-- Short description of the function
		deferred
		end

	full_description: STRING
			-- Full description of the function, including descriptions
			-- of contained functions, if any
		deferred
		end

	output: MARKET_TUPLE_LIST [MARKET_TUPLE]
			-- y of function "y = f(x)"
		deferred
		end

	trading_period_type: TIME_PERIOD_TYPE
			-- Type of trading period associated with each tuple:  hourly,
			-- daily, weekly, etc.
		deferred
		end

	immediate_parameters: LIST [FUNCTION_PARAMETER]
			-- Changeable parameters for this function, exluding those
			-- of `descendants'
		do
			Result := immediate_direct_parameters.twin
			Result.append (immediate_operator_parameters)
		ensure
			result_exists: Result /= Void
			immediate_direct_plus_ops: Result.count =
				immediate_direct_parameters.count +
				immediate_operator_parameters.count
		end

	processed_date_time: DATE_TIME
			-- Date and time the function was last processed
		deferred
		end

	children: LIST [MARKET_FUNCTION]
			-- This function's children, if this is a composite function
		deferred
		end

	functions: LIST [MARKET_FUNCTION]
		do
			Result := descendants
			Result.extend (Current)
		end

	operators: LIST [COMMAND]
		local
			l: LIST [MARKET_FUNCTION]
		do
			create {LINKED_SET [COMMAND]} Result.make
			if attached {SEQUENCE [COMMAND]} immediate_operators as ops then
				Result.append (ops)
			end
			l := children
			if l /= Void then
				from l.start until l.exhausted loop
					Result.append (l.item.operators)
					l.forth
				end
			end
		end

	required_tuple_types: SET [MARKET_TUPLE]
			-- One instance of each MARKET_TUPLE descendant used by Current
			-- or one of its operators
		local
			ops: LIST [COMMAND]
			suppliers: LINEAR [ANY]
			tuple: MARKET_TUPLE
		do
			create {LINKED_SET [MARKET_TUPLE]} Result.make
			from
				ops := operators
				ops.start
			until
				ops.exhausted
			loop
				from
					suppliers := ops.item.suppliers.linear_representation
					suppliers.start
				until
					suppliers.exhausted
				loop
					tuple ?= suppliers.item
					if tuple /= Void then
						Result.extend (tuple)
					end
					suppliers.forth
				end
				ops.forth
			end
		end

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE]
			-- The innermost input sequence to be processed
		deferred
		end

feature -- Status report

	processed: BOOLEAN
			-- Has this function been processed?
		deferred
		end

	has_children: BOOLEAN
			-- Does this function have children?
		deferred
		ensure
			Result implies children /= Void and not children.is_empty
		end

	debugging: BOOLEAN
			-- Is debugging mode on?
		local
			gs: expanded GLOBAL_SERVICES
		do
			Result := gs.debug_state.market_functions
		end

feature {FACTORY, MARKET_FUNCTION_EDITOR} -- Element change

	set_name (n: STRING)
			-- Set the function's name to n.
		require
			not_void: n /= Void
		do
			name_implementation := n
		ensure
			is_set: name = n and name /= Void
		end

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE])
			-- If the run-time type is a complex function, set the innermost
			-- input attribute to `in', else do nothing.
		require
			not_void: in /= Void and in.trading_period_type /= Void
		do
		ensure
			output_empty_if_complex_and_not_processed:
				is_complex and not processed implies output.is_empty
		end

feature -- Basic operations

	process
			-- Process the output from the input.
		deferred
		ensure then
			processed: processed
		end

feature {MARKET_FUNCTION, MARKET_FUNCTION_EDITOR}

	is_complex: BOOLEAN
			-- Is the run-time type a complex function?
		deferred
		end

feature {MARKET_FUNCTION_EDITOR, MARKET_FUNCTION}

	reset_parameters
			-- Reset the cached parameter list to ensure it is up to date
			-- after a change in the composite function's structure - that
			-- is, after one of the (direct or indirect) input functions
			-- has been changed.
		do
			-- Default to null action - redefine as needed.
		end

feature {MARKET_FUNCTION}

	immediate_direct_parameters: LIST [FUNCTION_PARAMETER]
			-- Parameters of Current, excluding `operator_parameters' and
			-- exluding those of `descendants'
		do
			-- Default to empty list - Redefine as needed.
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	direct_parameters: like parameters
			-- Parameters of Current, excluding `operator_parameters'
		local
			parameter_set: LINKED_SET [FUNCTION_PARAMETER]
			flist: like functions
		do
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
			create parameter_set.make
			flist := functions
			across flist as ic loop
				parameter_set.fill(ic.item.immediate_direct_parameters)
			end
			Result.append (parameter_set)
		ensure
			result_exists: Result /= Void
		end

	immediate_operators: like operators
			-- All operators that belong directly to this function, but not
			-- to its descendants
		do
			-- Default to empty list - Redefine as needed.
			create {LINKED_LIST [COMMAND]} Result.make
		ensure
			exists: Result /= Void
		end

	operator_parameters: LIST [FUNCTION_PARAMETER]
			-- Parameters belonging to `operators'
		local
			ops: like operators
		do
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
			if operators /= Void then
				from
					ops := operators
					ops.start
				until
					ops.exhausted
				loop
					prepare_operator_for_editing (ops.item, Result)
					ops.forth
				end
			end
		ensure
			result_exists: Result /= Void
		end

	immediate_operator_parameters: LIST [FUNCTION_PARAMETER]
			-- Parameters of `immediate_operators'
		local
			ops: like operators
		do
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
			ops := immediate_operators
			if ops /= Void then
				from
					ops.start
				until
					ops.exhausted
				loop
					prepare_operator_for_editing (ops.item, Result)
					ops.forth
				end
			end
		ensure
			result_exists: Result /= Void
		end

--!!!!![14.05]It appears the old version, above, is OK; if so, delete this
--!!!!!routine:
	new_immediate_operator_parameters: LIST [FUNCTION_PARAMETER]
			-- Parameters of `immediate_operators'
		local
			ops: LIST [TREE_NODE]
		do
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
			ops := immediate_operators
			if ops /= Void then
				across ops as cursor loop
					if attached {COMMAND} cursor.item as cmd then
						prepare_operator_for_editing (cmd, Result)
					end
				end
			end
		ensure
			result_exists: Result /= Void
		end

	prepare_operator_for_editing (op: COMMAND; l: LIST [FUNCTION_PARAMETER])
			-- If `op' is editable, prepare it for editing
			-- (as a FUNCTION_PARAMETER).
		do
			if op.is_editable then
				op.prepare_for_editing (l)
			end
		end

	copy_of_children: like children
		do
			Result := children.twin
		end

	descendant_comparison_is_by_objects: BOOLEAN
		do
			Result := True
		end

	name_implementation: STRING

feature {NONE} -- (from FUNCTION_PARAMETER)

	current_value: STRING
		do
			Result := output.out
		end

	value_type_description: STRING = "[MARKET_FUNCTION - to-be-defined]"

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := current_value.is_equal (v)
		end

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and then not v.is_empty
		end

	change_value (v: STRING)
		do
			--!!!!![14.05]Should this really do nothing???!!!!
			do_nothing
		end


invariant

	output_not_void: output /= Void
	parameters_not_void: parameters /= Void and immediate_parameters /= Void
	date_time_not_void_when_processed:
		processed implies processed_date_time /= Void
	operators_not_void: operators /= Void

end -- class MARKET_FUNCTION
