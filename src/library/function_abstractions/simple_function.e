indexing
	description:
		"A market function that is also an sequence of market tuples. %
		%Its purpose is to act as the innermost function in a composition %
		%of functions."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SIMPLE_FUNCTION [G->MARKET_TUPLE] inherit

	MARKET_FUNCTION
		rename
			output as data
		export {NONE}
			copy, setup
		undefine
			is_equal, copy, setup, out
		redefine
			data
		end

	MARKET_TUPLE_LIST [G]
		rename
			make as arrayed_list_make
		export
			{NONE} all
			{FACTORY, MARKET_FUNCTION_EDITOR} extend, first, last, i_th,
				item, off
			{MARKET_FUNCTION} make_from_array
			{ANY} is_empty, count
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
		indexing
			once_status: global
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
-- !!!! indexing once_status: global??!!!
		once
			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
		end

	processed_date_time: DATE_TIME is
-- !!!! indexing once_status: global??!!!
		once
			-- Very early date
			create Result.make (1, 1, 1, 0, 0, 0)
		end

	children: LINKED_LIST [MARKET_FUNCTION] is
-- !!!! indexing once_status: global??!!!
		once
			create Result.make
		end

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE] is
		do
			Result := Current
		end

feature -- Status report

	processed: BOOLEAN is
			-- Has this function been processed?
		do
			Result := True
		ensure then
			Result = True
		end

	loaded: BOOLEAN
			-- Has `data' been loaded and post-processing completed?

	has_children: BOOLEAN is False

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
			loaded := True
		ensure
			loaded: loaded
		end

feature {MARKET_FUNCTION} -- Status report

	is_complex: BOOLEAN is False

feature {NONE} -- Basic operations

	process is
			-- Null action
		do
		end

invariant

	period_type_set_when_loaded: loaded implies (trading_period_type /= Void)
	no_children: not has_children

end -- class SIMPLE_FUNCTION
