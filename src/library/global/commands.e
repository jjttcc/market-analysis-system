indexing
	description: "An instance of each instantiable COMMAND class"
	author: "Jim Cochrane"
	date: "$Date$";
	note: "`make_instances' must be called before using any of the command-%
		%instance queries: true_command, false_command, etc."
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMANDS inherit

	CLASSES [COMMAND]
		rename
			instances as command_instances,
			description as command_description, 
			instance_with_generator as command_with_generator
		redefine
			command_instances
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

feature -- Initialization

	make_instances is
			-- Ensure that all "once" data are created.
		local
			i_and_d: ARRAYED_LIST [PAIR [COMMAND, STRING]]
			cmd_names: ARRAYED_LIST [STRING]
		do
			i_and_d := instances_and_descriptions
			cmd_names := command_names
		end

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [COMMAND, STRING]] is
			-- An instance and description of each COMMAND class used
			-- in indicator or market-analyzer creation
		once
			create Result.make (0)
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				numeric_value_command,
				"Operator that simply stores a numeric value - Can be %
				%used as a constant or a variable"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (true_command,
				"Boolean operator whose result is always true"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (false_command,
				"Boolean operator whose result is always false"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (and_operator,
				"Logical 'and' operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (or_operator,
				"Logical 'or' operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (xor_operator,
				"Logical 'exclusive or' operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (eq_operator,
				"Operator that compares two numbers for equality"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (lt_operator,
				"Numeric comparison operator that determines whether the %
				%first number is less than the second"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (gt_operator,
				"Numeric comparison operator that determines whether the %
				%first number is greater than the second"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (ge_operator,
				"Numeric comparison operator that determines whether the %
				%first number is greater than or equal to the second"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (le_operator,
				"Numeric comparison operator that determines whether the %
				%first%Nnumber is less than or equal to the second"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				implication_operator,
				"Logical implication operator - True when %
				%the left%Noperand is false or both operands are true"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				equivalence_operator,
				"Logical equivalence operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (addition,
				"Addition operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (subtraction,
				"Subtraction operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				multiplication, "Multiplication operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (division,
				"Division operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (safe_division,
				"Division operator that handles division by zero safely"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (power,
				"Operator whose result is %
				%its left operand to the power of its right operand"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (n_th_root,
				"Operator whose result is the n-th root %
				%(specified by its right operand) of its left operand"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				absolute_value, "Absolute value operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (rounded_value,
				"Rounded value operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (square_root,
				"Square root operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (log_cmd,
				"Natural logarithm operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (log2_cmd,
				"Base-2 logarithm operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (log10_cmd,
				"Base-10 logarithm operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (not_operator,
				"Logical negation operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				index_extractor,
				"Operator that extracts the current index value from %
				%an indexed operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				basic_numeric_command,
				"Operator that obtains the numeric value for the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (highest_value,
				"Operator that extracts the highest value from a subsequence %
				%%Nof n trading periods"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (lowest_value,
				"Operator that extracts the lowest value from a subsequence %
				%%Nof n trading periods"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (linear_sum,
				"Operator that sums a subsequence of n records"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				minus_n_command,
				"Operator that processes data n periods before the current %
				%trading%N period - used, for example, for the momentum %
				%indicator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				n_value_command,
				"n-valued operator whose value is `n'"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				ma_exponential,
				"Moving average exponential"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				settable_offset_command,
				"Operator that processes data based on a settable offset %
				%from the current%Ntrading period - Warning: Be careful to %
				%set the offset correctly; setting%N it to the wrong value %
				%may cause out-of-bounds access to the data tuple array"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (volume,
				"Operator that extracts the volume for the current trading %
				%period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (low_price,
				"Operator that extracts the low price for the current trading %
				%period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (high_price,
				"Operator that extracts the high price for the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (closing_price,
				"Operator that extracts the closing price for the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (opening_price,
				"Operator that extracts the opening price for the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (open_interest,
				"Operator that extracts the open interest for the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				basic_linear_command,
				"Operator that retrieves the value at the current %
				%trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				unary_linear_operator,
				"Operator that operates on the current trading period"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				n_based_unary_operator, "N-based operator whose value %
				%remains unchanged after initialization and that obtains %
				%its value from a sub-operator"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				numeric_conditional_command,
				"Operator that makes a decision based on %
				%the value of executing its%Nboolean operator - if the %
				%result is true, value is set to the result of%Nexecuting %
				%its 'true command'; otherwise, value is set to the %
				%result of%Nexecuting its 'false command'.  This operator %
				%can thus function as%Nan if/else block that produces %
				%a numeric value.%N"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (sign_analyzer,
				"Operator that detects sign changes with respect to its %
				%left and right operands"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				slope_analyzer,
				"Operator that calculates the slope of a function"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				function_based_command,
				"Operator that processes a sequence of records %
				%obtained from a%Nmarket function - only used by %
				%ONE_VARIABLE_FUNCTION_ANALYZER"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				numeric_assignment_command,
				"Operator that executes its %
				%'main_operator' and stores the resulting value%Nin a %
				%target NUMERIC_VALUE_COMMAND and whose result is the %
				%target's%Nresulting value"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				numeric_valued_command_wrapper,
				"Numeric operator that can be used to %"wrap%" a non-numeric %
				%operator,%Nallowing it to be used in a numeric context.  If %
				%this operator can%Ndetermine if the wrapped operator has a %
				%value, it will set its value to%Nthat value; if the wrapped %
				%operator's value is boolean it will convert%Na true value to %
				%1 and a false value to 0. If no value can be found,%Nthis %
				%operator's value will be 0."))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				command_sequence,
				"Operator that executes a sequence of sub-operators%N%
				%Note: This operator cannot be used where a numeric-valued %
				%operator is%Nexepcted.  If it needs to be used in such %
				%a context, it can be%Nwrapped with a %
				%%"NUMERIC_VALUED_COMMAND_WRAPPER%"."))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (loop_command,
				"Operator that emulates a loop construct"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				loop_with_assertions,
				"Loop command that provides for the specification of a %
				%loop invariant and a loop variant"))
			Result.extend (create {PAIR [COMMAND, STRING]}.make (
				value_at_index_command, "Operator that operates on a %
				%specified trading period according to its 'index value'"))
		end

	command_instances: ARRAYED_LIST [COMMAND] is
		once
			Result := Precursor
		end

	command_names: ARRAYED_LIST [STRING] is
		once
			Result := names
		ensure
			object_comparison: Result.object_comparison
			not_void: Result /= Void
			Result.count = command_instances.count
		end

feature -- Access - an instance of each command

	absolute_value: ABSOLUTE_VALUE is
		once
			create Result.make (numeric_value_command)
		end

	addition: ADDITION is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	and_operator: AND_OPERATOR is
		once
			create Result.make (true_command, true_command)
		end

	basic_linear_command: BASIC_LINEAR_COMMAND is
		once
			create Result.make (
				default_market_tuple_list)
		end

	basic_numeric_command: BASIC_NUMERIC_COMMAND is
		once
			create Result
		end

	closing_price: CLOSING_PRICE is
		once
			create Result
		end

	command_sequence: COMMAND_SEQUENCE is
		once
			create Result.make
		end

	division: DIVISION is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	eq_operator: EQ_OPERATOR is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	equivalence_operator: EQUIVALENCE_OPERATOR is
		once
			create Result.make (
				true_command, true_command)
		end

	false_command: FALSE_COMMAND is
		once
			create Result
		end

	function_based_command: FUNCTION_BASED_COMMAND is
		local
			stock: STOCK
		once
			create stock.make ("DUMMY", Void, Void)
			create Result.make (stock,
				numeric_value_command)
		end

	ge_operator: GE_OPERATOR is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	gt_operator: GT_OPERATOR is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	highest_value: HIGHEST_VALUE is
		once
			create Result.make (
				default_market_tuple_list, basic_numeric_command, 1)
		end

	high_price: HIGH_PRICE is
		once
			create Result
		end

	implication_operator: IMPLICATION_OPERATOR is
		once
			create Result.make (
				true_command, true_command)
		end

	index_extractor: INDEX_EXTRACTOR is
		once
			create Result.make (Void)
		end

	le_operator: LE_OPERATOR is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	linear_sum: LINEAR_SUM is
		once
			create Result.make (default_market_tuple_list,
				basic_numeric_command, 1)
		end

	log10_cmd: LOG10 is
		once
			create Result.make (numeric_value_command)
		end

	log2_cmd: LOG2 is
		once
			create Result.make (numeric_value_command)
		end

	log_cmd: LOG is
		once
			create Result.make (numeric_value_command)
		end

	loop_command: LOOP_COMMAND is
		once
			create Result.make (false_command, false_command,
				numeric_value_command)
		end

	loop_with_assertions: LOOP_WITH_ASSERTIONS is
		once
			create Result.make (false_command, false_command,
				numeric_value_command)
		end

	lowest_value: LOWEST_VALUE is
		once
			create Result.make (default_market_tuple_list,
				basic_numeric_command, 1)
		end

	low_price: LOW_PRICE is
		once
			create Result
		end

	lt_operator: LT_OPERATOR is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	ma_exponential: MA_EXPONENTIAL is
		once
			create Result.make (1)
		end

	minus_n_command: MINUS_N_COMMAND is
		once
			create Result.make (
				default_market_tuple_list, basic_numeric_command, 1)
		end

	multiplication: MULTIPLICATION is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	n_based_unary_operator: N_BASED_UNARY_OPERATOR is
		once
			create Result.make (
				numeric_value_command, 1)
		end

	not_operator: NOT_OPERATOR is
		once
			create Result.make (true_command)
		end

	n_th_root: N_TH_ROOT is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	numeric_assignment_command: NUMERIC_ASSIGNMENT_COMMAND is
		once
			create Result.make (
				basic_numeric_command, numeric_value_command)
		end

	numeric_conditional_command: NUMERIC_CONDITIONAL_COMMAND is
		once
			create Result.make (lt_operator,
				numeric_value_command, numeric_value_command)
		end

	numeric_value_command: NUMERIC_VALUE_COMMAND is
		once
			create Result.make (0.0)
		end

	numeric_valued_command_wrapper: NUMERIC_VALUED_COMMAND_WRAPPER is
		once
			create Result.make (numeric_value_command)
		end

	n_value_command: N_VALUE_COMMAND is
		once
			create Result.make (1)
		end

	opening_price: OPENING_PRICE is
		once
			create Result
		end

	open_interest: OPEN_INTEREST is
		once
			create Result
		end

	or_operator: OR_OPERATOR is
		once
			create Result.make (true_command, true_command)
		end

	power: POWER is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	rounded_value: ROUNDED_VALUE is
		once
			create Result.make (numeric_value_command)
		end

	safe_division: SAFE_DIVISION is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	settable_offset_command: SETTABLE_OFFSET_COMMAND is
		once
			create Result.make (
				default_market_tuple_list, basic_numeric_command)
		end

	sign_analyzer: SIGN_ANALYZER is
		once
			create Result.make (numeric_value_command,
				numeric_value_command, False)
		end

	slope_analyzer: SLOPE_ANALYZER is
		once
			create Result.make (
				default_market_tuple_list)
		end

	square_root: SQUARE_ROOT is
		once
			create Result.make (numeric_value_command)
		end

	subtraction: SUBTRACTION is
		once
			create Result.make (numeric_value_command,
				numeric_value_command)
		end

	true_command: TRUE_COMMAND is
		once
			create Result
		end

	unary_linear_operator: UNARY_LINEAR_OPERATOR is
		once
			create Result.make (default_market_tuple_list,
				numeric_value_command)
		end

	value_at_index_command: VALUE_AT_INDEX_COMMAND is
		once
			create Result.make (default_market_tuple_list,
				numeric_value_command, numeric_value_command)
		end

	volume: VOLUME is
		once
			create Result
		end

	xor_operator: XOR_OPERATOR is
		once
			create Result.make (true_command, true_command)
		end

feature {NONE} -- Implementation

	default_market_tuple_list: LIST [MARKET_TUPLE] is
			-- Default list of MARKET_TUPLE to provide to the make routines
			-- of those COMMANDs that require such
		once
			create {LINKED_LIST [MARKET_TUPLE]} Result.make
		end

end -- COMMANDS
