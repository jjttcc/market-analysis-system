indexing
	description: "Abstraction for managing multiple tradable lists"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_LIST_HANDLER inherit

	TRADABLE_DISPENSER

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make (daily_list, intraday_list: TRADABLE_LIST;
			inds: SEQUENCE [MARKET_FUNCTION]) is
		require
			one_not_void: intraday_list /= Void or daily_list /= Void
			inds_exist: inds /= Void
			counts_equal_if_both_valid: daily_list /= Void and then
				not daily_list.is_empty and then intraday_list /= Void and then
				not intraday_list.is_empty implies
				intraday_list.count = daily_list.count
			consistent_caching: daily_list /= Void and intraday_list /= Void
				implies daily_list.caching_on = intraday_list.caching_on
			-- for_all i member_of 1 .. daily_list.count it_holds
			--    (daily_list.symbols @ i).is_equal (intraday_list.symbols @ i)
		do
			daily_market_list := daily_list
			intraday_market_list := intraday_list
			indicators := inds
		ensure
			lists_set: daily_market_list = daily_list and
				intraday_market_list = intraday_list
			indicators_set: indicators = inds
		end

feature -- Access

	index: INTEGER is
		do
			if symbol_list /= Void then
				Result := symbol_list.index
			end
		end

	tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				TRADABLE [BASIC_MARKET_TUPLE] is
		local
			l: TRADABLE_LIST
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			last_tradable := Void
			reset_error_state
			l := list_for (period_type)
			if l /= Void then
				if l.symbols.has (symbol) then
					l.search_by_symbol (symbol)
					if not l.fatal_error then
						t := l.item
						if
							t /= Void and then
							t.valid_period_type (period_type)
						then
							Result := t
							last_tradable := t
						end
					end
					if l.fatal_error then
						error_occurred := True
						last_error := concatenation (<<
							"Error occurred retrieving data for ", symbol>>)
						l.clear_error
					end
				else
					error_occurred := True
					last_error := concatenation (<<
						"Symbol ", symbol, " not found">>)
				end
			end
		end

	symbols: LIST [STRING] is
		do
			reset_error_state
			if daily_market_list /= Void then
				Result := daily_market_list.symbols
			elseif intraday_market_list /= Void then
				Result := intraday_market_list.symbols
			end
		ensure then
			correct_count: daily_market_list /= Void implies
				Result.count = daily_market_list.count and
				intraday_market_list /= Void implies
					Result.count = intraday_market_list.count
		end

	period_type_names_for (symbol: STRING): ARRAYED_LIST [STRING] is
		local
			l: LIST [TIME_PERIOD_TYPE]
			t: TRADABLE [BASIC_MARKET_TUPLE]
			tbl: HASH_TABLE [BOOLEAN, STRING]
		do
			reset_error_state
			if daily_market_list /= Void then
				daily_market_list.search_by_symbol (symbol)
				if not daily_market_list.fatal_error then
					t := daily_market_list.item
				end
				if not daily_market_list.fatal_error then
					l := t.period_types.linear_representation
					create tbl.make (l.count)
					from
						l.start
					until
						l.exhausted
					loop
						tbl.extend (True, l.item.name)
						l.forth
					end
				else
					error_occurred := True
					last_error := concatenation (<<"Error occurred ",
						"retrieving non-intraday period types for ", symbol>>)
				end
			end
			if not error_occurred and intraday_market_list /= Void then
				intraday_market_list.search_by_symbol (symbol)
				if not intraday_market_list.fatal_error then
					t := intraday_market_list.item
				end
				if not intraday_market_list.fatal_error then
					l := t.period_types.linear_representation
					if tbl = Void then
						create tbl.make (l.count)
					end
					from
						l.start
					until
						l.exhausted
					loop
						tbl.extend (True, l.item.name)
						l.forth
					end
				else
					error_occurred := True
					last_error := concatenation (<<"Error occurred ",
						"retrieving intraday period types for ", symbol>>)
				end
			end
			check tbl_check: not error_occurred implies tbl /= Void end
			if tbl /= Void and not tbl.is_empty then
				tbl.compare_objects
				Result := period_types_sorted_by_duration (tbl)
			end
		end

	current_symbol: STRING is
		do
			Result := symbol_list.item
		end

	indicators: SEQUENCE [MARKET_FUNCTION]

feature -- Status report

	after: BOOLEAN is
		do
			Result := symbol_list = Void or else symbol_list.after
		end

	is_empty: BOOLEAN is
		do
			if daily_market_list /= Void then
				Result := daily_market_list.is_empty
			else
				Result := intraday_market_list.is_empty
			end
		end

	isfirst: BOOLEAN is
		do
			Result := symbol_list /= Void and symbol_list.isfirst
		end

	off: BOOLEAN is
		do
			Result := symbol_list = Void or else symbol_list.off or else
				is_empty
		end

	caching_on: BOOLEAN is
		do
			Result := (daily_market_list = Void or else
				daily_market_list.caching_on) and (intraday_market_list = Void
				or else intraday_market_list.caching_on)
		end

feature -- Cursor movement

	finish is
		do
			symbol_list.finish
		end

	forth is
		do
			symbol_list.forth
		end

	start is
		do
			if symbol_list = Void then
				symbol_list := symbols
			end
			symbol_list.start
		end

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
			symbol_list := Void
		end

	turn_caching_off is
		do
			if daily_market_list /= Void then
				daily_market_list.turn_caching_off
			end
			if intraday_market_list /= Void then
				intraday_market_list.turn_caching_off
			end
		end

	turn_caching_on is
		do
			if daily_market_list /= Void then
				daily_market_list.turn_caching_on
			end
			if intraday_market_list /= Void then
				intraday_market_list.turn_caching_on
			end
		end

feature {NONE} -- Implementation

	daily_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is daily

	intraday_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is intraday

	symbol_list: LIST [STRING]
			-- List of all tradable symbols - used for iteration

	list_for (period_type: TIME_PERIOD_TYPE): TRADABLE_LIST is
			-- The tradable list that holds data for `period_type'
		do
			if period_type.intraday then
				Result := intraday_market_list
			else
				Result := daily_market_list
			end
		end

	both_lists_valid: BOOLEAN is
			-- Are both lists non-void and nonempty?
		do
			Result := daily_market_list /= Void and then
				not daily_market_list.is_empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.is_empty
		ensure
			definition: Result = (daily_market_list /= Void and then
				not daily_market_list.is_empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.is_empty)
		end

	period_types_sorted_by_duration (t: HASH_TABLE [BOOLEAN, STRING]):
		ARRAYED_LIST [STRING] is
			-- The result of a sort by duration, ascending, of the
			-- associated period type of each element of `t'
		require
			object_compare: t.object_comparison
		local
			l: LIST [TIME_PERIOD_TYPE]
			gs: expanded GLOBAL_SERVICES
		do
			from
				l := gs.period_types_in_order
				create Result.make (l.count)
				l.start
			until
				l.exhausted
			loop
				if t.has (l.item.name) then
					Result.force (l.item.name)
				end
				l.forth
			end
		end

	reset_error_state is
			-- Reset internal error state to no errors.
		do
			error_occurred := False
			if daily_market_list /= Void then
				daily_market_list.clear_error
			end
			if intraday_market_list /= Void then
				intraday_market_list.clear_error
			end
		end

invariant

	both_lists_not_void:
		not (daily_market_list = Void and intraday_market_list = Void)
	counts_equal_if_both_valid: both_lists_valid implies
		daily_market_list.count = intraday_market_list.count
	consistent_caching: daily_market_list /= Void and
		intraday_market_list /= Void implies
		daily_market_list.caching_on = intraday_market_list.caching_on
	-- for_all i member_of 1 .. daily_market_list.count it_holds
	--    (daily_market_list.symbols @ i).is_equal (
	--       intraday_market_list.symbols @ i)

end -- class TRADABLE_LIST_HANDLER
