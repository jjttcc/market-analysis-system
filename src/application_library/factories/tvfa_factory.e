indexing
	description:
		"Factory class that manufactures TWO_VARIABLE_FUNCTION_ANALYZERs"
	note:
		"Features left_function, right_function, period_type, and event_type %
		%should all be non-Void when execute is called.  (operator may be %
		%Void.)"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TVFA_FACTORY inherit

	EVENT_GENERATOR_FACTORY
		redefine
			product
		end

feature -- Access

	product: TWO_VARIABLE_FUNCTION_ANALYZER

	left_function, right_function: MARKET_FUNCTION
			-- Left and right functions to be associated with the new TVFA

	period_type: TIME_PERIOD_TYPE
			-- The time period type to be associated with the new TVFA

	operator: RESULT_COMMAND [BOOLEAN]
			-- The operator to be associated with the new TVFA

feature -- Status setting

	set_functions (left, right: MARKET_FUNCTION) is
			-- Set function to `arg'.
		require
			not_void: left /= Void and right /= Void
		do
			left_function := left
			right_function := right
		ensure
			functions_set: left_function = left and right_function = right
		end

	set_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			period_type := arg
		ensure
			period_type_set: period_type = arg and period_type /= Void
		end

	set_operator (arg: RESULT_COMMAND [BOOLEAN]) is
			-- Set operator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			operator := arg
		ensure
			operator_set: operator = arg and operator /= Void
		end

feature -- Basic operations

	execute is
		do
			!!product.make (left_function, right_function, event_type,
							period_type)
			if operator /= Void then
				product.set_operator (operator)
			end
		end

end -- TVFA_FACTORY
