note
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
		export
			{NONE} copy
		undefine
			is_equal, copy, out
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
			{DATA_SCANNER, COMPOSITE_TUPLE_BUILDER} wipe_out
			{ANY} is_empty, count, before, area_v2, extendible, valid_index,
				readable, index, prunable
		end

creation {FACTORY}

	make

creation {ARRAYED_LIST}

--!!!To fix compiler error
	arrayed_list_make

feature {NONE} -- Initialization

	make (type: TIME_PERIOD_TYPE)
		do
			trading_period_type := type
			arrayed_list_make (300)
		ensure
			tpt_set: trading_period_type = type
		end

feature -- Access

	data: MARKET_TUPLE_LIST [G]
			-- Contents - market tuple data
		do
			Result := Current
		end

	trading_period_type: TIME_PERIOD_TYPE
			-- Period type of `data'

	short_description: STRING
		note
			once_status: global
		once
			Result := "Simple Function"
		end

	full_description: STRING
		do
			create Result.make (40)
			Result.append (short_description)
			Result.append (" with ")
			Result.append (count.out)
			Result.append (" records")
		end

	parameters: LIST [TREE_NODE]
--	parameters: LIST [FUNCTION_PARAMETER]
-- !!!! indexing once_status: global??!!!
		once
--!!!!!			create {LINKED_LIST [FUNCTION_PARAMETER]} Result.make
--!!!!will this work???!!!:
			create {LINKED_LIST [TREE_NODE]} Result.make
		end

	processed_date_time: DATE_TIME
-- !!!! indexing once_status: global??!!!
		once
			-- Very early date
			create Result.make (1, 1, 1, 0, 0, 0)
		end

	children: LINKED_LIST [MARKET_FUNCTION]
-- !!!! indexing once_status: global??!!!
		once
			create Result.make
		end

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE]
		do
			Result := Current
		end

feature -- Status report

	processed: BOOLEAN
			-- Has this function been processed?
		do
			Result := True
		ensure then
			Result = True
		end

	loaded: BOOLEAN
			-- Has `data' been loaded and post-processing completed?

	has_children: BOOLEAN = False

feature {FACTORY} -- Status setting

	set_trading_period_type (arg: TIME_PERIOD_TYPE)
			-- Set trading_period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			trading_period_type := arg
		ensure
			trading_period_type_set: trading_period_type = arg and
				trading_period_type /= Void
		end

	finish_loading
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

	is_complex: BOOLEAN = False

feature {COMPOSITE_TUPLE_BUILDER} -- Basic operations

	process
			-- Null action
		do
		end

invariant

	period_type_set_when_loaded: loaded implies (trading_period_type /= Void)
	no_children: not has_children

end -- class SIMPLE_FUNCTION
