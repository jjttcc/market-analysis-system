indexing
	description: 
		"A market function that is also an array of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_FUNCTION [G->MARKET_TUPLE] inherit

	MARKET_FUNCTION
		undefine
			is_equal, copy, setup
		redefine
			output
		end

	MARKET_TUPLE_LIST [G]
		rename
			make as arrayed_list_make
		export {NONE}
			all
				{FACTORY}
			extend
		end

creation {FACTORY}

	make

feature -- Initialization

	make (type: TIME_PERIOD_TYPE) is
		require
			not_void: type /= Void
		do
			trading_period_type := type
		ensure
			tpt_set: trading_period_type = type and trading_period_type /= Void
		end

feature -- Access

	output: MARKET_TUPLE_LIST [G] is
		do
			Result := Current
		end

	trading_period_type: TIME_PERIOD_TYPE

	short_description: STRING is
		once
			Result := "Simple Function"
		end

	full_description: STRING is
		do
			!!Result.make (40)
			Result.append (short_description)
			Result.append (" with ")
			Result.append (count.out)
			Result.append (" records")
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		once
			!LINKED_LIST [FUNCTION_PARAMETER]!Result.make
		end

	processed_date_time: DATE_TIME is
		once
			-- Very early date
			!!Result.make (-500, 1, 1, 0, 0, 0)
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := output /= Void
		ensure then
			Result = (output /= Void)
		end

feature {NONE} -- Basic operations

	process is
			-- Null action
		do
		end

end -- class SIMPLE_FUNCTION
