indexing
	description:
		"A market function that uses an agent for its calculations and %
		%that takes a list of arguments"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class AGENT_BASED_FUNCTION inherit

	COMPLEX_FUNCTION
		redefine
			set_innermost_input, operators, reset_parameters, operator_used,
			immediate_parameters
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (key: like calculator_key; op: like operator; ins: like inputs) is
		require
			f_exists: key /= Void
		do
			if op /= Void then
				set_operator (op)
				operator.initialize (Current)
			end
			create output.make (0)
			calculator_key := key
			if ins = Void then
				create {LINKED_LIST [MARKET_FUNCTION]} inputs.make
			else
				inputs := ins
			end
			create immediate_parameters.make
print ("calculator was set to: " + calculator.out + "%N")
print ("inputs.count: " + inputs.count.out + "%N")
		ensure
			set: operator = op and calculator_key = key and
				(ins /= Void implies inputs = ins)
			no_op_init: not operator_needs_initializing
		end

feature -- Access

	agent_table: MARKET_AGENTS is
			-- Table of available "market-agents"
		once
			create Result
		end

	calculator: PROCEDURE [ANY, TUPLE [like Current]] is
			-- Agent to be used for processing
		do
			Result := agent_table @ calculator_key
		end

	calculator_key: INTEGER
			-- Key to Current's calculator

	trading_period_type: TIME_PERIOD_TYPE is
		local
			gs: expanded GLOBAL_SERVICES
		do
			if inputs.is_empty then
				Result := gs.period_types_in_order @ gs.Daily
			else
				Result := inputs.first.trading_period_type
			end
		ensure then
			definition: (inputs.is_empty implies
				Result.name.is_equal (Result.Daily)) and
				(not inputs.is_empty implies
				Result = inputs.first.trading_period_type)
		end

	short_description: STRING is
		do
			Result := "Indicator that operates on a configurable number %
				%of data sequences%Nwith a configurable calculation procecure"
		end

	full_description: STRING is
		do
			Result := short_description + ":%N"
			if not inputs.is_empty then
				inputs.start
				Result := Result + inputs.item.full_description
				from inputs.forth until inputs.exhausted loop
					Result := Result + ",%N" + inputs.item.full_description
					inputs.forth
				end
			end
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		local
			parameter_set: LINKED_SET [FUNCTION_PARAMETER]
		do
			if parameter_list = Void then
				create parameter_list.make
				create parameter_set.make
				if immediate_parameters /= Void then
					parameter_set.fill (immediate_parameters)
				end
				from inputs.start until inputs.exhausted loop
					check
						input_parameters_not_void:
							inputs.item.parameters /= Void
					end
					parameter_set.fill (inputs.item.parameters)
					inputs.forth
				end
				parameter_list.append (parameter_set)
			end
			Result := parameter_list
		end

	children: LIST [MARKET_FUNCTION] is
		do
			create {LINKED_LIST [MARKET_FUNCTION]} Result.make
			from
				inputs.start
			until
				inputs.exhausted
			loop
				Result.extend (inputs.item)
				inputs.forth
			end
		end

	operators: LIST [COMMAND] is
		do
			Result := Precursor
			from
				inputs.start
			until
				inputs.exhausted
			loop
				Result.append (inputs.item.operators)
				inputs.forth
			end
		end

	leaf_functions: LIST [COMPLEX_FUNCTION] is
		local
			f: COMPLEX_FUNCTION
		do
			create {LINKED_LIST [COMPLEX_FUNCTION]} Result.make
			if not inputs.is_empty then
				from
					inputs.start
				until
					inputs.exhausted
				loop
					if inputs.item.is_complex then
						f ?= inputs.item
						Result.append (f.leaf_functions)
					end
					inputs.forth
				end
			else
				Result.extend (Current)
			end
		end

	immediate_parameters: LINKED_LIST [FUNCTION_PARAMETER]

feature -- Status report

	processed: BOOLEAN is
		do
			Result := processed_date_time /= Void
			--!!!!!Check if this implementation is adequate.
		end

	has_children: BOOLEAN is true

	operator_used: BOOLEAN is
		do
			Result := operator /= Void
		end

	operator_needs_initializing: BOOLEAN
			-- Does `operator' need initializing when `set_innermost_input'
			-- is called?

feature {NONE}

	do_process is
			-- Execute the `calculator'.
		do
print ("do_process start - calculator: " + calculator.out + "%N")
			calculator.call ([Current])
print ("do_process end%N")
		end

	pre_process is
		do
			from inputs.start until inputs.exhausted loop
				if not inputs.item.processed then
					inputs.item.process
				end
				inputs.forth
			end
		end

feature {FACTORY} -- Status setting

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		do
print ("set_innermost_input called with in.count: " + in.count.out + "%N")
			processed_date_time := Void
			if
				inputs.is_empty or else (inputs.count = 1 and
				not inputs.first.is_complex)
			then
				inputs.wipe_out
				inputs.extend (in)
			else
				from inputs.start until inputs.exhausted loop
					inputs.item.set_innermost_input (in)
print ("is_complex: " + inputs.item.is_complex.out + "%N")
					inputs.forth
				end
			end
print ("set_innermost_input - inputs.count: " + inputs.count.out + "%N")
			if operator /= Void and operator_needs_initializing then
				-- !!!Check if the operator_needs_initializing
				-- construct is adequate.
				operator.initialize (Current)
			end
			output.wipe_out
		end

feature {MARKET_FUNCTION_EDITOR}

	reset_parameters is
		do
			parameter_list := Void
			inputs.do_all (agent reset_market_function_parameters)
		end

	add_parameter (p: FUNCTION_PARAMETER) is
			-- Add `p' to `parameters'.
		do
			immediate_parameters.extend (p)
			-- Force `parameters' to recreate `parameter_list':
			parameter_list := Void
		end

	set_operator_needs_initializing (arg: BOOLEAN) is
			-- Set `operator_needs_initializing' to `arg'.
		require
			op_exists: operator /= Void
		do
			operator_needs_initializing := arg
		ensure
			operator_needs_initializing_set: operator_needs_initializing = arg
		end

feature {MARKET_FUNCTION_EDITOR, MARKET_AGENTS}

	inputs: LIST [MARKET_FUNCTION]
			-- All inputs to be used for processing

feature {NONE} -- Implementation

	initialize_operators is
			-- Initialize all operators that are not Void - default:
			-- initialize `operator' if it's not Void.
		do
			if operator /= Void then
				-- operator will set its target to new input.output.
				operator.initialize (Current)
			end
		end

	reset_market_function_parameters (mf: MARKET_FUNCTION) is
		do
			mf.reset_parameters
		end

invariant

	inputs_exist: inputs /= Void
	has_inputs_count_children: children.count = inputs.count
	operator_used_definition: operator_used = (operator /= Void)
	calculator_exists: calculator /= Void
	calculator_definition: calculator = agent_table @ calculator_key

end