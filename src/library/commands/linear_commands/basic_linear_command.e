indexing
	description:
		"A numeric command that operates on the current item of a linear %
		%structure of market tuples"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	NUMERIC_COMMAND

	LINEAR_ANALYZER

feature -- Basic operations

	execute (arg: ANY) is
				-- Can be redefined by ancestors.
		do
			value := target.item.value
		end

feature -- Status report

	arg_used: BOOLEAN is
		do
			Result := false
		ensure then
			not_used: Result = false
		end

	execute_precondition: BOOLEAN is
		do
			Result := target_set
		ensure then
			target_set: Result = target_set
		end

end -- class BASIC_LINEAR_COMMAND
