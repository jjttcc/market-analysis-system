indexing
	description:
		"A market function that is also an sequence of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SIMPLE_FUNCTION [G->MARKET_TUPLE] inherit

	MARKET_FUNCTION
		rename
			output as data
		export {NONE}
			copy, setup
		undefine
			is_equal, copy, setup
		redefine
			data
		end

	MARKET_TUPLE_LIST [G]
		rename
			make as arrayed_list_make
		export {NONE}
			all
				{FACTORY}
			extend, count, first, last, empty, i_th
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (type: TIME_PERIOD_TYPE) is
		require
			not_void: type /= Void
		do
			trading_period_type := type
			arrayed_list_make (300)
		ensure
			tpt_set: trading_period_type = type and trading_period_type /= Void
		end

feature -- Access

	data: MARKET_TUPLE_LIST [G] is
			-- Contents - market tuple data
		do
			Result := Current
		end

	trading_period_type: TIME_PERIOD_TYPE
			-- Period type of `data'

	short_description: STRING is
		once
			Result := "Simple Function"
		end

	full_description: STRING is
		do
			create Result.make (40)
			Result.append (short_description)
			Result.append (" with ")
			Result.append (count.out)
			Result.append (" records")
		end

	parameters: LIST [FUNCTION_PARAMETER] is
		once
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
		end

	processed_date_time: DATE_TIME is
		once
			-- Very early date
			create Result.make (1, 1, 1, 0, 0, 0)
		end

feature {FACTORY} -- Status setting

	finish_loading is
			-- Notify this instance that the process of loading its
			-- data is finished.  Does nothing here - may change the
			-- object's state in descendants.
			-- The class that loads the data into this object should
			-- always call this procedure after the load process ends.
		do
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := true
		ensure then
			Result = true
		end

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is false

feature {NONE} -- Basic operations

	process is
			-- Null action
		do
		end

end -- class SIMPLE_FUNCTION
