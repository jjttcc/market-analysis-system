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
			set_innermost_input, operators, reset_parameters, operator_used
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (fkey: like function_key; op: like operator; ins: like inputs) is
		require
			f_exists: fkey /= Void
		do
			if op /= Void then
				set_operator (op)
				operator.initialize (Current)
			end
			make_output
			function_key := fkey
			if ins = Void then
				create inputs.make (0)
			else
				inputs := ins
			end
print ("function was set to: " + function.out + "%N")
print ("inputs.count: " + inputs.count.out + "%N")
		ensure
			set: operator = op and function_key = fkey and
				(ins /= Void implies inputs = ins)
		end

feature -- Access

	agent_table: MARKET_AGENTS is
			-- Table of available "market-agent" functions
		once
			create Result
		end

	function: FUNCTION [ANY, TUPLE [LIST [MARKET_FUNCTION]],
		MARKET_TUPLE_LIST [MARKET_TUPLE]] is
			-- Agent to be used for processing
		do
			Result := agent_table @ function_key
		end

	function_key: INTEGER
			-- Key to Current's function

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
			Result := "!!!!To be specified"
		end

	full_description: STRING is
		do
			Result := "!!!!To be specified"
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		do
			-- Stub !!!!Implementation to be determined
 if parameter_list = Void then
	create parameter_list.make
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

feature -- Status report

	processed: BOOLEAN is
		do
			Result := processed_date_time /= Void
			--!!!!!Stub
		end

	has_children: BOOLEAN is true

	operator_used: BOOLEAN is
		do
			Result := operator /= Void
		end

feature {NONE}

	do_process is
			-- Execute the function.
		do
print ("do_process start - function: " + function.out + "%N")
			output := function.item ([inputs])
print ("do_process end%N")
		end

	pre_process is
		do
			if not output.is_empty then
				--!!!!This may not be needed:
				output.wipe_out
			end
			--!!!!!For each i in inputs: if not i.processed then i.process end
			--!!!!Anything else?
		end

feature {FACTORY} -- Status setting

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
		do
print ("set_innermost_input called with in.count: " + in.count.out + "%N")
			-- !!!!Stub - Look at set_innermost_input implentation in
			-- ONE_VARIABLE_FUNCTION and decide if that logic applies here.
--!!!For experimentation/testing - may be appropriate in final implementation
--inside of a guard:
if
	inputs.is_empty or else inputs.count = 1 and not inputs.first.is_complex
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
			output.wipe_out
		end

feature {MARKET_FUNCTION_EDITOR}

	reset_parameters is
		do
			parameter_list := Void
			-- !!!!! Call reset_parameters on all inputs.
		end

feature {MARKET_FUNCTION_EDITOR}

	inputs: ARRAYED_LIST [MARKET_FUNCTION]
			-- All inputs to be used for processing

feature {NONE} -- Implementation

	make_output is
		do
			-- !!!How many elements?
			create output.make (0)
		end

	initialize_operators is
			-- Initialize all operators that are not Void - default:
			-- initialize `operator' if it's not Void.
		do
			if operator /= Void then
				-- operator will set its target to new input.output.
				operator.initialize (Current)
			end
		end

invariant

	inputs_exist: inputs /= Void
	has_inputs_count_children: children.count = inputs.count
	operator_used_definition: operator_used = (operator /= Void)
	function_exists: function /= Void
	function_definition: function = agent_table @ function_key

end -- class ONE_VARIABLE_FUNCTION
