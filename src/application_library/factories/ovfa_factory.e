indexing
	description:
		"Factory class that manufactures ONE_VARIABLE_FUNCTION_ANALYZERs"
	note: "Features function, period_type, operator, and event_type should %
		%all be non-Void when execute is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class OVFA_FACTORY inherit

	EVENT_GENERATOR_FACTORY
		rename
			initialize_signal_type as make
		redefine
			product
		end

creation

	make

feature -- Access

	product: ONE_VARIABLE_FUNCTION_ANALYZER

	function: MARKET_FUNCTION
			-- The function to be associated with the new OVFA

	period_type: TIME_PERIOD_TYPE
			-- The time period type to be associated with the new OVFA

	operator: RESULT_COMMAND [BOOLEAN]
			-- The operator to be associated with the new OVFA

	left_offset: INTEGER
			-- Left offset value to provide to the new OVFA

feature -- Status setting

	set_function (arg: MARKET_FUNCTION) is
			-- Set function to `arg'.
		require
			arg_not_void: arg /= Void
		do
			function := arg
		ensure
			function_set: function = arg and function /= Void
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

	set_left_offset (arg: INTEGER) is
			-- Set left_offset to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			left_offset := arg
			debug ("editing")
				print ("OVFA_FCT left offset set to: "); print (left_offset)
				print ("%N")
			end
		ensure
			left_offset_set: left_offset = arg and left_offset >= 0
		end

feature -- Basic operations

	execute is
		do
			create product.make (function, operator, event_type,
				signal_type, period_type)
			if left_offset > 0 then
				product.set_left_offset (left_offset)
				debug ("editing")
					print ("OVFA_FCT created OVFA and set its offset to: ")
					print (product.left_offset)
					print ("%N")
				end
			end
		end

end -- OVFA_FACTORY
