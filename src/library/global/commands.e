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
			cmd: COMMAND
			real_dummy: CONSTANT
			pair: PAIR [COMMAND, STRING]
		once
			!!Result.make (0)
			-- true_dummy serves as a dummy command instance, needed by
			-- some of the creation routines for other commands.
			!!true_dummy
			-- Likewise, some creation routines need a dummy of type
			-- RESULT_COMMAND [REAL], fulfilled by real_dummy.
			!!real_dummy.make (0.0)
			!!pair.make (real_dummy, "Command with a numeric constant result")
			Result.extend (pair)
			!FALSE_COMMAND!cmd
			!!pair.make (cmd,
				"Boolean command whose result is always false")
			Result.extend (pair)
			!!pair.make (true_dummy,
				"Boolean command whose result is always true")
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
			!LT_OPERATOR!cmd.make (real_dummy, real_dummy)
			!!pair.make (cmd,
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
				%first number is less than or equal to the second")
			Result.extend (pair)
			!IMPLICATION_OPERATOR!cmd.make (true_dummy, true_dummy)
			!!pair.make (cmd, "Logical implication operator")
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

end -- COMMANDS
