indexing
	description: "An instance of each instantiable COMMAND class"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [COMMAND, STRING]] is
			-- An instance and description of each COMMAND class
		local
			true_dummy: TRUE_COMMAND
			bool_real_dummy: LT_OPERATOR
			cmd: COMMAND
			real_dummy: CONSTANT
			pair: PAIR [COMMAND, STRING]
			bnc_dummy: BASIC_NUMERIC_COMMAND
			stock: STOCK
		once
			!!stock.make ("DUMMY",
				period_types @ (period_type_names @ Daily), Void)
			!!Result.make (0)
			-- true_dummy serves as a dummy command instance, needed by
			-- some of the creation routines for other commands.
			!!true_dummy
			-- Likewise, some creation routines need a dummy of type
			-- RESULT_COMMAND [REAL], fulfilled by real_dummy.
			!!real_dummy.make (0.0)
			-- Create a pair for the CONSTANT instance (real_dummy) and
			-- add it to the list (Result).
			!!pair.make (real_dummy, "Operator with a numeric constant result")
			------ Create/insert non-MAL COMMANDs (from eiffel_library) ------
			Result.extend (pair)
			-- Create a pair for the TRUE_COMMAND instance (true_dummy) and
			-- add it to the list (Result).
			!!pair.make (true_dummy,
				"Boolean operator whose result is always true")
			Result.extend (pair)
			!FALSE_COMMAND!cmd
			!!pair.make (cmd,
				"Boolean operator whose result is always false")
			Result.extend (pair)
			!AND_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical 'and' operator")
			Result.extend (pair)
			!OR_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical 'or' operator")
			Result.extend (pair)
			!XOR_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical 'exclusive or' operator")
			Result.extend (pair)
			!EQ_OPERATOR!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
				"Operator that compares two numbers for equality")
			Result.extend (pair)
			-- bool_real_dummy is needed by boolean numeric client.
			!LT_OPERATOR!bool_real_dummy.make (real_dummy, real_dummy)
			!!pair.make (bool_real_dummy,
				"Numeric comparison operator that determines whether the %
				%first number is less than the second")
			Result.extend (pair)
			!GT_OPERATOR!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
				"Numeric comparison operator that determines whether the %
				%first number is greater than the second")
			Result.extend (pair)
			!GE_OPERATOR!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
				"Numeric comparison operator that determines whether the %
				%first number is greater than or equal to the second")
			Result.extend (pair)
			!LE_OPERATOR!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
				"Numeric comparison operator that determines whether the %
				%first%Nnumber is less than or equal to the second")
			Result.extend (pair)
			!IMPLICATION_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical implication operator - True when %
				%the left%Noperand is false or both operands are true")
			Result.extend (pair)
			!EQUIVALENCE_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical equivalence operator")
			Result.extend (pair)
			!ADDITION!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd, "Addition operator")
			Result.extend (pair)
			!SUBTRACTION!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd, "Subtraction operator")
			Result.extend (pair)
			!MULTIPLICATION!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd, "Multiplication operator")
			Result.extend (pair)
			!DIVISION!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd, "Division operator")
			Result.extend (pair)
			!SAFE_DIVISION!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
				"Division operator that handles division by zero safely")
			Result.extend (pair)
			!ABSOLUTE_VALUE!cmd.make (real_dummy)
			!!pair.make (cmd, "Absolute value operator")
			Result.extend (pair)
			!NOT_OPERATOR!cmd.make (true_dummy)
			!!pair.make (cmd, "Logical negation operator")
			Result.extend (pair)
			----------------- Create/insert MAL COMMANDs -----------------
			!!bnc_dummy -- Fulfills requirement for type RESULT_COMMAND [REAL].
			-- Create a pair for the BASIC_NUMERIC_COMMAND instance
			-- (bnc_dummy) and add it to the list.
			!!pair.make (bnc_dummy,
				"Operator that processes data for the current trading period")
			Result.extend (pair)
			!HIGHEST_VALUE!cmd.make (default_market_tuple_list, bnc_dummy, 1)
			!!pair.make (cmd,
				"Operator that extracts the highest value from a subsequence %
				%%Nof n trading periods")
			Result.extend (pair)
			!LOWEST_VALUE!cmd.make (default_market_tuple_list, bnc_dummy, 1)
			!!pair.make (cmd,
				"Operator that extracts the lowest value from a subsequence %
				%%Nof n trading periods")
			Result.extend (pair)
			!LINEAR_SUM!cmd.make (default_market_tuple_list, bnc_dummy, 1)
			!!pair.make (cmd,
				"Operator that sums a subsequence of n market records")
			Result.extend (pair)
			!MINUS_N_COMMAND!cmd.make (default_market_tuple_list, bnc_dummy, 1)
			!!pair.make (cmd,
				"Operator that processes data n periods before the current %
				%trading%N period - used, for example, for the momentum %
				%indicator")
			Result.extend (pair)
			!N_VALUE_COMMAND!cmd.make (1)
			!!pair.make (cmd, "n-valued operator whose value is `n'")
			Result.extend (pair)
			!MA_EXPONENTIAL!cmd.make (1)
			!!pair.make (cmd, "Moving average exponential")
			Result.extend (pair)
			!SETTABLE_OFFSET_COMMAND!cmd.make (default_market_tuple_list,
												bnc_dummy)
			!!pair.make (cmd,
				"Operator that processes data based on a settable offset %
				%from the current%Ntrading period - Warning: Be careful to %
				%set the offset correctly; setting%N it to the wrong value %
				%may cause out-of-bounds access to the data tuple array")
			Result.extend (pair)
			!VOLUME!cmd
			!!pair.make (cmd,
				"Operator that extracts the volume for the current trading %
				%period")
			Result.extend (pair)
			!LOW_PRICE!cmd
			!!pair.make (cmd,
				"Operator that extracts the low price for the current trading %
				%period")
			Result.extend (pair)
			!HIGH_PRICE!cmd
			!!pair.make (cmd,
				"Operator that extracts the high price for the current %
				%trading period")
			Result.extend (pair)
			!CLOSING_PRICE!cmd
			!!pair.make (cmd,
				"Operator that extracts the closing price for the current %
				%trading period")
			Result.extend (pair)
			!OPENING_PRICE!cmd
			!!pair.make (cmd,
				"Operator that extracts the opening price for the current %
				%trading period")
			Result.extend (pair)
			!OPEN_INTEREST!cmd
			!!pair.make (cmd,
				"Operator that extracts the open interest for the current %
				%trading period")
			Result.extend (pair)
			!BASIC_LINEAR_COMMAND!cmd.make (default_market_tuple_list)
			!!pair.make (cmd,
				"Operator that retrieves the value at the current %
				%trading period")
			Result.extend (pair)
			!UNARY_LINEAR_OPERATOR!cmd.make (default_market_tuple_list,
				real_dummy)
			!!pair.make (cmd,
				"Operator that uses an operand to operate on the current %
				%trading period")
			Result.extend (pair)
			!N_BASED_UNARY_OPERATOR!cmd.make (real_dummy, 1)
			!!pair.make (cmd,
				"N-based operator whose value remains unchanged after %
				%initialization and that uses%Nan operand to obtain its value")
			Result.extend (pair)
			!BOOLEAN_NUMERIC_CLIENT!cmd.make (bool_real_dummy, real_dummy,
												real_dummy)
			!!pair.make (cmd, "Operator that makes a decision based on %
				%the value of executing its%Nboolean operator - if the %
				%result is true, value is set to the result of%Nexecuting %
				%its 'true command'; otherwise, value is set to the %
				%result of%Nexecuting its 'false command'.")
			Result.extend (pair)
			!SIGN_ANALYZER!cmd.make (real_dummy, real_dummy, false)
			!!pair.make (cmd,
				"Operator that detects sign changes with respect to its %
				%left and right operands")
			Result.extend (pair)
			!SLOPE_ANALYZER!cmd.make (default_market_tuple_list)
			!!pair.make (cmd,
				"Operator that calculates the slope of a function")
			Result.extend (pair)
			!FUNCTION_BASED_COMMAND!cmd.make (stock, real_dummy)
			!!pair.make (cmd,
				"Operator that processes a sequence of market records %
				%obtained from a%Nmarket function - only used by %
				%ONE_VARIABLE_FUNCTION_ANALYZER")
			Result.extend (pair)
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

feature {NONE} -- Implementation

	default_market_tuple_list: LIST [MARKET_TUPLE] is
			-- Default list of MARKET_TUPLE to provide to the make routines
			-- of those COMMANDs that require such
		once
			!LINKED_LIST [MARKET_TUPLE]!Result.make
		end

end -- COMMANDS
