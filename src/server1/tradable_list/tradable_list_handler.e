indexing
	description: "Abstraction for managing multiple tradable lists"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE_LIST_HANDLER inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (daily_list, intraday_list: TRADABLE_LIST) is
		require
			one_not_void: intraday_list /= Void or daily_list /= Void
			counts_equal_if_both_valid: both_lists_valid implies
				intraday_list.count = daily_list.count
		do
			daily_market_list := daily_list
			intraday_market_list := intraday_list
		ensure
			lists_set: daily_market_list = daily_list and
				intraday_market_list = intraday_list
		end

feature -- Access

	daily_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is daily

	intraday_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is intraday

	list_for (period_type: TIME_PERIOD_TYPE): TRADABLE_LIST is
			-- The tradable list that holds data for `period_type'
		do
			if period_type.intraday then
				Result := intraday_market_list
			else
				Result := daily_market_list
			end
		end

	tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				TRADABLE [BASIC_MARKET_TUPLE] is
			-- The tradable for `period_type' associated with `symbol' -
			-- Void if the tradable for `symbol' is not found or if
			-- `period_type' is not a valid type for `symbol'
		local
			l: TRADABLE_LIST
		do
			error_occurred := false
			l := list_for (period_type)
			if l.symbols.has (symbol) then
				l.search_by_symbol (symbol)
				Result := l.item
				if l.fatal_error then
					error_occurred := true
					last_error := concatenation (<<
						"Error occurred retrieving data for ", symbol>>)
				end
			end
		ensure
			period_type_valid: Result /= Void implies
				Result.tuple_list_names.has (period_type.name)
		end

	tuple_list (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				SIMPLE_FUNCTION [BASIC_MARKET_TUPLE] is
			-- Tuple list for `period_type' associated with `symbol' -
			-- Void if the tradable for `symbol' is not found or if
			-- `period_type' is not a valid type for `symbol'
		local
			l: TRADABLE_LIST
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			error_occurred := false
			l := list_for (period_type)
			if l.symbols.has (symbol) then
				l.search_by_symbol (symbol)
				t := l.item
				if not l.fatal_error then
					Result := t.tuple_list (period_type.name)
				else
					error_occurred := true
					last_error := concatenation (<<
						"Error occurred retrieving data for ", symbol>>)
				end
			end
		ensure
			same_period_type: Result /= Void implies
				Result.trading_period_type.is_equal (period_type)
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		do
			if not daily_market_list.empty then
				Result := daily_market_list.symbols
			else
				Result := intraday_market_list.symbols
			end
		ensure then
			object_comparison: Result.object_comparison
		end

	period_types (symbol: STRING): ARRAYED_LIST [STRING] is
			-- Names of all period types available for `symbol' -
			-- Void if the tradable for `symbol' is not found
		local
			l: LIST [TIME_PERIOD_TYPE]
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			error_occurred := false
			if daily_market_list /= Void then
				daily_market_list.search_by_symbol (symbol)
				t := daily_market_list.item
				if not daily_market_list.fatal_error then
					l := t.period_types.linear_representation
					create Result.make (l.count)
					from
						l.start
					until
						l.exhausted
					loop
						Result.extend (l.item.name)
						l.forth
					end
				else
					error_occurred := true
					last_error := concatenation (<<
						"Error occurred retrieving period types for ",
						symbol>>)
				end
			end
			if not error_occurred and intraday_market_list /= Void then
				intraday_market_list.search_by_symbol (symbol)
				t := intraday_market_list.item
				if not intraday_market_list.fatal_error then
					l := t.period_types.linear_representation
					if Result = Void then
						create Result.make (l.count)
					end
					from
						l.start
					until
						l.exhausted
					loop
						Result.extend (l.item.name)
						l.forth
					end
				else
					error_occurred := true
					last_error := concatenation (<<
						"Error occurred retrieving period types for ",
						symbol>>)
				end
			end
		end

	last_error: STRING
			-- Description of last error

feature -- Status report

	both_lists_valid: BOOLEAN is
			-- Are both lists non-void and nonempty?
		do
			Result := daily_market_list /= Void and then
				not daily_market_list.empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.empty
		ensure
			definition: Result = (daily_market_list /= Void and then
				not daily_market_list.empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.empty)
		end

	error_occurred: BOOLEAN
			-- Did an error occur during the last operation?

feature -- Basic operations

	clear_caches is
			-- Clear the cache of all lists.
		do
			if daily_market_list /= Void then
				daily_market_list.clear_cache
			end
			if intraday_market_list /= Void then
				intraday_market_list.clear_cache
			end
		end

invariant

	both_lists_not_void:
		not (daily_market_list = Void and intraday_market_list = Void)
	counts_equal_if_both_valid: both_lists_valid implies
		daily_market_list.count = intraday_market_list.count

end -- class TRADABLE_LIST_HANDLER
