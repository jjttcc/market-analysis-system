indexing
	description:
		"A numeric command that operates on the current item of a linear %
		%structure of market tuples"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	NUMERIC_COMMAND

feature -- Basic operations

	execute (arg: ANY) is
				-- Can be redefined by ancestors.
		do
			value := target.item.value
		end

feature {TEST_FUNCTION_FACTORY} -- Element change

	set_target (in: LINEAR [MARKET_TUPLE]) is
		do
			target := in
		ensure then
			target = in
			target /= Void
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
			Result := true
		ensure then
			is_true: Result = true
		end

feature {NONE}

	target: LINEAR [MARKET_TUPLE]

end -- class BASIC_LINEAR_COMMAND
