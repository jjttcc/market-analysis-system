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
			set_innermost_input, reset_parameters, operator_used,
			immediate_direct_parameters
		end

	LINEAR_ANALYZER

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (key: like calculator_key; op: like operator; ins: like inputs) is
		require
			key_exists: key /= Void
		do
			if ins = Void then
				create {LINKED_LIST [MARKET_FUNCTION]} inputs.make
			else
				inputs := ins
			end
			if op /= Void then
				set_operator (op)
				operator.initialize (Current)
			end
			create output.make (0)
			calculator_key := key
			create immediate_direct_parameters.make
		ensure
			set: operator = op and calculator_key = key and
				(ins /= Void implies inputs = ins)
			no_op_init: not operator_needs_initializing
		end

feature -- Access

	agent_table: MARKET_AGENTS is
			-- Table of available "market-agents"
		once
			--@@If the application is made multi-threaded, this should be
			--"once-per-thread".
			create Result
		end

	calculator: PROCEDURE [ANY, TUPLE [like Current]] is
			-- Agent to be used for processing
		do
			Result := agent_table @ calculator_key
		end

	calculator_key: STRING
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

	immediate_direct_parameters: LINKED_LIST [FUNCTION_PARAMETER]

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE] is
		do
			if not inputs.is_empty then
				Result := inputs.first.innermost_input
			end
		ensure then
			defined_if_inputs_not_empty:
				not inputs.is_empty implies Result /= Void
		end

	target: CHAIN [MARKET_TUPLE] is
		do
			if not inputs.is_empty then
				Result := inputs.first.output
			else
				Result := default_target
			end
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := processed_date_time /= Void
		end

	has_children: BOOLEAN is True

	operator_used: BOOLEAN is
		do
			Result := operator /= Void
		end

--!!!!!!!Obsolete?:
	operator_needs_initializing: BOOLEAN
			-- Does `operator' need initializing when `set_innermost_input'
			-- is called?

feature {NONE}

	do_process is
			-- Execute the `calculator'.
		do
			check
				innermost_input_set: inputs.count > 0 and
					innermost_input /= Void
			end
			calculator.call ([Current])
		end

	pre_process is
		do
			check
				innermost_input_set: inputs.count > 0 and
					innermost_input /= Void
			end
			from inputs.start until inputs.exhausted loop
				if not inputs.item.processed then
					inputs.item.process
				end
				inputs.forth
			end
		end

feature {FACTORY} -- Element change

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		do
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
					inputs.forth
				end
			end
			if operator /= Void then
				-- !!!Check if the operator_needs_initializing
				-- construct is adequate or if it's even needed.
				operator.initialize (Current)
			end
			output.wipe_out
		end

feature {MARKET_FUNCTION_EDITOR} -- Element change

	set_calculator_key (arg: STRING) is
			-- Set `calculator_key' to `arg' and add the associated `params'.
		require
			arg_not_void: arg /= Void
			valid_key: agent_table.keys.has (arg)
		local
			params: LINEAR [FUNCTION_PARAMETER]
		do
			calculator_key := arg
			immediate_direct_parameters.wipe_out
			params := agent_table.parameters_for (calculator_key)
			params.do_all (agent add_parameter)
		ensure
			calculator_key_set: calculator_key = arg and calculator_key /= Void
			associated_parameters_added: immediate_direct_parameters.count = 
				agent_table.parameters_for (calculator_key).count
		end

	reset_parameters is
		do
			inputs.do_all (agent reset_market_function_parameters)
		end

	add_parameter (p: FUNCTION_PARAMETER) is
			-- Add `p' to `parameters'.
		do
			immediate_direct_parameters.extend (p)
		end

	add_input (f: MARKET_FUNCTION) is
			-- Add `f' to `inputs'.
		require
			f_exists: f /= Void
		do
			inputs.extend (f)
		ensure
			one_more: inputs.count = old inputs.count + 1
			added: inputs.last = f
		end

--!!!!!!!Obsolete?:
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

feature {MARKET_FUNCTION_EDITOR} -- Removal

	clear_inputs is
			-- Remove all elements of `inputs'.
		do
			inputs.wipe_out
		end

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

	default_target: CHAIN [MARKET_TUPLE] is
		once
			create {LINKED_LIST [MARKET_TUPLE]} Result.make
		end

invariant

	inputs_exist: inputs /= Void
	has_inputs_count_children: children.count = inputs.count
	at_least_one_input_when_innermost_input_set:
		innermost_input /= Void implies inputs.count > 0
	operator_used_definition: operator_used = (operator /= Void)
	calculator_exists: calculator /= Void
	calculator_definition: calculator = agent_table @ calculator_key
	immediate_direct_parameters_exist: immediate_direct_parameters /= Void

end
