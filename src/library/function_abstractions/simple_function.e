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
		do
			trading_period_type := type
			arrayed_list_make (300)
		ensure
			tpt_set: trading_period_type = type
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

	set_trading_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set trading_period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			trading_period_type := arg
		ensure
			trading_period_type_set: trading_period_type = arg and
				trading_period_type /= Void
		end

	finish_loading is
			-- Notify this instance that the process of loading its
			-- data is finished.
			-- The class that loads the data into this object should
			-- always call this procedure after the load process ends
			-- and before `data' is used.
		require
			period_type_not_void: trading_period_type /= Void
		do
			loaded := true
		ensure
			loaded: loaded
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := true
		ensure then
			Result = true
		end

	loaded: BOOLEAN
			-- Has `data' been loaded and post-processing completed?

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is false

feature {NONE} -- Basic operations

	process is
			-- Null action
		do
		end

invariant

	period_type_set_when_loaded: loaded implies (trading_period_type /= Void)

end -- class SIMPLE_FUNCTION
