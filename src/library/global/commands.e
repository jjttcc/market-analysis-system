indexing
	description: "An instance of each instantiable COMMAND class"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	COMMANDS

feature -- Access

	commands_and_descriptions: ARRAYED_LIST [PAIR [COMMAND, STRING]] is
			-- An instance and description of each COMMAND class
		local
			true_dummy: TRUE_COMMAND
			bool_real_dummy: LT_OPERATOR
			cmd: COMMAND
			real_dummy: CONSTANT
			pair: PAIR [COMMAND, STRING]
			bnc_dummy: BASIC_NUMERIC_COMMAND
		once
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
			------ Create/insert non-TAL COMMANDs (from eiffel_library) ------
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
			----------------- Create/insert TAL COMMANDs -----------------
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
				"Operator that sums a subsequence of n market tuples")
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
				%from the current trading period")
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
				"Operator that retrieves the price at the current %
				%trading period")
			Result.extend (pair)
			!BOOLEAN_NUMERIC_CLIENT!cmd.make (bool_real_dummy, real_dummy,
												real_dummy)
			!!pair.make (cmd, "[This one is very hard to describe.]")
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
		ensure
			one_of_each: one_of_each (Result)
		end

	command_instances: ARRAYED_LIST [COMMAND] is
			-- An instance of each COMMAND class
		once
			!!Result.make (commands_and_descriptions.count)
			from
				commands_and_descriptions.start
			until
				commands_and_descriptions.exhausted
			loop
				Result.extend (commands_and_descriptions.item.left)
				commands_and_descriptions.forth
			end
		end

	command_names: ARRAYED_LIST [STRING] is
			-- The name of each element of `command_instances'
		once
			!!Result.make (command_instances.count)
			Result.compare_objects
			from
				command_instances.start
			until
				command_instances.exhausted
			loop
				Result.extend (command_instances.item.generator)
				command_instances.forth
			end
		ensure
			object_comparison: Result.object_comparison
		end

	description (cmd: COMMAND): STRING is
			-- The description of the run-time type of `cmd'
		do
			from
				commands_and_descriptions.start
			until
				Result /= Void or commands_and_descriptions.exhausted
			loop
				if commands_and_descriptions.item.left.same_type (cmd) then
					Result := commands_and_descriptions.item.right
				else
					commands_and_descriptions.forth
				end
			end
		end

	command_with_generator (name: STRING): COMMAND is
			-- COMMAND instance whose generating type matches `name' -
			-- Void if there is no COMMAND instance whose generator matches
			-- name.
		do
			from
				command_instances.start
			until
				Result /= Void or command_instances.exhausted
			loop
				if command_instances.item.generator.is_equal (name) then
					Result := command_instances.item
				end
				command_instances.forth
			end
		end

feature {NONE} -- Implementation

	one_of_each (cmds: ARRAYED_LIST [PAIR [COMMAND, STRING]]): BOOLEAN is
		local
			names: ARRAYED_LIST [STRING]
		do
			Result := true
			!!names.make (cmds.count)
			names.compare_objects
			from
				cmds.start
			until
				Result = false or cmds.exhausted
			loop
				if names.has (cmds.item.right) then
					Result := false
				else
					names.extend (cmds.item.right)
					cmds.forth
				end
			end
		end

	default_market_tuple_list: LIST [MARKET_TUPLE] is
			-- Default list of MARKET_TUPLE to provide to the make routines
			-- of those COMMANDs that require such
		once
			!LINKED_LIST [MARKET_TUPLE]!Result.make
		end

end -- COMMANDS
